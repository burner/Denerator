module model.hardwaresystem;

import model.entity : Entity;

class HardwareSystem : Entity {
	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in HardwareSystem old, in Entity parent) {
		super(old, parent);
	}
}
