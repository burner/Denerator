module model.classes;

import std.exception : enforce;
import std.experimental.logger;

import containers.dynamicarray;

import model.entity : getOrNewEntityImpl, Entity, ProtectedEntity, 
	   toStringIndent;
import model.type : Type, TypeModifier;
import model.world : TheWorld;

class Class : ProtectedEntity {
	import std.array : empty, front;
	import model.entity : Entity, EntityHashSet, StringEntityMap, StringHashSet;
	import model.type : Type;

	StringEntityMap!(Member) members;
	StringEntityMap!(string) containerType;

	Entity[] parents;

	this(in string name) {
		super(name, null);
	}

	~this() {
		assert(false);
	}

	this(in Class old, in Entity parent, TheWorld world) {
		super(old, null);	
		// we need to fix up the parents in a second
		// pass after we have copied TheWorld

		foreach(const(string) key, const(Member) value; old.members) {
			if(auto mf = cast(const MemberFunction)value) {
				this.members[key] = new MemberFunction(mf, this, world);
			} else if(auto mv = cast(const MemberVariable)value) {
				this.members[key] = new MemberVariable(mv, this, world);
			} else {
				assert(false);
			}
		}

		foreach(const(string) key, const(string) value; old.containerType) {
			this.containerType[key] = value;
		}

		assert(!this.name.empty);
	}

	void removeParent(Entity par) {
		import std.algorithm.mutation : remove;
		import std.algorithm.searching : countUntil;
		import std.experimental.logger;

		int getParentIndex(Entity par) {
			foreach(int idx, it; this.parents) {
				if(it is par) {
					return idx;
				}	
			}
			return -1;
		}

		auto idx = getParentIndex(par);

		if(idx != -1) {
			logf("%s %s %s", this.name, par.name, this.parents);
			this.parents = remove(this.parents, idx);
			logf("%s", this.parents);
		} else {
			logf("!%s %s %s", this.name, par.name, this.parents);
		}
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

	void toString(in int indent) const {
		import std.stdio : writefln;
		toStringIndent(indent);
		writefln("Class %s %x", this.name, cast(ulong)cast(void*)this);
		foreach(par; this.parents) {
			toStringIndent(indent + 1);
			writefln("Parent %s %x", par.name, cast(ulong)cast(void*)par);
		}
	}
}

class Member : ProtectedEntity {
	string[][string] langSpecificAttributes;
	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in Member old, in Entity parent) {
		super(old, parent);

		foreach(const(string) key, const(string) value; old.protection) {
			this.protection[key] = value;
		}

		foreach(key, value; old.langSpecificAttributes) {
			this.langSpecificAttributes[key] = value.dup;
		}
	}

	void addLangSpecificAttribute(string lang, string value) {
		this.langSpecificAttributes[lang] ~= value;
	}
}

class MemberVariable : Member {
	Type type;
	TypeModifier typeMod;

	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in MemberVariable old, in Entity parent, TheWorld world) {
		super(old, parent);

		foreach(const(string) key, const(string) value; old.protection) {
			this.protection[key] = value;
		}

		if(old.type) {
			this.type = world.getType(old.type.name);
		}

		if(old.typeMod) {
			this.typeMod = new TypeModifier(old.typeMod, world);
		}
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
	TypeModifier returntypeMod;

	DynamicArray!MemberVariable parameter;

	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in MemberFunction old, in Entity parent, TheWorld world) {
		super(old, parent);

		foreach(const(string) key, const(string) value; old.protection) {
			this.protection[key] = value;
		}

		if(old.returnType) {
			this.returnType = world.getType(old.returnType.name);
		}

		if(old.returntypeMod) {
			this.returntypeMod = new TypeModifier(old.returntypeMod, world);
		}

		foreach(const(MemberVariable) value; old.parameter) {
			this.parameter.insert(new MemberVariable(value, this, world));
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
			cls.parents ~= it;
		}
	}
	return cls;
}

string[] pathToRoot(in Entity en) {
	import std.array : empty;
	if(auto c = cast(const(Class))en) {
		string[] paths = c.pathsToRoot();
		assert(!paths.empty);
		return paths;
	} else {
		return [en.pathToRoot()];
	}
}
