module model.classes;

import std.exception : enforce;

import containers.dynamicarray;

import model.entity : getOrNewEntityImpl, Entity, ProtectedEntity;
import model.type : Type;

class Class : ProtectedEntity {
	import std.array : empty, front;
	import model.entity : Entity, EntityHashSet, StringEntityMap, StringHashSet;
	import model.type : Type;

	StringEntityMap!(Member) members;
	StringEntityMap!(string) containerType;

	DynamicArray!(Entity) parents;

	this(in string name) {
		super(name, null);
	}

	this(in Class old, in Entity parent) {
		super(old, null);	// TODO we need to fix up the parents in a second
		// pass after we have copied TheWorld
		this.parents.insert(cast(Entity)parent);

		foreach(const(string) key, const(Member) value; old.members) {
			if(auto mf = cast(const MemberFunction)value) {
				this.members[key] = new MemberFunction(mf, this);
			} else if(auto mv = cast(const MemberVariable)value) {
				this.members[key] = new MemberVariable(mv, this);
			} else {
				assert(false);
			}
		}

		foreach(const(string) key, const(string) value; old.containerType) {
			this.containerType[key] = value;
		}

		assert(!this.name.empty);
	}

	S getOrNew(S)(in string name) {
		return enforce(getOrNewEntityImpl!(Member,S)(name, this.members, this));
	}

	override string areYouIn(ref in StringHashSet store) const {
		if(this.name in store) {
			return this.name;
		} else if(this.parents.empty) {
			return "";
		} else {
			foreach(it; this.parents) {
				auto tmp = it.areYouIn(store);
				if(!tmp.empty) {
					return tmp;
				}
			}
			return "";
		}
	}

	override const(Entity) areYouIn(ref in EntityHashSet!(Entity) store) const {
		if(store.contains(cast(Entity)(this))) {
			return this;
		} else if(this.parents.empty) {
			return null;
		} else {
			foreach(it; this.parents) {
				auto tmp = it.areYouIn(store);
				if(tmp !is null) {
					return tmp;
				}
			}

			return null;
		}
	}

	override Entity get(string[] path) {
		if(path.empty) {
			return this;
		} else {
			immutable fr = path.front;
			path = path[1 .. $];

			foreach(const(string) name, Member mem; this.members) {
				if(name == fr) {
					return mem.get(path);
				}
			}

			return this;
		}
	}

	override string pathToRoot() const {
		throw new Exception("Class can have multiple paths to root");
	}

	string[] pathsToRoot() const {
		string[] ret;
		foreach(const(Entity) par; this.parents[]) {
			ret ~= (par.pathToRoot() ~ "." ~ this.name);
		}

		return ret;
	}
}

class MemberModifier : Entity {
	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in MemberModifier old, in Entity parent) {
		super(old, parent);
	}
}

class Member : ProtectedEntity {
	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in Member old, in Entity parent) {
		super(old, parent);

		foreach(const(string) key, const(string) value; old.protection) {
			this.protection[key] = value;
		}
	}
}

class MemberVariable : Member {
	Type type;
	string[][string] langSpecificAttributes;

	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in MemberVariable old, in Entity parent) {
		super(old, parent);

		foreach(const(string) key, const(string) value; old.protection) {
			this.protection[key] = value;
		}

		this.type = new Type(old.type, this);

		foreach(key, value; old.langSpecificAttributes) {
			this.langSpecificAttributes[key] = value.dup;
		}
	}

	void addLangSpecificAttribute(string lang, string value) {
		this.langSpecificAttributes[lang] ~= value;
	}
}

unittest {
	auto mv = new MemberVariable("name", null);
	mv.addLangSpecificAttribute("Foo", "Bar");

	assert(mv.langSpecificAttributes["Foo"].length == 1);
	assert(mv.langSpecificAttributes["Foo"] == ["Bar"]);
}

class MemberFunction : Member {
	Type returnType;
	DynamicArray!MemberVariable parameter;
	DynamicArray!MemberModifier modifier;

	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in MemberFunction old, in Entity parent) {
		super(old, parent);

		foreach(const(string) key, const(string) value; old.protection) {
			this.protection[key] = value;
		}

		this.returnType = new Type(old.returnType, this);

		foreach(const(MemberVariable) value; old.parameter) {
			this.parameter.insert(new MemberVariable(value, this));
		}

		foreach(const(MemberModifier) value; old.modifier) {
			this.modifier.insert(new MemberModifier(value, this));
		}
	}

	T getOrNew(T)(in string name) {
		static if(is(T == MemberVariable)) {
			return enforce(getOrNewEntityImpl!MemberVariable(name,
				this.parameter, this)
			);
		} else static if(is(T == MemberFunction)) {
			return enforce(getOrNewEntityImpl!MemberFunction(name,
				this.modifer, this)
			);
		}
	}
}

/** Gets a class from one of the containers and adds them to all other
containers. If the Class can't be find by its name it is created and added
to all containers.
*/
Class getOrNewClass(T...)(in string name, T stuffThatHoldsClasses) {
	Class cls;
	foreach(it; stuffThatHoldsClasses) {
		if(name in it.classes) {
			cls = it.classes[name];
			break;
		}
	}

	if(cls is null) {
		cls = new Class(name);
	}

	foreach(it; stuffThatHoldsClasses) {
		if(name !in it.classes) {
			it.classes[name] = cls;
			cls.parents.insert(it);
		}
	}
	return cls;
}

