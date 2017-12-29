module model.classes;

import std.typecons : Flag;
import std.exception : enforce;
import std.experimental.logger;

import containers.dynamicarray;

import model.entity : getOrNewEntityImpl, Entity, ProtectedEntity, 
	   toStringIndent;
import model.type : Type;
import model.world : TheWorld;

alias DoNotGenerate = Flag!"DoNotGenerate";

class Class : Type {
	import std.array : empty, front;
	import model.entity : Entity, EntityHashSet, StringEntityMap, StringHashSet;
	import model.type : Type;
	import std.format : format;

    //inner classes: Map(string) -> Class
    StringEntityMap!(Class) classes;

	Member[] members;

	//Technology as key, type as value e.g. containerType["Java"] = "interface"
	StringEntityMap!(string) containerType;

    //like abstract final etc in java
	string[][string] languageSpecificAttributes;

	Entity[] parents;

	DoNotGenerate doNotGenerate;

	this(in string name) {
		super(name, null);
	}

	// Dummy Copy Constructor member are copied in a second step
	this(in Class old, in Entity) {
		super(name, null);
	}

	~this() {
		//assert(false);
	}

    /**
     * For copying classes containing all of its members of an old world to a new world.
     * @param old The class within the old world to copy
     * @param newWorld The new world that the new class is inserted to.
     */
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

	MemberVariable newMemberVariable(in string name) {
		return this.newImpl!MemberVariable(name);
	}

	MemberFunction newMemberFunction(in string name) {
		return this.newImpl!MemberFunction(name);
	}

	CopyConstness!(T,Class) getMemberClass(this T)(in string name) const{
        foreach(key, value; this.classes){
            if(key == name){
                return value;
            }
        }
        throw new Exception(std.format.format("Inner class %s could not be found.", name));
	}

	Class addInnerClass(Class clazz){
	    this.classes[clazz.name] = clazz;
	    clazz.parents ~= this;
	    return clazz;
	}

	CopyConstness!(T,MemberVariable) getMemberVariable(this T)(in string name) {
		return this.get!MemberVariable(name);
	}

	CopyConstness!(T,MemberFunction) getMemberFunction(this T)(in string name) {
		return this.get!MemberFunction(name);
	}

    /**
     * Adds a new member to this.members and returns it.
     */
	S newImpl(S)(in string name) {
		import std.array : back;
		foreach(mem; this.members) {
			if(name == mem.name) {
				throw new Exception(format("%s with name \"%s\" already present",
					S.stringof, name));
			}
		}
		this.members ~= new S(name, this);
		return cast(S)this.members.back();
	}

    /**
     * Gets a member of this.members.
     */
	CopyConstness!(T,S) getImpl(S,this T)(in string name) {
	    // why is the class not returned?
		foreach(mem; this.members) {
		    //what happens here?
			if(name == mem.name && (cast(typeof(return))mem) !is null) {
				return cast(typeof(return))mem;
			}
		}
		throw new Exception(format("%s with name \"%s\" could not be found",
			S.stringof, name));
	}

    /**
     * Determines if this class or its parents (specified by their names) are present within store.
     * If so, the name of the entity is returned. Else an empty string is returned.
     */
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

			foreach(const(Member) mem; members) {
				if(mem.name == fr) {
					return mem.get(path);
				}
			}
            //TODO add support for inner classes / enums
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

class Enum : Type{
    import std.algorithm : remove;
    import std.array : empty, front;

    EnumConstant[] enumConstants;
    Constructor constructor;
    Entity[] parents;
    DoNotGenerate doNotGenerate;

    this(in const(string) name){
        super(name, null);
    }

    EnumConstant addEnumConstant(string name){
        import std.algorithm;
        import std.format;
        if(this.enumConstants.canFind!(enumConst => enumConst.name == name)){
            throw new Exception(format("EnumConstant %s has already been defined. ", name));
        } else {
            auto enumConstant = new EnumConstant(name, this);
            this.enumConstants ~= enumConstant;
            return enumConstant;
        }
    }

    Constructor setConstructor(){
        this.constructor = new Constructor(this.name, this);
        return this.constructor;
    }

    //TODO refactor this as a mixin
    void removeParent(Entity parent){
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

        auto idx = getParentIndex(parent);

        if(idx != -1) {
            this.parents = remove(this.parents, idx);
        } else {
            logf("!%s %s %s", this.name, parent.name, this.parents);
        }
    }

    override const(Entity) get(string[] path) const {
    		return this.getImpl(path);
    	}

    override Entity get(string[] path) {
    		return cast(Entity)this.getImpl(path);
    	}

    const(Entity) getImpl(string[] path) const {
        return this;
    }
}

/**
 * Defines a constant within an enum: E.g. in Java programming language this could be:
 *  enum Planet{
 *      MARS(12.38, 10.0) //EnumConstant
 *      ...
 *  }
 */
class EnumConstant : Entity{
    string[] values;

    this(in string name, in Entity parent){
        super(name, parent);
    }

    void setValues(string[] values){
        this.values = values;
    }
}

/**
 * Defines a constructor for an enum.
 */
class Constructor : Member{
    MemberVariable[] parameters;

    this(in string name, in Entity parent) {
        super(name, parent);
    }

    /**
     * Adds a parameter to this.parameters. Therefore it generates a new MemberVariable and sets its name, parent and type.
     * For further modifications of the parameter a reference to the generated parameter is returned.
     * @param name The name of the parameter
     * @param type The type of the parameter
     * @throws Exception if a parameter with the same name is already present
     * @return The newly created parameter
     */
    MemberVariable addParameter(string name, Type type){
        import std.algorithm;
        import std.format;
        if(this.parameters.canFind!(par => par.name == name)){
            throw new Exception(format("%s is already present in parameters", name));
        } else{
            MemberVariable parameter = new MemberVariable(name, this);
            parameter.type = type;
            this.parameters ~= parameter;
            return parameter;
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

	/*T getOrNew(T)(in string name) {
		static if(is(T == MemberVariable)) {
			return enforce(getOrNewEntityImpl!MemberVariable(name,
				this.parameter, this)
			);
		} else static if(is(T == MemberFunction)) {
			return enforce(getOrNewEntityImpl!MemberFunction(name,
				this.modifer, this)
			);
		}
	}*/

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

