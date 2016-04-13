module model;

import std.array : empty, front, split;
import std.traits : functionAttributes, FunctionAttribute;
import std.experimental.allocator.mallocator : Mallocator;
import containers.hashmap;

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

enum ActorType {
	SoftwareSystem,
	HardwareSystem,
	Person,
}

abstract class Entity {
	string name;
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
}

class Actor : Entity {
	ActorType type;
}

class TheWorld : Entity {
	StringEntityMap!(Actor) actors;
	StringEntityMap!(SoftwareSystem) softwareSystems;
	StringEntityMap!(HardwareSystem) hardwareSystems;
	StringEntityMap!(Connection) connections;

	T getSubEntity(T)(string uri) {
		const(string[]) uriSplit = split(uri, ".");

		auto toIterate = [this.actors, this.softwareSystems,
			 this.hardwareSystems, this.connections
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
}

class Connection : Entity {
	Entity from;
	Entity two;
}

class HardwareSystem : Entity {
}

class SoftwareSystem : Entity {
	StringEntityMap!(Container) container;

	override Entity getSubEntity(const(string[]) uri) {
		return getSubEntityImpl(this.container, uri);
	}
}

class Container : Entity {
	StringEntityMap!(Component) components;

	override Entity getSubEntity(const(string[]) uri) {
		return getSubEntityImpl(this.components, uri);
	}
}

class Component : Entity {
	StringEntityMap!(Class) classes;

	override Entity getSubEntity(const(string[]) uri) {
		return getSubEntityImpl(this.classes, uri);
	}
}

class Class : Entity {
	StringEntityMap!(Member) members;

	override Entity getSubEntity(const(string[]) uri) {
		return getSubEntityImpl(this.members, uri);
	}
}

class Member : Entity {
}

class MemberVariable : Member {
}

class MemberFunction : Member {
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
