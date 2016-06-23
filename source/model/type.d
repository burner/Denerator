module model.type;

import model.entity : StringEntityMap;
import model.entity : Entity, ProtectedEntity;

class Type : ProtectedEntity {
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

	string typeToLang(string lang) const {
		if(lang in this.typeToLanguage) {
			return this.typeToLanguage[lang];
		} else {
			return "\"" ~ lang ~ "no found\"";
		}
	}
}
