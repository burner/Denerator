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
