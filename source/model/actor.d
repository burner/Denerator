module model.actor;

import model.entity : Entity;

class Actor : Entity {
	string type;
	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in Actor old, in Entity parent) {
		super(old, parent);
		this.type = old.type;
	}
}

