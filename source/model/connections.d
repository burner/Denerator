module model.connections;

import model.entity : Entity;
import model.classes : MemberVariable;

struct ConnectionCount {
	long low;
	long high;
}

class ConnectionImpl : Entity {
	Entity from;
	Entity to;

	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

// Dependency are basically import
class Dependency : ConnectionImpl {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

// Connection are logical connections
class Connection : ConnectionImpl {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

// from and to can exists without each other
class Aggregation : ConnectionImpl {
	ConnectionCount fromCnt;
	ConnectionCount toCnt;

	// a MemberVariable that stores fromCnt instances of from
	MemberVariable fromStore; 

	// a MemberVariable that stores toCnt instances of to
	MemberVariable toStore; 

	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

// from can not exists without to
class Composition : ConnectionImpl {
	ConnectionCount fromCnt; // to count is always 1 for Composition

	// a MemberVariable that stores fromCnt instances of from
	MemberVariable fromStore; 
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

// Generalization subclass a Class
class Generalization : ConnectionImpl {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

// Realization implements a Interface
class Realization : ConnectionImpl {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

struct ConnectedPath {
	string from;
	string to;
}

/* The idea of this function is to find a path from "from" and a path from
"to" that equal in the first three level (World.SoftwareSystem.Container).
ConnectedPaths where from and to are not empty are connected Classes inside a
container or component. This is important as Classes can be part of multiple
containers or components and we need to draw the edges between them in all
containers and components.
*/
ConnectedPath[] connectPaths(string[] from, string[] to) {
	import std.algorithm.iteration : splitter;
	import std.algorithm.comparison : equal;
	import std.array : array;
	ConnectedPath[] ret;
	outer: foreach(string fit; from) {
		string[] fsp = fit.splitter(".").array;
		if(fsp.length < 2) {
			continue;
		}
		auto fsps = fsp[0 .. 3];
		foreach(string tit; to) {
			string[] tsp = tit.splitter(".").array;
			if(tsp.length < 2) {
				continue;
			}
			auto tsps = tsp[0 .. 3];

			if(fsps.equal(tsps)) {
				ret ~= ConnectedPath(fit, tit);
				continue outer;
			}
		}
	}

	return ret;
}
