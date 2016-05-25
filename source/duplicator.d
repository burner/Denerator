module duplicator;

import std.experimental.logger;
import model;

// Does only duplicate Nodes, no edges
TheWorld duplicateNodes(in TheWorld old) {
	auto ret = new TheWorld(old);
	StringEntityMap!Class classes;

	foreach(const(string) key, SoftwareSystem ss; ret.softwareSystems) {
		addClasses(ss, classes);
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

		//auto fEn = ne.get(fPath[0]);
		//auto tEn = ne.get(tPath[0]);
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
	void addClasses(SoftwareSystem ss, ref StringEntityMap!Class classes) {
		void addClasses(Container con, ref StringEntityMap!Class classes) {
			void addClasses(Component com, ref StringEntityMap!Class classes) {
				foreach(const(string) key, Component scom; com.subComponents) {
					addClasses(scom, classes);
				}

				foreach(const(string) key, Class cls; com.classes) {
					if(key !in classes) {
						classes[key] = cls;
					}
				}
			}

			foreach(const(string) key, Component com; con.components) {
				addClasses(com, classes);
			}

			foreach(const(string) key, Class cls; con.classes) {
				if(key !in classes) {
					classes[key] = cls;
				}
			}
		}

		foreach(const(string) key, Container con; ss.containers) {
			addClasses(con, classes);
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
