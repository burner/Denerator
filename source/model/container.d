module model.container;

import model.entity;

class Container : Entity {
	import std.array : empty, front;
	import model.classes;
	import model.component;
	import model.world : SearchResult, TheWorld;

	string technology;
	StringEntityMap!(Component) components;
	StringEntityMap!(Class) classes;

	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in Container old, in Entity parent, TheWorld world) {
		super(old, parent);
		this.technology = old.technology;
		foreach(const(string) name, const(Component) com; old.components) {
			this.components[name] = new Component(com, this, world);
		}

		foreach(const(string) name, const(Class) cls; old.classes) {
			this.classes[name] = new Class(cls, this, world);
		}

		assert(!this.name.empty);
	}

	Component getOrNewComponent(in string name) {
		import std.exception : enforce;
		return enforce(getOrNewEntityImpl!Component(name, this.components,
			this)
		);
	}

	SearchResult holdsEntity(const Entity needle) const {
		const(Entity) tmp = holdsEntityImpl(needle, this.components, this.classes);
		if(tmp !is null) {
			return SearchResult(tmp, [super.name]);
		} else {
			foreach(const(string) it, const(Component) com; this.components) {
				SearchResult ret = com.holdsEntity(needle);
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

			foreach(const(string) name, Component com; this.components) {
				if(name == fr) {
					return com.get(path);
				}
			}

			foreach(const(string) name, Class cls; this.classes) {
				if(name == fr) {
					return cls.get(path);
				}
			}

			if(this.components.empty && this.classes.empty) {
				return this;
			} else {
				return null;
			}
		}
	}

	void drop() {
		import std.experimental.logger;

		foreach(const(string) it, Component con; this.components) {
			log(it);
			con.drop();
		}

		foreach(it; this.components.keys()) {
			this.components.remove(it);
		}

		foreach(const(string) it, Class con; this.classes) {
			logf("\t%s %s", super.name, it);
			con.removeParent(this);
		}

		foreach(it; this.classes.keys()) {
			this.classes.remove(it);
		}
	}

	override string toString() const {
		return this.name;
	}

	void toString(in int indent) const {
		import std.stdio : writefln;
		toStringIndent(indent);
		writefln("Container %s %x", this.name, cast(ulong)cast(void*)this);
		foreach(const(string) it, const(Class) cls; this.classes) {
			cls.toString(indent + 1);
		}
		foreach(const(string) it, const(Component) com; this.components) {
			com.toString(indent + 1);
		}
	}
}
