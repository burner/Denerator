module model.type;

import model.entity : StringEntityMap;
import model.entity : Entity;

class Type : Entity {
	StringEntityMap!(string) typeToLanguage;

	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in Type old, in Entity parent) {
		super(old, parent);

		foreach(const(string) key, const(string) value; old.typeToLanguage) {
			this.typeToLanguage[key] = value;
		}
	}
}
