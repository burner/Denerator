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
	import std.traits : CopyConstness;
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

	this(const(string) name) {
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

			foreach(const(string) name, const(SoftwareSystem) ss; 
					this.softwareSystems) 
			{
				if(name == fr) {
					return ss.get(path);
				}
			}

			foreach(const(string) name, const(HardwareSystem) hw; 
					this.hardwareSystems) 
			{
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

	CopyConstness!(T,Actor) getActor(this T)(const(string) name) {
		if(name in this.actors) {
			return this.actors[name];
		} else {
			throw new Exception("Actor \"" ~ name ~ "\" does not exists");
		}
	}

	Actor newActor(const(string) name) {
		if(name in this.actors) {
			throw new Exception(format("Actor '%s' already exists", name));
		} else {
			Actor ret = new Actor(name, this);
			this.actors[name] = ret;
			return ret;
		}
	}

	CopyConstness!(T,SoftwareSystem) getSoftwareSystem(this T)(const(string) name) {
		if(name in this.softwareSystems) {
			return this.softwareSystems[name];
		} else {
			throw new Exception("SoftwareSystem \"" ~ name ~ "\" does not exists");
		}
	}

	SoftwareSystem newSoftwareSystem(const(string) name) {
		if(name in this.softwareSystems) {
			throw new Exception(format("SoftwareSystem '%s' already exists", name));
		} else {
			SoftwareSystem ret = new SoftwareSystem(name, this);
			this.softwareSystems[name] = ret;
			return ret;
		}
	}

	CopyConstness!(T,HardwareSystem) getHardwareSystem(this T)(const(string) name) {
		if(name in this.hardwareSystems) {
			return this.hardwareSystems[name];
		} else {
			throw new Exception("HardwareSystem \"" ~ name ~ "\" does not exists");
		}
	}

	HardwareSystem newHardwareSystem(const(string) name) {
		if(name in this.hardwareSystems) {
			throw new Exception(format("HardwareSystem '%s' already exists", name));
		} else {
			HardwareSystem ret = new HardwareSystem(name, this);
			this.hardwareSystems[name] = ret;
			return ret;
		}
	}

	Realization newRealization(F,O)(const(string) name, F from, O to) {
		return this.newConnectionImpl!Realization(name, from, to);
	}

	Generalization newGeneralization(F,O)(const(string) name, F from, O to) {
		return this.newConnectionImpl!Generalization(name, from, to);
	}

	Composition newComposition(F,O)(const(string) name, F from, O to) {
		return this.newConnectionImpl!Composition(name, from, to);
	}

	Aggregation newAggregation(F,O)(const(string) name, F from, O to) {
		return this.newConnectionImpl!Aggregation(name, from, to);
	}

	Connection newConnection(F,O)(const(string) name, F from, O to) {
		return this.newConnectionImpl!Connection(name, from, to);
	}
	
	Dependency newDependency(F,O)(const(string) name, F from, O to) {
		return this.newConnectionImpl!Dependency(name, from, to);
	}

	ConnectionImpl newConnectionImpl(F,O)(const(string) name, F from, O to) {
		return this.newConnectionImpl!ConnectionImpl(name, from, to);
	}

	CopyConstness!(T,Realization) getRealization(this T)(const(string) name) {
		return this.getConnectionImpl!Realization(name);
	}

	CopyConstness!(T,Generalization) getGeneralization(this T)(const(string) name) {
		return this.getConnectionImpl!Generalization(name);
	}

	CopyConstness!(T,Composition) getComposition(this T)(const(string) name) {
		return this.getConnectionImpl!Composition(name);
	}

	CopyConstness!(T,Aggregation) getAggregation(this T)(const(string) name) {
		return this.getConnectionImpl!Aggregation(name);
	}

	CopyConstness!(T,Connection) getConnection(this T)(const(string) name) {
		return this.getConnectionImpl!Connection(name);
	}
	
	CopyConstness!(T,Dependency) getDependency(this T)(const(string) name) {
		return this.getConnectionImpl!Dependency(name);
	}

	CopyConstness!(T,ConnectionImpl) getConnectionImpl(this T)(const(string) name) {
		return this.getConnectionImpl!ConnectionImpl(name);
	}

	T newConnectionImpl(T,F,O)(const(string) name, F from, O to) {
		if(name in this.connections) {
			throw new Exception(format("%s with name \"%s\" already exists",
				T.stringof, name
			));
		}
		
		T ret = new T(name, this);
		this.connections[name] = ret;
		ret.from = from;
		ret.to = to;
		return ret;
	}

	CopyConstness!(F,T) getConnectionImpl(T, this F)(const(string) name) {
		if(name !in this.connections 
				|| (cast(typeof(return))this.connections[name]) is null) 
		{
			throw new Exception(format("%s with name \"%s\" does not exists",
				T.stringof, name
			));
		}
		
		return cast(typeof(return))this.connections[name];
	}

	T copy(T,F,O)(T toCopy, F from, O to) {
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

	Type newType(const(string) name) {
		if(name in this.typeContainerMapping) {
			throw new Exception(format("Type '%s' already exists", name));
		} else {
			Type ret = new Type(name, null);
			this.typeContainerMapping[name] = ret;
			return ret;
		}
	}

	CopyConstness!(T,S) getType(S = Type,this T)(const(string) name) {
		if(name in this.typeContainerMapping) {
			return cast(CopyConstness!(T,S))this.typeContainerMapping[name];
		} else {
			throw new Exception("Type \"" ~ name ~ "\" does not exists");
		}
	}

	/** Gets a class from one of the containers and adds them to all other
	containers. If the Class can't be find by its name it is created and added
	to all containers.
	*/
	Class newClass(T...)(const(string) name, T stuffThatHoldsClasses) {
		Class ret;
		if(name in this.typeContainerMapping) {
			throw new Exception(format("Class '%s' already exists", name));
		} else {
			this.typeContainerMapping[name] = new Class(name);
			ret = cast(Class)this.typeContainerMapping[name];
		}

		foreach(it; stuffThatHoldsClasses) {
			ensure(it !is null, "Container to hold ", name, " was null");
			if(name !in it.classes) {
				it.classes[name] = ret;
				ret.parents ~= it;
			} else {
				ensure(false, "Class ", name, "is already in ", it, ".");	
			}
		}
		return ret;
	}

	CopyConstness!(T,Class) getClass(this T)(const(string) name) {
		if(name in this.typeContainerMapping) {
			return cast(Class)this.typeContainerMapping[name];
		} else {
			throw new Exception(format("Class '%s' does not exists", name));
		}
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

unittest {
	auto w = new TheWorld("The World");
	auto ss = w.newSoftwareSystem("SS");
	assert(w.getSoftwareSystem("SS") !is null);
	auto c1 = ss.newContainer("C1");
	auto c2 = ss.newContainer("C2");
}
