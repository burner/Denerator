module model;

import std.array : empty, front, split;
import std.traits : functionAttributes, FunctionAttribute;
import std.experimental.allocator.mallocator : Mallocator;
import std.exception : enforce;
import containers.hashmap;
import containers.hashset;
import containers.dynamicarray;

hash_t stringToHash(string str) @safe pure nothrow @nogc {
	hash_t hash = 5381;
	foreach(it; str) {
		hash = ((hash << 5) + hash) + it; /* hash * 33 + it */
	}
	
	return hash;
}

hash_t EntityToHash(in Entity e) pure @safe nothrow @nogc {
	return stringToHash(e.name);
}

alias EntityHashSet(T) = HashSet!(T, Mallocator, EntityToHash);
public alias StringHashSet = HashSet!(string, Mallocator, stringToHash);
public alias StringEntityMap(T) = HashMap!(string, T, Mallocator, stringToHash);

abstract class Entity {
	immutable(string) name;
	const(Entity) parent;
	string description;
	string longDescription;

	final override hash_t toHash() @safe pure nothrow @nogc {
		return stringToHash(this.name);
	}

	final override bool opEquals(Object other) @safe pure nothrow @nogc {
		Entity entity = cast(Entity)other;
		return this.name == entity.name;
	}

	this(string name, in Entity parent) {
		this.name = name;
		this.parent = parent;
	}

	string areYouIn(ref in StringHashSet store) const {
		if(this.name in store) {
			return this.name;
		} else if(this.parent is null) {
			return "";
		} else {
			return this.parent.areYouIn(store);
		}
	}

	const(Entity) areYouIn(ref in EntityHashSet!(/*const*/ Entity) store) const {
		if(cast(Entity)(this) in store) {
			return this;
		} else if(this.parent is null) {
			return null;
		} else {
			return this.parent.areYouIn(store);
		}
	}

	final string pathToRoot() const {
		if(this.parent is null) {
			return "";
		} else {
			auto tmp = this.parent.pathToRoot();
			if(tmp.empty) {
				return this.name;
			} else {
				return tmp ~ '.' ~ this.name;
			}
		}
	}
}

class Actor : Entity {
	string type;
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

struct SearchResult {
	const(Entity) entity;
	string[] path;
}

class TheWorld : Entity {
	StringEntityMap!(Actor) actors;
	StringEntityMap!(SoftwareSystem) softwareSystems;
	StringEntityMap!(HardwareSystem) hardwareSystems;
	StringEntityMap!(Type) typeContainerMapping;
	StringEntityMap!(Entity) connections;

	this(in string name) {
		super(name, null);
	}

	SearchResult search(Entity needle) {
		assert(needle !is null);

		if(const(Entity) mnp = holdsEntityImpl(needle, this.actors,
					this.softwareSystems, this.hardwareSystems,
					this.typeContainerMapping, this.connections)) 
		{
			return SearchResult(mnp, [super.name]);
		}

		SearchResult dummy;
		return dummy;
	}

	Actor getOrNewActor(in string name) {
		return enforce(getOrNewEntityImpl!Actor(name, this.actors, this));
	}

	SoftwareSystem getOrNewSoftwareSystem(in string name) {
		return enforce(getOrNewEntityImpl!SoftwareSystem(name,
			this.softwareSystems, this)
		);
	}

	HardwareSystem getOrNewHardwareSystem(in string name) {
		return enforce(getOrNewEntityImpl!HardwareSystem(name,
			this.hardwareSystems, this)
		);
	}

	T getOrNew(T,F,O)(in string name, F from, O to) 
	{
		T con =  enforce(getOrNewEntityImpl!(Entity,T)(
			name, this.connections, this
		));
		con.from = from;
		con.to = to;
		return con;
	}

	Type getOrNewType(in string name) {
		return enforce(getOrNewEntityImpl!(Type)(name,
			this.typeContainerMapping, null
		));
	}

	override string areYouIn(ref in StringHashSet store) const {
		return super.name in store ? super.name : "";
	}

	override const(Entity) areYouIn(ref in EntityHashSet!(/*const*/ Entity) store) 
			const 
	{
		if(cast(Entity)(this) in store) {
			return this;
		} else {
			return null;
		}
	}
}

struct ConnectionCount {
	long low;
	long high;
}

class ConnectionImpl : Entity {
	Entity from;
	Entity to;

	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

// Dependency are basically import
class Dependency : ConnectionImpl {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

// Connection are logical connections
class Connection : ConnectionImpl {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

// from and to can exists without each other
class Aggregation : ConnectionImpl {
	ConnectionCount fromCnt;
	ConnectionCount toCnt;

	// a MemberVariable that stores fromCnt instances of from
	MemberVariable fromStore; 

	// a MemberVariable that stores toCnt instances of to
	MemberVariable toStore; 

	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

// from can not exists without to
class Composition : ConnectionImpl {
	ConnectionCount fromCnt; // to count is always 1 for Composition

	// a MemberVariable that stores fromCnt instances of from
	MemberVariable fromStore; 
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

// Generalization subclass a Class
class Generalization : ConnectionImpl {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

// Realization implements a Interface
class Realization : ConnectionImpl {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

class HardwareSystem : Entity {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

class SoftwareSystem : Entity {
	StringEntityMap!(Container) containers;
	
	this(in string name, in Entity parent) {
		super(name, parent);
	}

	Container getOrNewContainer(in string name) {
		return enforce(getOrNewEntityImpl!Container(name, this.containers,
			this)
		);
	}

	SearchResult holdsEntity(const Entity needle) const {
		const Entity tmp = holdsEntitySingleImpl(needle, this.containers);
		if(tmp !is null) {
			return SearchResult(tmp, [super.name]);	
		} else {
			foreach(it; this.containers.keys()) {
				const(Container) con = this.containers[it];
				SearchResult ret = con.holdsEntity(needle);
				if(ret.entity !is null) {
					ret.path ~= super.name;
					return ret;
				}
			}
		}
		SearchResult dummy;
		return dummy;
	}
}

class Container : Entity {
	string technology;
	StringEntityMap!(Component) components;
	StringEntityMap!(Class) classes;
	
	this(in string name, in Entity parent) {
		super(name, parent);
	}

	Component getOrNewComponent(in string name) {
		return enforce(getOrNewEntityImpl!Component(name, this.components,
			this)
		);
	}

	SearchResult holdsEntity(const Entity needle) const {
		const(Entity) tmp = holdsEntityImpl(needle, this.components, this.classes);
		if(tmp !is null) {
			return SearchResult(tmp, [super.name]);
		} else {
			foreach(it; this.components.keys()) {
				const(Component) com = this.components[it];
				SearchResult ret = com.holdsEntity(needle);
				if(ret.entity !is null) {
					ret.path ~= super.name;
					return ret;
				}
			}
		}
		SearchResult dummy;
		return dummy;
	}
}

// e.g. [D] = "protected"
class ProtectedEntity : Entity {
	HashMap!(string,string) protection;

	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

class Component : ProtectedEntity {
	StringEntityMap!(Class) classes;
	Component[string] subComponents;
	
	this(in string name, in Entity parent) {
		super(name, parent);
	}

	Component getOrNewSubComponent(in string name) {
		if(name in this.subComponents) {
			return this.subComponents[name];
		} else {
			auto n = new Component(name, this);
			this.subComponents[name] = n;
			return n;
		}
	}

	SearchResult holdsEntity(const Entity needle) const {
		const Entity tmp = holdsEntityImpl(needle, this.classes,
				this.subComponents);
		if(tmp !is null) {
			return SearchResult(tmp, [super.name]);
		} else {
			foreach(it; this.subComponents.keys()) {
				const(Component) com = this.subComponents[it];
				auto ret = com.holdsEntity(needle);
				if(ret.entity !is null) {
					ret.path ~= super.name;
					return ret;
				}
			}
		}

		SearchResult dummy;
		return dummy;
	}
}

class Class : ProtectedEntity {
	StringEntityMap!(Member) members;
	StringEntityMap!(string) containerType;

	DynamicArray!Entity parents;
	
	this(in string name) {
		super(name, null);
	}

	S getOrNew(S)(in string name) {
		return enforce(getOrNewEntityImpl!(Member,S)(name, this.members, this));
	}

	override string areYouIn(ref in StringHashSet store) const {
		if(this.name in store) {
			return this.name;
		} else if(this.parents.empty) {
			return "";
		} else {
			foreach(it; this.parents) {
				auto tmp = it.areYouIn(store);
				if(!tmp.empty) {
					return tmp;
				}
			}
			return "";
		}
	}

}

class MemberModifier : Entity {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

class Type : Entity {
	StringEntityMap!(string) typeToLanguage;	

	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

/* This class maps types from one language to other languages

For instance, a D string may becomes a LONGTEXT in MySQL
*/
class TypeMapping {
	StringEntityMap!(Type) equivalencies;
}

class Member : ProtectedEntity {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

class MemberVariable : Member {
	Type type;
	string[][string] langSpecificAttributes;

	this(in string name, in Entity parent) {
		super(name, parent);
	}

	void addLandSpecificAttribute(string lang, string value) {
		this.langSpecificAttributes[lang] ~= value;
	}
}

unittest {
	auto mv = new MemberVariable("name");
	mv.addLandSpecificAttribue("Foo", "Bar");

	assert(mv.langSpecificAttributes["Foo"].length == 1);
	assert(mv.langSpecificAttributes["Foo"] == ["Bar"]);
}

class MemberFunction : Member {
	Type returnType;
	DynamicArray!MemberVariable parameter;
	DynamicArray!MemberModifier modifier;

	this(in string name, in Entity parent) {
		super(name, parent);
	}

	T getOrNew(T)(in string name) {
		static if(is(T == MemberVariable)) {
			return enforce(getOrNewEntityImpl!MemberVariable(name,
				this.parameter, this)
			);
		} else static if(is(T == MemberFunction)) {
			return enforce(getOrNewEntityImpl!MemberFunction(name,
				this.modifer, this)
			);
		}
	}
}

private Entity getSubEntityImpl(T)(ref T map, const(string[]) uri) {
	if(!uri.empty && uri.front in map) {
		Entity sub = map[uri.front];
		if(uri.length == 1) {
			return sub;
		} else {
			return sub.getSubEntity(uri[1 .. $]);
		}
	}

	return null;
}

private S getOrNewEntityImpl(T, S=T)(in string name, ref StringEntityMap!(T) map,
		in Entity parent) 
{
	if(name in map) {
		return cast(S)map[name];
	} else {
		S act = new S(name, parent);
		map[name] = act;
		return act;
	}
}

private T getOrNewEntityImpl(T)(in string name, ref DynamicArray!(T) arr,
		in Entity parent) 
{
	foreach(it; arr) {
		if(it.name == name) {
			return it;
		}
	}

	T ne = new T(name, parent);
	arr.insert(ne);
	return ne;
}

/** Gets a class from one of the containers and adds them to all other
containers. If the Class can't be find by its name it is created and added
to all containers.
*/
Class getOrNewClass(T...)(in string name, T stuffThatHoldsClasses) {
	Class cls;
	foreach(it; stuffThatHoldsClasses) {
		if(name in it.classes) {
			cls = it.classes[name];
			break;
		}
	}

	if(cls is null) {
		cls = new Class(name);
	}

	foreach(it; stuffThatHoldsClasses) {
		if(name !in it.classes) {
			it.classes[name] = cls;
			cls.parents.insert(it);
		}
	}
	return cls;
}

const(Entity) holdsEntitySingleImpl(T)(const Entity needle, ref T arg)
{
	foreach(key; arg.keys()) {
		auto entity = arg[key];
		if(needle is entity) {
			return entity;
		}
	}

	return null;
}

const(Entity) holdsEntityImpl(T...)(const Entity needle, ref T args)
{
	foreach(ref arg; args) {
		foreach(key; arg.keys()) {
			auto entity = arg[key];
			if(needle is entity) {
				return entity;
			}
		}
	}

	return null;
}
