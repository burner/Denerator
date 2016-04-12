module model;

enum ActorType
	SoftWareSystem,
	Person
}

abstract class Entity {
	string name;
	string description;
}

class Actor : Entity {
	ActorType type;
}

class SoftwareSystem : Entity {
	Container[] containers;
}

class Container : Entity {
	Component[] components;
}

class Components : Entity {
	Class[] classes;
}

class Class : Entity {
	MemberVariable[] memberVariables;
	MemberFunction[] memberFunctions;
}

class MemberVariable : Entity {
}

class MemberFunction : Entity {
}
