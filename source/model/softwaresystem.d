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
	import model.entity : empty;
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

	CopyConstness!(T,Container) getContainer(this T)(in string name) {
		if(name in this.containers) {
			return cast(CopyConstness!(T,Container))this.containters[name];
		} else {
			throw new Exception("Container \"" ~ name ~ "\" does not exists");
		}
	}

	Container newContainer(in string name) {
		import std.format : format;
		if(name in this.containers) {
			throw new Exception(format("Container '%s' already exists", name));
		} else {
			auto ret = new Container(name, this);
			this.containers[name] = ret;
			return ret;
		}
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
