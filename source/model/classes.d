module model.classes;

import std.exception : enforce;
import std.experimental.logger;

import containers.dynamicarray;

import model.entity : getOrNewEntityImpl, Entity, ProtectedEntity, 
	   toStringIndent;
import model.type : Type;
import model.world : TheWorld;

class Class : Type {
	import std.array : empty, front;
	import model.entity : Entity, EntityHashSet, StringEntityMap, StringHashSet;
	import model.type : Type;

	Member[] members;
	StringEntityMap!(string) containerType;

	Entity[] parents;

	this(in string name) {
		super(name, null);
	}

	// Dummy Copy Constructor member are copied in a second step
	this(in Class old, in Entity) {
		super(name, null);
	}

	~this() {
		assert(false);
	}

	void realCCtor(in Class old, TheWorld newWorld) {
		foreach(const(Member) value; old.members) {
			if(auto mf = cast(const MemberFunction)value) {
				this.members ~= new MemberFunction(mf, this, newWorld);
			} else if(auto mv = cast(const MemberVariable)value) {
				this.members ~= new MemberVariable(mv, this, newWorld);
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
			this.parents = remove(this.parents, idx);
		} else {
			logf("!%s %s %s", this.name, par.name, this.parents);
		}
	}

	S getOrNew(S)(in string name) {
		import std.array : back;
		//return enforce(getOrNewEntityImpl!(Member,S)(name, this.members, this));
		foreach(mem; this.members) {
			if(name == mem.name) {
				return cast(S)mem;
			}
		}

		this.members ~= new S(name, this);
		return cast(S)this.members.back();
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

			foreach(Member mem; this.members) {
				if(mem.name == fr) {
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

	override string typeToLang(string lang) const {
		return this.name;
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

	MemberVariable addParameter(in string name, Type type) {
		auto np = new MemberVariable(name, this);
		np.type = type;
		this.parameter.insert(np);
		return np;
	}
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
