module model.container;

class Container : Entity {
	string technology;
	StringEntityMap!(Component) components;
	StringEntityMap!(Class) classes;
	
	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in Container old, in Entity parent) {
		super(old, parent);
		this.technology = old.technology;
		foreach(const(string) name, const(Component) com; old.components) {
			this.components[name] = new Component(com, this);
		}

		foreach(const(string) name, const(Class) cls; old.classes) {
			this.classes[name] = new Class(cls, this);
		}

		assert(!this.name.empty);
	}

	Component getOrNewComponent(in string name) {
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

			return this;
		}
	}

	void drop(in ref StringHashSet toKeep) {
		auto keys = this.components.keys();
		foreach(key; keys) {
			if(key !in toKeep) {
				this.components.remove(key);
			}
		}

		keys = this.classes.keys();
		foreach(key; keys) {
			if(key !in toKeep) {
				this.classes.remove(key);
			}
		}
	}
}
