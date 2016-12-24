module model.world;

import model.entity : getOrNewEntityImpl, holdsEntityImpl, Entity, EntityHashSet, 
	   StringEntityMap, StringHashSet;

struct SearchResult {
	const(Entity) entity;
	string[] path;
}

class TheWorld : Entity {
	import std.array : empty, front;
	import std.exception : enforce;
	import std.format : format;
	import model.container : Container;
	import model.world : SearchResult;
	import model.actor : Actor;
	import model.classes : Class;
	import model.softwaresystem : SoftwareSystem;
	import model.hardwaresystem : HardwareSystem;
	import model.type : Type;
	import model.connections;
	import util;
	import exceptionhandling;

	StringEntityMap!(Actor) actors;
	StringEntityMap!(SoftwareSystem) softwareSystems;
	StringEntityMap!(HardwareSystem) hardwareSystems;
	StringEntityMap!(Type) typeContainerMapping;
	StringEntityMap!(Entity) connections;

	this(in string name) {
		super(name, null);
	}

	this(in TheWorld old) {
		super(old, null);
		foreach(const(string) name, const(Type) t; old.typeContainerMapping) {
			if(auto c = cast(const(Class))t) {
				this.typeContainerMapping[name] = new Class(name);
			} else {
				this.typeContainerMapping[name] = new Type(t, this);
			}
		}

		foreach(const(string) name, const(Actor) act; old.actors) {
			this.actors[name] = new Actor(act, this);
		}

		foreach(const(string) name, const(SoftwareSystem) ss; old.softwareSystems) {
			this.softwareSystems[name] = new SoftwareSystem(ss, this, this);
		}

		foreach(const(string) name, const(HardwareSystem) hw; old.hardwareSystems) {
			this.hardwareSystems[name] = new HardwareSystem(hw, this);
		}
	}

	override const(Entity) get(string[] path) const {
		return this.getImpl(path);
	}

	override Entity get(string[] path) {
		return cast(Entity)this.getImpl(path);
	}

	const(Entity) getImpl(string[] path) const {
		if(path.empty) {
			return this;
		} else {
			immutable fr = path.front;
			path = path[1 .. $];

			foreach(const(string) name, const(Actor) act; this.actors) {
				if(name == fr) {
					return act.get(path);
				}
			}

			foreach(const(string) name, const(SoftwareSystem) ss; this.softwareSystems) {
				if(name == fr) {
					return ss.get(path);
				}
			}

			foreach(const(string) name, const(HardwareSystem) hw; this.hardwareSystems) {
				if(name == fr) {
					return hw.get(path);
				}
			}

			return null;
		}
	}

	auto search(const(Entity) needle) inout {
		assert(needle !is null);

		const(Entity) mnp = holdsEntityImpl(needle, this.actors,
					this.softwareSystems, this.hardwareSystems,
					this.typeContainerMapping, this.connections);

		if(mnp !is null) {
			return SearchResult(mnp, [super.name]);
		}

		const(SearchResult) dummy;
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

	T getOrNew(T,F,O)(in string name, F from, O to) {
		T con =  enforce(getOrNewEntityImpl!(Entity,T)(
			name, this.connections, this
		));
		con.from = from;
		con.to = to;
		return con;
	}

	T getOrNew(T,F,O)(T toCopy, F from, O to) {
		T con =  enforce(getOrNewEntityImpl!(Entity,T)(
			toCopy.name, this.connections, this
		));
		con.from = from;
		con.to = to;
		con.description = toCopy.description;
		con.longDescription = toCopy.longDescription;

		static if(is(T == Aggregation)) {
			con.fromCnt = toCopy.fromCnt;
			con.toCnt = toCopy.toCnt;
			//con.fromType = toCopy.fromType;
			//con.toStore = toCopy.toStore;
		} else static if(is(T == Composition)) {
			con.fromCnt = toCopy.fromCnt;
			con.fromType = toCopy.fromType;
		}
		return con;
	}

	Type newType(in string name) {
		if(name in this.typeContainerMapping) {
			throw new Exception(format("Type '%s' already exists", name));
		} else {
			Type ret = new Type(name, null);
			this.typeContainerMapping[name] = ret;
			return ret;
		}
	}

	T getType(T = Type)(in string name) {
		if(name in this.typeContainerMapping 
				&& cast(T)(this.typeContainerMapping[name]) !is null) 
		{
			return cast(T)this.typeContainerMapping[name];
		} else {
			throw new Exception("Type \"" ~ name ~ "\" does not exists");
		}
	}

	const(T) getType(T = Type)(in string name) const {
		if(name in this.typeContainerMapping 
				&& cast(const(T))(this.typeContainerMapping[name]) !is null) 
		{
			return cast(const(T))this.typeContainerMapping[name];
		} else {
			throw new Exception("Type \"" ~ name ~ "\" does not exists");
		}
	}

	/** Gets a class from one of the containers and adds them to all other
	containers. If the Class can't be find by its name it is created and added
	to all containers.
	*/
	Class getOrNewClass(T...)(in string name, T stuffThatHoldsClasses) {
		import std.experimental.logger;
		Class ret;
		if(name in this.typeContainerMapping) {
			ret = cast(Class)this.typeContainerMapping[name];
		} else {
			this.typeContainerMapping[name] = new Class(name);
			ret = cast(Class)this.typeContainerMapping[name];
		}

		foreach(it; stuffThatHoldsClasses) {
			if(name !in it.classes) {
				it.classes[name] = ret;
				ret.parents ~= it;
			} else {
				ensure(false, "Class ", name, "is already in ", it, ".");	
			}
		}
		return ret;
	}

	override string areYouIn(ref in StringHashSet store) const {
		return super.name in store ? super.name : "";
	}

	override const(Entity) areYouIn(ref in EntityHashSet!(Entity) store) 
			const 
	{
		if(cast(Entity)(this) in store) {
			return this;
		} else {
			return null;
		}
	}

	Entity get(string path) {
		import std.array : array;
		import std.algorithm.iteration : splitter;
		string[] spath = splitter(path, ".").array;
		return this.get(spath);
	}

	void drop(in ref StringHashSet toKeep) {
		auto keys = this.softwareSystems.keys();
		foreach(key; keys) {
			if(key !in toKeep) {
				this.softwareSystems[key].drop();
				this.softwareSystems.remove(key);
			}
		}
		keys = this.actors.keys();
		foreach(key; keys) {
			if(key !in toKeep) {
				this.actors.remove(key);
			}
		}
		keys = this.hardwareSystems.keys();
		foreach(key; keys) {
			if(key !in toKeep) {
				this.hardwareSystems.remove(key);
			}
		}
	}
}
