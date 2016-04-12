module model;

import std.traits : functionAttributes, FunctionAttribute;
import std.experimental.allocator.mallocator : Mallocator;
import containers.hashset;

private hash_t stringToHash(string str) @safe pure nothrow @nogc {
	hash_t hash = 5381;
	foreach(it; str) {
		hash = ((hash << 5) + hash) + it; /* hash * 33 + it */
	}
	
	return hash;
}

hash_t EntityToHash(Entity e) pure @safe nothrow @nogc {
	return stringToHash(e.name);
};

//alias EntityHashSet(T) = HashSet!(T, Mallocator, EntityToHash);

enum ActorType {
	SoftWareSystem,
	Person
}

abstract class Entity {
	string name;
	string description;

	final override hash_t toHash() @safe pure nothrow @nogc {
		return stringToHash(this.name);
	}

	final override bool opEquals(Object other) @safe pure nothrow @nogc {
		Entity entity = cast(Entity)other;
		return this.name == entity.name;
	}
}

class Actor : Entity {
	ActorType type;
}

class SoftwareSystem : Entity {
	HashSet!(Component, Mallocator, EntityToHash) components;
}

class Container : Entity {
	//EntityHashSet!(Component) components;
}

class Component : Entity {
	//EntityHashSet!(Class) classes;
}

class Class : Entity {
	//EntityHashSet!(MemberVariable) memberVariables;
	//EntityHashSet!(MemberFunction) memberFunctions;
}

class MemberVariable : Entity {
}

class MemberFunction : Entity {
}
