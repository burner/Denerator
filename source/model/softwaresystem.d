module model.softwaresystem;

//import model.entity : Entity;
import model.entity;

private const(Entity) holdsEntitySingleImpl(T)(const Entity needle, ref T arg) {
	foreach(key; arg.keys()) {
		auto entity = arg[key];
		if(needle is entity) {
			return entity;
		}
	}

	return null;
}

class SoftwareSystem : Entity {
	import std.array : empty, front;
	import model.container : Container;
	import model.world : SearchResult, TheWorld;

	StringEntityMap!(Container) containers;
	
	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in SoftwareSystem old, in Entity parent, TheWorld world) {
		super(old, parent);
		foreach(const(string) name, const(Container) con; old.containers) {
			this.containers[name] = new Container(con, this, world);
		}
	}

	Container getOrNewContainer(in string name) {
		import std.exception : enforce;
		return enforce(getOrNewEntityImpl!Container(name, this.containers,
			this)
		);
	}

	void drop() {
		foreach(const(string) it, Container con; this.containers) {
			con.drop();
		}

		foreach(it; this.containers.keys()) {
			this.containers.remove(it);
		}
	}

	SearchResult holdsEntity(const Entity needle) const {
		const Entity tmp = holdsEntitySingleImpl(needle, this.containers);
		if(tmp !is null) {
			return SearchResult(tmp, [super.name]);	
		} else {
			foreach(const(string) it, const(Container) con; this.containers) {
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

			foreach(const(string) name, const(Container) con; this.containers) {
				if(name == fr) {
					return con.get(path);
				}
			}

			if(this.containers.empty) {
				return this;
			} else {
				return null;
			}
		}
	}

	void drop(in ref StringHashSet toKeep) {
		auto keys = this.containers.keys();
		foreach(key; keys) {
			if(key !in toKeep) {
				this.containers.remove(key);
			}
		}
	}

	void toString(in int indent) const {
		import std.stdio : writefln;
		toStringIndent(indent);
		writefln("SoftwareSystem %s %x", this.name, cast(ulong)cast(void*)this);

		foreach(const(string) it, const(Container) con; this.containers) {
			con.toString(indent + 1);
		}
	}
}
