module model.component;

//import model.entity : Entity, ProtectedEntity;
import model.entity;
import model.classes;

class Component : ProtectedEntity {
	import std.array : empty, front;
	import model.entity : StringEntityMap;
	import model.world : SearchResult, TheWorld;
	import util;

	StringEntityMap!(Class) classes;
	Component[string] subComponents;
	
	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in Component old, in Entity parent, TheWorld world) {
		super(old, parent);

		foreach(const(string) name, const(Class) value; old.classes) {
			auto cls = world.getOrNewClass(name);
			expect(cls !is null, "While copying ", this.name, "class ", name,
				"could not be found as type in TheWorld"
			);

			cls.parents ~= this;
			this.classes[name] = cls;
		}

		foreach(string key, const(Component) value; old.subComponents) {
			this.subComponents[key] = new Component(value, this, world);
		}
		assert(!this.name.empty);
	}

	Component getOrNewSubComponent(in string name) {
		if(name in this.subComponents) {
			return this.subComponents[name];
		} else {
			auto n = new Component(name, this);
			this.subComponents[name] = n;
			return n;
		}
	}

	SearchResult holdsEntity(const Entity needle) const {
		const Entity tmp = holdsEntityImpl(needle, this.classes,
				this.subComponents);
		if(tmp !is null) {
			return SearchResult(tmp, [super.name]);
		} else {
			foreach(const(string) it, const(Component) com; this.subComponents) {
				auto ret = com.holdsEntity(needle);
				if(ret.entity !is null) {
					ret.path ~= super.name;
					return ret;
				}
			}
		}

		SearchResult dummy;
		return dummy;
	}

	void drop() {
		import std.experimental.logger;

		foreach(string key, Component value; this.subComponents) {
			value.drop();
		}

		foreach(it; this.subComponents.keys()) {
			this.subComponents.remove(it);
		}

		foreach(const(string) it, Class con; this.classes) {
			con.removeParent(this);
		}

		foreach(it; this.classes.keys()) {
			this.classes.remove(it);
		}
	}

	override Entity get(string[] path) {
		if(path.empty) {
			return this;
		} else {
			immutable fr = path.front;
			path = path[1 .. $];

			foreach(const(string) name, Component com; this.subComponents) {
				if(name == fr) {
					return com.get(path);
				}
			}

			foreach(const(string) name, Class cls; this.classes) {
				if(name == fr) {
					return cls.get(path);
				}
			}

			if(this.subComponents.length == 0 && this.classes.empty) {
				return this;
			} else {
				return null;
			}
		}
	}

	override string toString() const {
		return this.name;
	}

	void toString(in int indent) const {
		import std.stdio : writefln;
		toStringIndent(indent);
		writefln("Component %s %x", this.name, cast(ulong)cast(void*)this);
		foreach(const(string) it, const(Class) cls; this.classes) {
			cls.toString(indent + 1);
		}
		foreach(const(string) it, const(Component) com; this.subComponents) {
			com.toString(indent + 1);
		}
	}
}
