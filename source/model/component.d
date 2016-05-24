module model.component;

//import model.entity : Entity, ProtectedEntity;
import model.entity;
import model.classes;
import model.world : SearchResult;

class Component : ProtectedEntity {
	import std.array : empty, front;
	import model.entity : StringEntityMap;

	StringEntityMap!(Class) classes;
	Component[string] subComponents;
	
	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in Component old, in Entity parent) {
		super(old, parent);

		foreach(const(string) key, const(Class) value; old.classes) {
			this.classes[key] = new Class(value, this);
		}

		foreach(string key, const(Component) value; old.subComponents) {
			this.subComponents[key] = new Component(value, this);
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
			log(key);
			value.drop();
		}

		foreach(it; this.subComponents.keys()) {
			this.subComponents.remove(it);
		}

		foreach(const(string) it, Class con; this.classes) {
			logf("\t%s %s", super.name, it);
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

			return this;
		}
	}

	override string toString() const {
		return this.name;
	}
}
