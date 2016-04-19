module model;

import std.array : empty, front, split;
import std.traits : functionAttributes, FunctionAttribute;
import std.experimental.allocator.mallocator : Mallocator;
import std.exception : enforce;
import containers.hashmap;
import containers.dynamicarray;

private hash_t stringToHash(string str) @safe pure nothrow @nogc {
	hash_t hash = 5381;
	foreach(it; str) {
		hash = ((hash << 5) + hash) + it; /* hash * 33 + it */
	}
	
	return hash;
}

hash_t EntityToHash(Entity e) pure @safe nothrow @nogc {
	return stringToHash(e.name);
}

alias EntityHashSet(T) = HashSet!(T, Mallocator, EntityToHash);
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
}

class Actor : Entity {
	string type;
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

class TheWorld : Entity {
	StringEntityMap!(Actor) actors;
	StringEntityMap!(SoftwareSystem) softwareSystems;
	StringEntityMap!(HardwareSystem) hardwareSystems;
	StringEntityMap!(Type) typeContainerMapping;
	StringEntityMap!(Connection) connections;

	this(in string name) {
		super(name, null);
	}

	/*T getSubEntity(T)(string uri) {
		const(string[]) uriSplit = split(uri, ".");

		auto toIterate = [this.actors, this.softwareSystems,
			 this.hardwareSystems, this.connections, this.types
		];

		foreach(it; toIterate) {
			Entity ret = it.getSubEntity(uriSplit);
			T cas = cast(T)ret;
			if(cas !is null) {
				return cas;
			}
		}

		return null;
	}*/

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
			this.hardwareSystems, null)
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
}

class ConnectionImpl(T,S) : Entity {
	T from;
	S to;

	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

class Dependency : ConnectionImpl!(Entity,Entity) {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}


class Connection : ConnectionImpl!(Entity,Entity) {
	string fromCnt;
	string toCnt;
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

class Aggregation : ConnectionImpl!(Class,Class) {
	string fromCnt;
	string toCnt;
	Type toImplType;
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

class Composition : ConnectionImpl!(Class,Class) {
	string fromCnt;
	string toCnt;
	Type toImplType;
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

class Generalization : ConnectionImpl!(Class,Class) {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

class Realization : ConnectionImpl!(Class,Class) {
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

	/*override Entity getSubEntity(const(string[]) uri) {
		return getSubEntityImpl(this.containers, uri);
	}*/

	Container getOrNewContainer(in string name) {
		return enforce(getOrNewEntityImpl!Container(name, this.containers,
			this)
		);
	}
}

class Container : Entity {
	StringEntityMap!(Component) components;
	StringEntityMap!(Class) classes;
	
	this(in string name, in Entity parent) {
		super(name, parent);
	}

	/*override Entity getSubEntity(const(string[]) uri) {
		return getSubEntityImpl(this.components, uri);
	}*/

	Component getOrNewComponent(in string name) {
		return enforce(getOrNewEntityImpl!Component(name, this.components,
			this)
		);
	}
}

class Component : Entity {
	StringEntityMap!(Class) classes;
	Component[] subComponent;
	
	this(in string name, in Entity parent) {
		super(name, parent);
	}

	/*override Entity getSubEntity(const(string[]) uri) {
		return getSubEntityImpl(this.classes, uri);
	}*/

	/*Class getOrNewClass(in string name) {
		return getOrNewEntityImpl!Class(name, this.classes);
	}*/
}

class Class : Entity {
	StringEntityMap!(Member) members;
	StringEntityMap!(string) containerType;
	
	this(in string name) {
		super(name, null);
	}

	/*override Entity getSubEntity(const(string[]) uri) {
		return getSubEntityImpl(this.members, uri);
	}*/

	S getOrNew(S)(in string name) {
		return enforce(getOrNewEntityImpl!(Member,S)(name, this.members, this));
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

class Member : Entity {
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

	void addLandSpecificAttribue(string lang, string value) {
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
			break;
		}
	}
	return cls;
}
