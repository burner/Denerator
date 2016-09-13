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
	//MemberVariable fromStore; 

	// a MemberVariable that stores toCnt instances of to
	//MemberVariable toStore; 

	this(in string name, in Entity parent) {
		super(name, parent);
		fromCnt.low = -1;
		fromCnt.high = -1;

		toCnt.low = -1;
		toCnt.high = -1;
	}
}

// from can not exists without to
class Composition : ConnectionImpl {
	import model.type;
	ConnectionCount fromCnt; // the "to" count is always 1 for Composition

	// a MemberVariable that stores fromCnt instances of from
	Type fromType; 

	this(in string name, in Entity parent) {
		super(name, parent);
		fromCnt.low = -1;
		fromCnt.high = -1;
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
ConnectedPath[] connectedPaths(string[] from, string[] to) {
	import std.algorithm.iteration : splitter;
	import std.algorithm.comparison : equal;
	import std.array : array;
	ConnectedPath[] ret;
	outer: foreach(string fit; from) {
		string[] fsp = fit.splitter(".").array;
		if(fsp.length < 2) {
			continue;
		}
		auto fsps = fsp[0 .. 2];
		foreach(string tit; to) {
			string[] tsp = tit.splitter(".").array;
			if(tsp.length < 2) {
				continue;
			}
			auto tsps = tsp[0 .. 2];

			if(fsps.equal(tsps)) {
				ret ~= ConnectedPath(fit, tit);
				break;
			}
		}
	}

	return ret;
}

unittest {
	import std.format : format;
	string[] from = [
		"AwesomeSoftware.Frontend.frontUserCtrl.Address",
		"AwesomeSoftware.Database.Address",
		"AwesomeSoftware.Server.serverUserCtrl.Address"
	];

	string[] to = [
		"AwesomeSoftware.Frontend.frontUserCtrl.User",
		"AwesomeSoftware.Server.serverUserCtrl.User",
		"AwesomeSoftware.Database.User"
	];

	ConnectedPath[] correct = [
		ConnectedPath(
			"AwesomeSoftware.Frontend.frontUserCtrl.Address",
			"AwesomeSoftware.Frontend.frontUserCtrl.User"
		),
		ConnectedPath(
			"AwesomeSoftware.Server.serverUserCtrl.Address",
			"AwesomeSoftware.Server.serverUserCtrl.User"
		),
		ConnectedPath(
			"AwesomeSoftware.Database.Address",
			"AwesomeSoftware.Database.User"
		)
	];

	auto rslt = connectedPaths(from, to);
	assert(correct.length == rslt.length,
		format("%s %s\n%s", correct.length, rslt.length, rslt)
	);
	
	foreach(it; correct) {
		bool found = false;
		foreach(jt; rslt) {
			if(it == jt) {
				found = true;
				break;
			}
		}

		assert(found, format("%s %s", it, rslt));
	}
}
