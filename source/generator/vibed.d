module generator.vibed;

import generator;
import model;
import std.array : empty, front;

class VibeD : Generator {
	import std.exception : enforce;

	const(string) outputDir;

	this(in TheWorld world, in string outputDir) {
		super(world);
		this.outputDir = outputDir;
		enforce(Generator.createFolder(outputDir));
	}

	override void generate() {
	}

	void generate(in Container con) {
		import std.stdio : stdout;
		auto ltw = stdout.lockingTextWriter();
		foreach(const(string) cn, const(Component) com; con.components) {
			this.generate(ltw, com);
		}

		foreach(const(string) cn, const(Class) cls; con.classes) {
			this.generate(ltw, cls);
		}
	}

	void generate(Out)(ref Out ltw, in Component com) {
		foreach(const(string) cn, const(Component) scom; com.subComponents) {
			this.generate(ltw, scom);
		}

		foreach(const(string) cn, const(Class) cls; com.classes) {
			this.generate(ltw, cls);
		}
	}

	void generate(Out)(ref Out ltw, in Class cls) {
		import std.range : isInputRange;
		generate(ltw, cast(ProtectedEntity)cls);
		format(ltw, 0, "%s %s {\n", cls.containerType.get("D", "class"), 
			cls.name
		);

		auto mvs = MemRange!(const(MemberVariable))(&cls.members);
		foreach(mv; mvs) {
			this.generate(ltw, cast(const(ProtectedEntity))(mv), 1);
			chain!Exception(this.generate(ltw, cast(const(Type))(mv.type)),
				"In Class with name", cls.name, "."
			);
			format(ltw, 0, "%s;\n", mv.name);
		}

		format(ltw, 0, "\n");
		generateCtor(ltw, cls);
		generateToStr(ltw, cls);

		format(ltw, 0, "}\n");
	}

	void generateCtor(Out)(ref Out ltw, in Class cls) {
		import std.array : appender;
		auto app = appender!string();
		bool first = true;
		bool wrap = false;
		format(app, 1, "this(");
		foreach(mv; MemRange!(const MemberVariable)(&cls.members)) {
			if(app.data.length + parameterLength(mv) > 80) {
				format(ltw, 0, "%s\n", app.data);
				app = appender!string();
				format(app, 3, "");
				wrap = true;
			} 
			if(!first) {
				format(app, 0, ", ");
			}
			generate(app, mv.type);
			format(app, 0, "%s", mv.name);
			first = false;
		}

		if(wrap) {
			format(ltw, 0, "%s)\n", app.data);
			format(ltw, 1, "{\n");
		} else {
			format(ltw, 0, "%s) {\n", app.data);
		}

		foreach(mv; MemRange!(const MemberVariable)(&cls.members)) {
			format(ltw, 2, "this.%s = %s;\n", mv.name, mv.name);
		}
		format(ltw, 1, "}\n\n");
	}

	void generateToStr(Out)(ref Out ltw, in Class cls) {
		foreach(it; 0 .. 3) {
			if(it == 0) {
				format(ltw, 1, "string toString() {\n");
				format(ltw, 2, "import std.array : appender\n");
				format(ltw, 2, "auto sink = appender!string()\n");
			} else if(it == 1) {
				format(ltw, 1, 
					"void toString(scope void delegate(const(char)[]) sink) {\n"
				);
			} else if(it == 2) {
				format(ltw, 1, 
					"void toString(scope void delegate(const(char)[]) " ~
					"@trusted sink) {\n"
				);
			} else {
				assert(false);
			}

			format(ltw, 2, "import std.format : formattedWrite;\n");
			format(ltw, 2, "formattedWrite(sink, \"%s(\");\n", cls.name);

			bool first = true;
			foreach(mv; MemRange!(const MemberVariable)(&cls.members)) {
				if(!first) {
					format(ltw, 2, "formattedWrite(sink, \",\");\n");
				}
				first = false;
				format(ltw, 2, "formattedWrite(sink, \"%s='%%s'\", this.%s);\n", 
					mv.name, mv.name
				);
			}
			format(ltw, 2, "formattedWrite(sink, \")\");\n");

			if(it == 0) {
				format(ltw, 2, "return sink.data\n");
			}

			format(ltw, 1, "}\n\n");
		}
	}

	void generate(Out)(ref Out ltw, in ProtectedEntity pe, in int indent = 0) {
		if("D" in pe.protection) {
			format(ltw, indent, "%s ", pe.protection["D"]);
		} else if(indent > 0) {
			format(ltw, indent, "");
		}
	}

	void generate(Out)(ref Out ltw, in Type type, in int indent = 0) {
		expect!Exception(type, "MemberVariable of name", type.name, 
			" has no type"
		);
		expect!Exception("D" in type.typeToLanguage, "Variable type",
			"has no typeToLanguage entry for key", "D"
		);
		format(ltw, indent, "%s ", type.typeToLanguage["D"]);
	}

	size_t parameterLength(in MemberVariable mv) {
		expect!Exception(mv.type, "MemberVariable of name", mv.name, 
			" has no type"
		);
		expect!Exception("D" in mv.type.typeToLanguage, "MemberVariable.type",
			"has no entry for key", "D"
		);
		return mv.type.typeToLanguage["D"].length + mv.name.length + 2;
	}
}
