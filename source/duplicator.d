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

	foreach(const(string) key, SoftwareSystem ss; ret.softwareSystems) {
		modClasses(ss, classes);
	}

	EntityHashSet!Entity ehs;
	ehs.insert(ret);

	foreach(const(string) key, Class cls; classes) {
		assert(cls.areYouIn(ehs) is ret, cls.name);
	}

	StringEntityMap!Class classes2;

	foreach(const(string) key, SoftwareSystem ss; ret.softwareSystems) {
		addClasses(ss, classes);
	}

	foreach(const(string) key, Class cls; classes2) {
		assert(cls.areYouIn(ehs) is ret, cls.name);
	}

	return ret;
}

void reAdjustEdges(in TheWorld old, TheWorld ne) {
	foreach(const(string) key, const(Entity) en; old.connections) {
		const(ConnectionImpl) con = cast(ConnectionImpl)en;

		string fPath = con.from.pathToRoot();
		string tPath = con.to.pathToRoot();

		auto fEn = ne.get(fPath);
		auto tEn = ne.get(tPath);
		assert(fEn !is null);
		assert(tEn !is null);
		logf("\n\t%s %s\n\t%s %s", con.from.name, con.to.name,
			fEn.name, tEn.name
		);

		if(fEn is tEn) {
			logf("%s %s %s", con.name, fEn.name, tEn.name);
			continue;
		}

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
		void modClasses(Container con, ref StringEntityMap!Class classes) {
			void modClasses(Component com, ref StringEntityMap!Class classes) {
				foreach(const(string) key, Component scom; com.subComponents) {
					modClasses(scom, classes);
				}

				foreach(const(string) key, Class cls; classes) {
					if(key in com.classes) {
						com.classes[key] = cls;
						if(!canFind(cls.parents[], com)) {
							cls.parents.insert(com);
						}
					}
				}
			}

			foreach(const(string) key, Component com; con.components) {
				modClasses(com, classes);
			}

			foreach(const(string) key, Class cls; classes) {
				if(key in con.classes) {
					con.classes[key] = cls;
					if(!canFind(cls.parents[], con)) {
						cls.parents.insert(con);
					}
				}
			}
		}

		foreach(const(string) key, Container con; ss.containers) {
			modClasses(con, classes);
		}
	}
}
