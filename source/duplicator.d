module duplicator;

import std.experimental.logger;
import model;

//only duplicates Nodes, no edges
TheWorld duplicateNodes(in TheWorld old) {
    //For every entity and supclasses thereof instantiate new ones and add them to the new world
	auto ret = new TheWorld(old);

	foreach(const(string) name, Type type; ret.typeContainerMapping) {
	    //not null check is performed
		if(Class cls = cast(Class)type) {
		    //gets the class from the world
			const(Class) oldCls = cast(const Class)old.typeContainerMapping[name];
			if(oldCls) {
			    //adds the old class with members to the new world
				cls.realCCtor(oldCls, ret);
			}
		}
	}
	StringEntityMap!Class classes;

	return ret;
}

void reAdjustEdges(in TheWorld old, TheWorld ne) {
	foreach(const(string) key, const(Entity) en; old.connections) {
		const(ConnectionImpl) con = cast(ConnectionImpl)en;

		string[] fPath = pathToRoot(con.from);
		string[] tPath = pathToRoot(con.to);
		//logf("%s %s", fPath, tPath);

		auto fEn = getFromSelection(ne, fPath);
		auto tEn = getFromSelection(ne, tPath);

		if(fEn is null) continue;
		if(tEn is null) continue;

		/*logf("%s\n\t%s %s\n\t%s %s", con.name, con.from.name, con.to.name,
			fEn.name, tEn.name
		);*/

		// no selfconnecting edges
		if(fEn is tEn) {
			continue;
		}

		//logf("%s %s %s", con.name, fEn.name, tEn.name);

		if(auto c = cast(Realization)(con)) {
			ne.copy!Realization(c, fEn, tEn);
		} else if(auto c = cast(Generalization)(con)) {
			ne.copy!Generalization(c, fEn, tEn);
		} else if(auto c = cast(Composition)(con)) {
			ne.copy!Composition(c, fEn, tEn);
		} else if(auto c = cast(Aggregation)(con)) {
			ne.copy!Aggregation(c, fEn, tEn);
		} else if(auto c = cast(Connection)(con)) {
			ne.copy!Connection(c, fEn, tEn);
		} else if(auto c = cast(Dependency)(con)) {
			ne.copy!Dependency(c, fEn, tEn);
		} else if(auto c = cast(ConnectionImpl)(con)) {
			ne.copy!ConnectionImpl(c, fEn, tEn);
		} else {
			assert(false);
		}
	}
}

private Entity getFromSelection(TheWorld w, string[] paths) {
	foreach(it; paths) {
		auto ret = w.get(it);
		if(ret !is null) {
			return ret;
		}
	}

	return null;
}
