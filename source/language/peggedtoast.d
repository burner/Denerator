module language.peggedtoast;

import std.stdio;

import std.array : appender, back, empty;
import std.format : formattedWrite;

import pegged.grammar;
import language.ast;

class Note {
	string[] str;

	override string toString() { 
		auto app = appender!string();
		app.put(": ");
		foreach(it; this.str) {
			app.put(it);
			app.put(" ");
		}

		return app.data;
	}
}

abstract class Member {
	char protection = ' ';
	string abstractStatic;
	Note[] notes;

	abstract override string toString();
} 

class Modifier {
	string modifier;
}

class Type {
	Modifier modifier;
	string type;
	Type follow;

	override string toString() {
		auto app = appender!string();
		if(this.modifier !is null) {
			formattedWrite(app, "%s(", this.modifier.modifier);
		}
		if(!this.type.empty) {
			app.put(this.type);
		} else {
			assert(follow !is null);
			app.put(this.follow.toString());
		}

		if(this.modifier !is null) {
			app.put(")");
		}
		return app.data;
	}
}

class MemberVariable : Member {
	Type type;
	string identifier;

	override string toString() {
		auto app = appender!string();
		formattedWrite(app, "%s", protection);
		if(!abstractStatic.empty) {
			formattedWrite(app, " %s", abstractStatic);
		}
		formattedWrite(app, " %s", identifier);
		formattedWrite(app, " %s", type.toString());
		foreach(it; notes) {
			formattedWrite(app, " %s", it);
		}

		return app.data;
	}
}

class ParameterList {
	MemberVariable[] parameter;

	override string toString() {
		auto app = appender!string();

		foreach(it; parameter) {
			formattedWrite(app, "%s", it.toString());
		}

		return app.data;
	}
}

class MemberFunction : Member {
	Type type;
	string identifier;
	ParameterList parameterList;

	override string toString() {
		auto app = appender!string();
		formattedWrite(app, "%s", protection);
		if(!abstractStatic.empty) {
			formattedWrite(app, " %s", abstractStatic);
		}
		formattedWrite(app, " %s", identifier);
		formattedWrite(app, " %s", type.toString());
		formattedWrite(app, "(%s)", parameterList.toString());

		foreach(it; notes) {
			formattedWrite(app, " %s", it);
		}

		return app.data;
	}
}

class MemberSeperator : Member {
	string seperatorSymbol;
	string seperatorText;

	override string toString() {
		auto app = appender!string();
		formattedWrite(app, "%s", seperatorSymbol);

		if(!seperatorText.empty) {
			formattedWrite(app, "%s", seperatorText);
		}

		return app.data;
	}
}

class Class {
	string className;
	string classType;
	Member[] members;
	string[] stereoTypes;
	Note[] notes;

	override string toString() {
		auto app = appender!string();

		formattedWrite(app, "%s %s", this.classType, this.className);
		app.put("<<");
		foreach(it; this.stereoTypes) {
			formattedWrite(app, " %s", it);
		}
		app.put(">>");
		foreach(it; this.notes) {
			formattedWrite(app, " %s", it.toString());
		}
		app.put("{");
		foreach(it; this.members) {
			app.put(it.toString());
		}
		app.put("}");
		return app.data;
	}
}

class UMLCls {
	Class[] classes;

	override string toString() {
		auto app = appender!string();
		foreach(it; this.classes) {
			app.put(it.toString());
		}
		return app.data;
	}
}

UMLCls peggedToUML(ParseTree p) {
	auto ret = new UMLCls;
	switch(p.name) {
		case "UML":
			foreach(it; p.children) {
				if(it.name == "UML.Start") {
					foreach(jt; it.children) {
						if(jt.name == "UML.Comment") {
							continue;
						} else if(jt.name == "UML.ClassStart") {
							auto cls = peggedToClassStart(jt);
							ret.classes ~= cls;
						} else {
							writeln(jt.name);
						}
					}
				}
			}
			break;
		default:
			assert(false, "Not implemented "  ~ p.name);
	}
	return ret;
}

Class peggedToClassStart(ParseTree p) {
	auto cls = new Class;
	foreach(it; p.children) {
		if(it.name == "UML.Context") {
		} else if(it.name == "UML.Class") {
			peggedToClass(it, cls);
		} else if(it.name == "UML.RealNote") {
		}
	}

	return cls;
}

void peggedToClass(ParseTree p, Class cls) {
	foreach(it; p.children) {
		if(it.name == "UML.ClassPrefix") {
			foreach(jt; it.children) {
				if(jt.name == "UML.ClassType") {
					foreach(kt; jt.matches) {
						cls.classType ~= kt;
					}
				} else if(jt.name == "UML.ClassName") {
					foreach(kt; jt.matches) {
						cls.className ~= kt;
					}
				}
			}
		} else if(it.name == "UML.StereoTypes") {
			foreach(jt; it.children) {
				if(jt.name == "UML.StereoType") {
					foreach(kt; jt.matches) {
						cls.stereoTypes ~= kt;
					}
				}
			}
		} else if(it.name == "UML.ClassBody") {
			foreach(jt; it.children) {
				if(jt.name == "UML.ClassDecls") {
					foreach(kt; jt.children) {
						if(kt.name == "UML.Method") {
							cls.members ~= peggedToMethod(kt);
						} else if(kt.name == "UML.Member") {
							cls.members ~= peggedToMember(kt);
						} else if(kt.name == "UML.Seperator") {
							cls.members ~= peggedToSeperator(kt);
						}
					}
				} else {
					assert(false, jt.name);
				}
			}
		} else {
			assert(false, it.name);
		}
	}
}

MemberVariable peggedToMember(ParseTree p) {
	auto ret = new MemberVariable;
	foreach(it; p.children) {
		if(it.name == "UML.Parameter") {
			foreach(jt; it.children) {
				if(jt.name == "identifier") {
					foreach(kt; jt.matches) {
						ret.identifier ~= kt;
					}
				} else if(jt.name == "UML.Type") {
					ret.type = peggedToType(jt);
				}
			}
		} else if(it.name == "UML.Note") {
			ret.notes ~= peggedToNote(it);
		} else {
			assert(false, it.name);
		}
	}

	return ret;
}

Type peggedToType(ParseTree p) {
	auto ret = new Type;
	foreach(it; p.children) {
		if(it.name == "UML.Modifier") {
			ret.modifier = new Modifier;
			ret.modifier.modifier = it.matches[0];
		} else if(it.name == "UML.Type") {
			ret.follow = peggedToType(it);
		} else if(it.name == "identifier") {
			ret.type = it.matches[0];
		}
	}
	return ret;
}

MemberFunction peggedToMethod(ParseTree p) {
	auto ret = new MemberFunction;
	foreach(it; p.children) {
		if(it.name == "UML.AbstractStatic") {
			foreach(jt; it.children) {
				if(jt.name == "UML.AbstractStatic") {
					foreach(kt; jt.matches) {
						ret.abstractStatic ~= kt;
					}
				}
			}
		} else if(it.name == "UML.Protection") {
			ret.protection = it.matches[0][0];
		} else if(it.name == "UML.Type") {
			ret.type = peggedToType(it);
		} else if(it.name == "UML.MethodName") {
			ret.identifier = it.matches[0];
		} else if(it.name == "UML.ParameterList") {
			ret.parameterList = peggedToParameterList(it);
		} else if(it.name == "UML.Note") {
			foreach(jt; it.children) {
				ret.notes ~= peggedToNote(jt);
			}
		} else {
			assert(false, it.name);
		}
	}

	return ret;
}

MemberSeperator peggedToSeperator(ParseTree p) {
	auto ret = new MemberSeperator;
	foreach(it; p.children) {
		if(it.name == "NoteText") {
			ret.seperatorText ~= it.matches[0];
		}
	}
	return ret;
}

ParameterList peggedToParameterList(ParseTree p) {
	auto ret = new ParameterList;

	foreach(it; p.children) {
		if(it.name == "UML.Parameter") {
			ret.parameter ~= new MemberVariable;
			foreach(jt; it.children) {
				if(jt.name == "identifier") {
					ret.parameter.back.identifier = jt.matches[0];
				} else if(jt.name == "UML.Type") {
					ret.parameter.back.type = peggedToType(jt);
				}
			}
		}
	}

	return ret;
}

Note peggedToNote(ParseTree p) {
	auto ret = new Note;
	foreach(it; p.children) {
		if(it.name == "UML.NoteText") {
			foreach(jt; it.children) {
				if(jt.name == "UML.Text") {
					foreach(kt; jt.matches) {
						ret.str ~= kt;
					}
				}
			}
		}
	}

	return ret;
}
