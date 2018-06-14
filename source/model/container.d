module model.container;

import model.entity;

class Container : Entity {
	import std.array : empty, front;
	import model.classes;
	import model.component;
	import model.world : SearchResult, TheWorld;
	import exceptionhandling;

	string technology;
	StringEntityMap!(Component) components;
	StringEntityMap!(Class) classes;
	StringEntityMap!(Enum) enums;

	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in Container old, in Entity parent, TheWorld world) {
		super(old, parent);
		this.technology = old.technology;
		foreach(const(string) name, const(Component) com; old.components) {
			assert(name == com.name);
			this.components[name] = new Component(com, this, world);
		}

		foreach(const(string) name, const(Class) cls; old.classes) {
			assert(name == cls.name);
			auto nCls = world.getClass(name);
			ensure(cls !is null, "While copying ", this.name, "class ", name,
				"could not be found as type in TheWorld"
			);

			nCls.parents ~= this;
			this.classes[name] = nCls;
		}

		foreach(const(string) name, const(Enum) en; old.enums){
		    assert(en.name == name);
		    auto newEnum = world.getEnum(name);
		    ensure(en !is null, "While copying ", this.name, " enum " , name, " could not be found.");
		    newEnum.parents ~= this;
		    this.enums[name] = newEnum;
		}
		assert(!this.name.empty);
	}

	CopyConstness!(T,Component) getComponent(this T)(in string name) {
		if(name in this.components) {
			return cast(CopyConstness!(T,Component))this.containters[name];
		} else {
			throw new Exception("Component \"" ~ name ~ "\" does not exists");
		}
	}

	Component newComponent(in string name) {
		import std.format : format;
		if(name in this.components) {
			throw new Exception(format("Component '%s' already exists", name));
		} else {
			auto ret = new Component(name, this);
			this.components[name] = ret;
			return ret;
		}
	}

	SearchResult holdsEntity(const Entity needle) const {
		const(Entity) tmp = holdsEntityImpl(needle, this.components, this.classes, this.enums);
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

	override const(Entity) get(string[] path) const {
		return this.getImpl(path);
	}

	override Entity get(string[] path) {
		return cast(Entity)this.getImpl(path);
	}

    /**
     * Searches for the entity specified by the path down the path tree recursively.
     * @param path The path for the entity to be found
     */
	const(Entity) getImpl(string[] path) const {
		if(path.empty) {
			return this;
		} else {
			immutable fr = path.front;
			path = path[1 .. $];

			foreach(const(string) name, const(Component) com; this.components) {
				if(name == fr) {
					return com.get(path);
				}
			}

			foreach(const(string) name, const(Class) cls; this.classes) {
				if(name == fr) {
					return cls.get(path);
				}
			}
            foreach(const(string) name, const(Enum) en; this.enums){
                if(name == fr){
                    return en.get(path);
                }
            }
			if(this.components.empty && this.classes.empty) {
				return this;
			} else {
				return null;
			}
		}
	}

    /**
     * Recursively drops all children of this container.
     * Therefore this container is removed from the classes as a parent and the reference from this container to the classes is deleted.
     * Also the references to all components contained by this container are deleted.
     * On these components the drop method is called.
     */
	void drop() {
		import std.experimental.logger;

		foreach(const(string) it, Component con; this.components) {
			con.drop();
		}

		foreach(it; this.components.keys()) {
			this.components.remove(it);
		}

		foreach(const(string) it, Class con; this.classes) {
			con.removeParent(this);
		}

		foreach(it; this.classes.keys()) {
			this.classes.remove(it);
		}

        foreach(const(string)enumName, Enum enumInstance; this.enums){
            enumInstance.removeParent(this);
        }

		foreach(it; this.enums.keys()){
		    this.enums.remove(it);
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
