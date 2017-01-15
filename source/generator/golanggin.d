module generator.golanggin;

import generator.cstyle;

class GoLangGin : CStyle {
	this(in TheWorld world, in string outputDir) {
		super(world, outputDir);
	}

	override void generate() {
		super.generate("golanggin");
	}

	override void generateClass(LTW ltw, const(Class) cls) {
		if(cls.doNotGenerate == DoNotGenerate.yes) {
			return;
		}

		chain(generateClassImpl(ltw, cls),
			"In Class with name", cls.name, "."
		);
	}

	void generateClassImpl(LTW ltw, in Class cls) {
		import std.range : isInputRange;

		ensure(cls !is null, "Class must not be null.");
		generateModuleDecl(ltw, cls);
		generateImports(ltw, cls);
		format(ltw, 0, "\n");

		format(ltw, 0, "type %s struct {\n", cls.name);

		auto mvs = MemRange!(const(MemberVariable))(cls.members);
		foreach(mv; mvs) {
			chain(
				this.generateType(ltw, cast(const(Type))(mv.type)),
				"In Member with name", mv.name, "."
			);

			format(ltw, 0, "%s;\n", mv.name);
		}
	}

	void generateType(Out)(ref Out ltw, in Type type, in int indent = 0) {
		ensure(type !is null, "Type is null");
		if(auto cls = cast(const(Class))type) {
			format(ltw, indent, "%s ", cls.name);
		} else {
			ensure("golang" in type.typeToLanguage, "Variable type\"",
				type.name, "\"has no typeToLanguage entry for key", "golang"
			);
			format(ltw, indent, "%s ", type.typeToLanguage["golang"]);
		}
	}
}
