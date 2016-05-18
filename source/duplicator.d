module duplicator;

// Does only duplicate Nodes, no edges
TheWorld duplicateNodes(in TheWorld old) {
	auto ret = new TheWorld(old);
	StringEntityMap!Class classes;

	foreach(const(string) key, SoftwareSystem ss; ret.softwareSystems) {
		addClasses(ss, classes);
	}

	log(classes.length);

	return ret;
}

private {
	void addClasses(SoftwareSystem ss, ref StringEntityMap!Class classes) {
		foreach(const(string) key, Container con; ss.containers) {
			addClasses(con, classes);
		}
	}

	void addClasses(Container con, ref StringEntityMap!Class classes) {
		foreach(const(string) key, Component com; con.components) {
			addClasses(com, classes);
		}

		foreach(const(string) key, Class cls; con.classes) {
			if(key !in classes) {
				classes[key] = cls;
			}
		}
	}

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
}
