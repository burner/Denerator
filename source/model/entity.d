module model.entity;

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

class Entity {
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

	this(in Entity old, in Entity parent) {
		this.name = old.name;
		this.parent = parent;
		this.description = old.description;
		this.longDescription = old.longDescription;
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

	const(Entity) areYouIn(ref in EntityHashSet!(Entity) store) const {
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

	final auto getRoot() inout {
		assert(this.parent !is null);
		if(this.parent.parent is null) {
			return this;
		} else {
			return this.parent.getRoot();
		}
	}

	Entity get(string[] path) {
		return this;
	}
}

// e.g. [D] = "protected"
class ProtectedEntity : Entity {
	HashMap!(string,string) protection;

	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in ProtectedEntity old, in Entity parent) {
		super(old, parent);
		foreach(const(string) key, const(string) value; old.protection) {
			this.protection[key] = value;
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
