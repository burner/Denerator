module duplicator;

import std.experimental.logger;
import model;

// Does only duplicate Nodes, no edges
TheWorld duplicateNodes(in TheWorld old) {
	auto ret = new TheWorld(old);
	StringEntityMap!Class classes;

	// there should one one instance per type name
	StringEntityMap!(Type[]) types;

	foreach(const(string) key, SoftwareSystem ss; ret.softwareSystems) {
		addClassesAndTypes(ss, classes, types);
	}

	foreach(const(string) key, Type[] value; types) {
		import std.array : front;
		logf("%s %s", key, value.length);
		if(value.length > 1) {
			Type frontType = value.front;
			foreach(it; value) {
				assert(it is frontType);
			}
		}
	}

	foreach(const(string) key, Class cls; classes) {
		cls.parents = [];
	}

	foreach(const(string) key, SoftwareSystem ss; ret.softwareSystems) {
		modClasses(ss, classes);
		//ss.toString(0);
	}

	EntityHashSet!Entity ehs;
	ehs.insert(ret);

	foreach(const(string) key, Class cls; classes) {
		logf("%s %s", key, cls.parents);
		assert(cls.areYouIn(ehs) is ret, cls.name);
	}

	return ret;
}

void reAdjustEdges(in TheWorld old, TheWorld ne) {
	foreach(const(string) key, const(Entity) en; old.connections) {
		const(ConnectionImpl) con = cast(ConnectionImpl)en;

		string[] fPath = pathToRoot(con.from);
		string[] tPath = pathToRoot(con.to);
		logf("%s %s", fPath, tPath);

		auto fEn = getFromSelection(ne, fPath);
		auto tEn = getFromSelection(ne, tPath);

		if(fEn is null) continue;
		if(tEn is null) continue;

		logf("%s\n\t%s %s\n\t%s %s", con.name, con.from.name, con.to.name,
			fEn.name, tEn.name
		);

		// no selfconnecting edges
		if(fEn is tEn) {
			continue;
		}

		logf("%s %s %s", con.name, fEn.name, tEn.name);

		if(auto c = cast(Realization)(con)) {
			ne.getOrNew!Realization(c, fEn, tEn);
		} else if(auto c = cast(Generalization)(con)) {
			ne.getOrNew!Generalization(c, fEn, tEn);
		} else if(auto c = cast(Composition)(con)) {
			ne.getOrNew!Composition(c, fEn, tEn);
		} else if(auto c = cast(Aggregation)(con)) {
			ne.getOrNew!Aggregation(c, fEn, tEn);
		} else if(auto c = cast(Connection)(con)) {
			ne.getOrNew!Connection(c, fEn, tEn);
		} else if(auto c = cast(Dependency)(con)) {
			ne.getOrNew!Dependency(c, fEn, tEn);
		} else if(auto c = cast(ConnectionImpl)(con)) {
			ne.getOrNew!ConnectionImpl(c, fEn, tEn);
		} else {
			assert(false);
		}
	}
}

private {
	void insertType(ref StringEntityMap!(Type[]) types, Type type) {
		if(type.name !in types) {
			types[type.name] = new Type[0];
		}
		Type[] old = types[type.name];
		old ~= type;
		types.remove(type.name);
		types[type.name] = old;
	}
	void addTypes(Class cls, ref StringEntityMap!(Type[]) types) {
		void addTypes(MemberFunction mf, ref StringEntityMap!(Type[]) types) {
			foreach(MemberVariable parm; mf.parameter) {
				if(parm.type) {
					insertType(types, parm.type);
				}
			}
		}

		foreach(const(string) mName, Member mem; cls.members) {
			if(auto mf = cast(MemberFunction)mem) {
				if(mf.returnType) {
					insertType(types, mf.returnType);
					addTypes(mf, types);
				}
			} else if(auto mv = cast(MemberVariable)mem) {
				if(mv.type) {
					insertType(types, mv.type);
				}
			} else {
				assert(false);
			}
		}

	}
	void addClassesAndTypes(SoftwareSystem ss, 
			ref StringEntityMap!Class classes, 
			ref StringEntityMap!(Type[]) types) 
	{
		void addClassesAndTypes(Container con, 
				ref StringEntityMap!Class classes, 
				ref StringEntityMap!(Type[]) types) 
		{
			void addClassesAndTypes(Component com, 
					ref StringEntityMap!Class classes, 
					ref StringEntityMap!(Type[]) types) 
			{
				foreach(const(string) key, Component scom; com.subComponents) {
					addClassesAndTypes(scom, classes, types);
				}

				foreach(const(string) key, Class cls; com.classes) {
					addTypes(cls, types);
					if(key !in classes) {
						classes[key] = cls;
					}
				}
			}

			foreach(const(string) key, Component com; con.components) {
				addClassesAndTypes(com, classes, types);
			}

			foreach(const(string) key, Class cls; con.classes) {
				addTypes(cls, types);
				if(key !in classes) {
					classes[key] = cls;
				}
			}
		}

		foreach(const(string) key, Container con; ss.containers) {
			addClassesAndTypes(con, classes, types);
		}
	}

	void modClasses(SoftwareSystem ss, ref StringEntityMap!Class classes) {
		import std.algorithm.searching : canFind;
		void modClassesImpl(C)(C con, ref StringEntityMap!Class classes)
		{
			foreach(const(string) key, Class cls; classes) {
				if(key in con.classes) {
					logf("%s %s", con.name, key);
					con.classes.remove(key);
					con.classes[key] = cls;
					cls.parents ~= con;
				}
			}

		}
		void modClasses(Container con, ref StringEntityMap!Class classes) {
			void modClasses(Component com, ref StringEntityMap!Class classes) {
				foreach(const(string) key, Component scom; com.subComponents) {
					modClasses(scom, classes);
				}

				modClassesImpl(com, classes);
			}

			foreach(const(string) key, Component com; con.components) {
				modClasses(com, classes);
			}

			modClassesImpl(con, classes);
		}

		foreach(const(string) key, Container con; ss.containers) {
			modClasses(con, classes);
		}
	}

	Entity getFromSelection(TheWorld w, string[] paths) {
		foreach(it; paths) {
			auto ret = w.get(it);
			if(ret !is null) {
				return ret;
			}
		}

		return null;
	}
}
