module model;

import std.array : empty, front, split;
import std.traits : functionAttributes, FunctionAttribute;
import std.experimental.allocator.mallocator : Mallocator;
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
alias StringEntityMap(T) = HashMap!(string, T, Mallocator, stringToHash);

abstract class Entity {
	immutable(string) name;
	string description;
	string longDescription;

	final override hash_t toHash() @safe pure nothrow @nogc {
		return stringToHash(this.name);
	}

	final override bool opEquals(Object other) @safe pure nothrow @nogc {
		Entity entity = cast(Entity)other;
		return this.name == entity.name;
	}

	Entity getSubEntity(const(string[]) uri) {
		return null;
	}

	this(string name) {
		this.name = name;
	}
}

class Actor : Entity {
	string type;
	this(in string name) {
		super(name);
	}
}

class TheWorld : Entity {
	StringEntityMap!(Actor) actors;
	StringEntityMap!(SoftwareSystem) softwareSystems;
	StringEntityMap!(HardwareSystem) hardwareSystems;
	StringEntityMap!(Connection) connections;
	StringEntityMap!(Type[string]) typeContainerMapping;

	this(in string name) {
		super(name);
	}

	T getSubEntity(T)(string uri) {
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
	}

	Actor getOrNewActor(in string name) {
		return getOrNewEntityImpl!Actor(name, this.actors);
	}

	SoftwareSystem getOrNewSoftwareSystem(in string name) {
		return getOrNewEntityImpl!SoftwareSystem(name, this.softwareSystems);
	}

	HardwareSystem getOrNewHardwareSystem(in string name) {
		return getOrNewEntityImpl!HardwareSystem(name, this.hardwareSystems);
	}

	Connection getOrNewConnection(in string name) {
		return getOrNewEntityImpl!Connection(name, this.connections);
	}

	Type[string] getOrNewTypeMappings(in string name) {
		return getOrNewEntityImpl!(Type[string])(name,
			this.typeContainerMapping
		);
	}

	private static T getOrNewEntityImpl(T)(in string name, ref StringEntityMap!(T) map) {
		if(name in map) {
			return map[name];
		} else {
			T act = new T(name);
			map[name] = act;
			return act;
		}
	}
}

class Connection : Entity {
	Entity from;
	Entity two;
	
	this(in string name) {
		super(name);
	}
}

class HardwareSystem : Entity {
	
	this(in string name) {
		super(name);
	}
}

class SoftwareSystem : Entity {
	StringEntityMap!(Container) container;
	
	this(in string name) {
		super(name);
	}

	override Entity getSubEntity(const(string[]) uri) {
		return getSubEntityImpl(this.container, uri);
	}
}

class Container : Entity {
	StringEntityMap!(Component) components;
	
	this(in string name) {
		super(name);
	}

	override Entity getSubEntity(const(string[]) uri) {
		return getSubEntityImpl(this.components, uri);
	}
}

class Component : Entity {
	StringEntityMap!(Class) classes;
	Component[] subComponent;
	
	this(in string name) {
		super(name);
	}

	override Entity getSubEntity(const(string[]) uri) {
		return getSubEntityImpl(this.classes, uri);
	}
}

class Class : Entity {
	StringEntityMap!(Member) members;
	
	this(in string name) {
		super(name);
	}

	override Entity getSubEntity(const(string[]) uri) {
		return getSubEntityImpl(this.members, uri);
	}
}

class MemberModifier : Entity {
	this(in string name) {
		super(name);
	}
}

class Type : Entity {
	StringEntityMap!(MemberModifier) modifier;

	this(in string name) {
		super(name);
	}
}

/* This class maps types from one language to other languages

For instance, a D string may becomes a LONGTEXT in MySQL
*/
class TypeMapping {
	StringEntityMap!(Type) equivalencies;
}

class Member : Entity {

	this(in string name) {
		super(name);
	}
}

class MemberVariable : Member {
	StringEntityMap!(MemberModifier) modifier;
	Type type;

	this(in string name) {
		super(name);
	}
}

class MemberFunction : Member {
	Type returnType;
	DynamicArray!MemberVariable parameter;
	DynamicArray!MemberModifier modifier;

	this(in string name) {
		super(name);
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
