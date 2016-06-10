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

/** Stuff like const, immutable, final */
class TypeModifier : Entity {
	StringEntityMap!(string[]) typeModsLang;

	this(in string name, in Entity parent) {
		super(name, parent);
	}

	this(in TypeModifier old, in Entity parent) {
		super(old, parent);
		foreach(const(string) lang, const(string[]) mods; old.typeModsLang) {
			this.typeModsLang[lang] = mods.dup;
		}
	}

	void addTypeMod(in string lang, in string mod) {
		string[] mods;
		if(lang in this.typeModsLang) {
			mods = this.typeModsLang[lang];
		}
		mods ~= mod;
		this.typeModsLang[lang] = mods;
	}
}
