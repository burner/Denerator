module source.type;

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

/* This class maps types from one language to other languages

For instance, a D string may becomes a LONGTEXT in MySQL
*/
class TypeMapping {
	StringEntityMap!(Type) equivalencies;
}