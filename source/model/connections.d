module model.connections;

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

class HardwareSystem : Entity {
	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in HardwareSystem old, in Entity parent) {
		super(old, parent);
	}
}
