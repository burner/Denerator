module model.softwaresystem;

import model.entity : Entity;

class SoftwareSystem : Entity {
	import model.entity : StringEntityMap;
	import model.container : Container;
	import model.world : SearchResult;

	StringEntityMap!(Container) containers;
	
	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in SoftwareSystem old, in Entity parent) {
		super(old, parent);
		foreach(const(string) name, const(Container) con; old.containers) {
			this.containers[name] = new Container(con, this);
		}
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

	override Entity get(string[] path) {
		if(path.empty) {
			return this;
		} else {
			immutable fr = path.front;
			path = path[1 .. $];

			foreach(const(string) name, Container con; this.containers) {
				if(name == fr) {
					return con.get(path);
				}
			}

			return this;
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
}
