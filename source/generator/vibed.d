module generator.vibed;

import std.array;
import std.meta : AliasSeq;
import std.stdio;

import containers.dynamicarray;

import exceptionhandling;

import generator.cstyle;

class VibeD : CStyle {
	import std.exception : enforce;
	import std.uni : toLower;
	import util;

	this(in TheWorld world, in string outputDir) {
		super(world, outputDir);
	}

	override void generate() {
		super.generate("D");
	}

	override void generateAggregation(LTW ltw, in Aggregation agg) {
		this.generateModuleDecl(ltw, agg);
		this.generateImport(ltw, cast(const(Class))agg.from);
		this.generateImport(ltw, cast(const(Class))agg.to);

		format(ltw, 0, "\nstruct %s {\n", agg.name);
		format(ltw, 1, "const long %s_id;\n", agg.name);
		format(ltw, 1, "%s from;\n", agg.from.name);
		format(ltw, 1, "%s to;\n\n", agg.to.name);
		format(ltw, 1, "this(long %s_id, %s from, %s to) {\n", agg.name, 
			agg.from.name, agg.to.name);
		format(ltw, 2, "this.%s_id = %s_id;\n", agg.name, agg.name);
		format(ltw, 2, "this.from = from;\n");
		format(ltw, 2, "this.to = to;\n");
		format(ltw, 1, "}\n\n");

		format(ltw, 1, "this(%s from, %s to) {\n", agg.from.name, agg.to.name);
		format(ltw, 2, "this.from = from;\n");
		format(ltw, 2, "this.to = to;\n");
		format(ltw, 1, "}\n");
		format(ltw, 0, "}\n");
	}

	void generateImports(LTW ltw, in Class cls) {
		ensure(cls !is null, "Cannot generate imports for null Class");
		EntityHashSet!(Class) allreadyImported;

		foreach(EdgeType; AliasSeq!(const(Dependency), const(Composition),
					const(Realization), const(Aggregation)))
		{
			//logf("%s", EdgeType.stringof);
			foreach(con; entityRange!(EdgeType)(&this.world.connections)) {
				auto to = cast(Class)(con.to);
				if(to !is null && to !in allreadyImported && to !is cls) {
					//logf("%s %s %s", cls.name, con.from !is null,
					//	con.from !is null ? con.from.name : ""
					//);
					this.generateImport(ltw, to);
					allreadyImported.insert(to);
				}
			}
		}
	}

	void generateImport(LTW ltw, in Class cls) {
		import std.string : indexOf;
		auto name = holdsContainerNameTrim(cls.pathsToRoot());
		auto dot = name.indexOf('.');
		if(dot != -1) {
			name = name[dot+1 .. $];
		}
		format(ltw, 0, "import %s;\n", toLower(name));
	}

	void generateModuleDecl(LTW ltw, in Entity en) {
		format(ltw, 0, "module ");

		First first;
		if(this.outDirPath.length > 0) {
			foreach(it; this.outDirPath[2 .. $]) {
				format(ltw, 0, "%s", first(
						(){ return format("%s", toLower(it)); },
						(){ return format(".%s", toLower(it)); }
					)
				);
			}
		}
		format(ltw, 0, "%s%s;\n\n", first ? "" : ".", toLower(en.name));
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

		generateProtectedEntity(ltw, cast(ProtectedEntity)cls);
		logf("%s %s", cls.containerType.get("D", "class"), cls.name);
		format(ltw, 0, "%s %s", cls.containerType.get("D", "class"), 
			cls.name
		);

		First first;
		foreach(EdgeType; AliasSeq!(const(Generalization), const(Realization)))
		{
			foreach(con; entityRangeFrom!(EdgeType)(&this.world.connections, cls)) {
				assert(con.from is cls);
				format(ltw, 0, "%s", first(
						(){ return " : "; },
						(){ return ", "; }
					)
				);
				format(ltw, 0, con.to.name);
			}
		}

		format(ltw, 0, " { \n");

		auto mvs = MemRange!(const(MemberVariable))(cls.members);
		foreach(mv; mvs) {
			chain(
				this.generateProtectedEntity(ltw, 
					cast(const(ProtectedEntity))(mv), 1),
				"In Member with name", mv.name, "."
			);
			chain(
				this.generateType(ltw, cast(const(Type))(mv.type)),
				"In Member with name", mv.name, "."
			);

			format(ltw, 0, "%s;\n", mv.name);
		}

		foreach(con; entityRangeFrom!(const(Composition))(&this.world.connections, cls)) 
		{
			assert(con.from is cls);
			chain(
				this.generateType(ltw, cast(const(Type))(con.fromType), 1),
				"In Member with name", con.name, "."
			);
			format(ltw, 0, "%s;\n", con.name);
		}

		format(ltw, 0, "\n");
		generateCtor(ltw, cls, FilterConst.no);
		generateCtor(ltw, cls, FilterConst.yes);

		if(cls.containerType.get("D", "abstract class")) {
			foreach(con; entityRangeFrom!(const(Realization))(&this.world.connections, cls)) 
			{
				assert(con.from is cls);
				generateMemberFunction(ltw, 
					cast(const(Class))(con.to), "abstract " 
				);
			}
		}
		generateMemberFunction(ltw, cls);
		generateToStr(ltw, cls);

		format(ltw, 0, "}\n");
	}

	void generateMemberFunction(LTW ltw, in Class cls, string prefix = "") {
		chain(generateMemberFunctionImpl(ltw, cls, prefix),
			"In Class with name", cls.name, "."
		);
	}

	void generateMemberFunctionImpl(LTW ltw, in Class cls, string prefix = "") {
		ensure(cls !is null, "Class must not be null.");
		logf("%s %s", cls.containerType.get("D", "class"), cls.name);

		foreach(mv; MemRange!(const(MemberFunction))(cls.members)) {
			logf("%s %s %s %s", cls.containerType.get("D", "class"), cls.name,
					mv.name, mv.returnType.name);
			if(cls.containerType.get("D", "class") == "abstract class") {
				format(ltw, 1, "abstract ");
			} else {
				format(ltw, 1, "%s", prefix);
			}
			chain(
				this.generateType(ltw, cast(const(Type))(mv.returnType)),
				"In Member with name", mv.name, "."
			);

			format(ltw, 0, "%s(", mv.name);
			First first;
			foreach(pa; mv.parameter) {
				format(ltw, 0, "%s", 
						first(() { return ""; }, (){ return ", "; })
				);
				chain(
					this.generateType(ltw, cast(const(Type))(pa.type)),
					"In Member with name", mv.name, "."
				);
				format(ltw, 0, "%s", pa.name);
			}
			format(ltw, 0, ");\n\n");
		}
	}

	bool isConst(in Member mem) {
		import std.algorithm.searching : canFind;
		if("D" in mem.langSpecificAttributes) {
			const(string[]) att = mem.langSpecificAttributes["D"];
			return canFind(att, "const");
		} else {
			return false;
		}
	}

	void generateCtor(LTW ltw, in Class cls, const FilterConst fc) {
		import std.array : appender;
		import std.algorithm.iteration : filter;
		import std.range.primitives : walkLength;

		size_t wl = 0;
		if(fc == FilterConst.yes) {
			wl = MemRange!(const MemberVariable)(cls.members)
					.filter!(a => !isConst(a))
					.walkLength;
		} else if(fc == FilterConst.no) {
			wl = MemRange!(const MemberVariable)(cls.members)
					.walkLength;
		}

		if(wl == 0) {
			return;
		}

		First first;

		auto app = appender!string();
		bool wrap = false;
		format(app, 1, "this(");
		foreach(mv; MemRange!(const MemberVariable)(cls.members)) {
			if(fc == FilterConst.yes && isConst(mv)) {
				continue;
			}
			if(app.data.length + parameterLength(mv) > 80) {
				format(ltw, 0, "%s\n", app.data);
				app = appender!string();
				format(app, 3, "");
				wrap = true;
			} 
			first((){}, (){ format(app, 0, ", "); });
			generateType(app, mv.type);
			format(app, 0, "%s", mv.name);
		}

		foreach(con; entityRangeFrom!(const(Composition))(&this.world.connections, cls)) {
			assert(con.from is cls);
			if(app.data.length + parameterLength(con) > 80) {
				format(ltw, 0, "%s\n", app.data);
				app = appender!string();
				format(app, 3, "");
				wrap = true;
			} 
			first((){}, (){format(app, 0, ", ");});

			chain(
				chain(
					generateType(app, cast(const(Type))(con.fromType)),
					"In Member with name", con.name, "."
				),
				"In Class with name", cls.name, "."
			);
			format(app, 0, "%s", con.name);
		}

		if(cls.containerType.get("D", "class") == "interface") {
			format(ltw, 0, "%s);", app.data);
		}

		if(wrap) {
			format(ltw, 0, "%s)\n", app.data);
			format(ltw, 1, "{\n");
		} else {
			format(ltw, 0, "%s) {\n", app.data);
		}

		foreach(mv; MemRange!(const MemberVariable)(cls.members)) {
			if(fc == FilterConst.yes && isConst(mv)) {
				continue;
			}
			format(ltw, 2, "this.%s = %s;\n", mv.name, mv.name);
		}
		foreach(con; entityRangeFrom!(const(Composition))(&this.world.connections, cls)) {
			assert(con.from is cls);
			format(ltw, 2, "this.%s = %1$s;\n", con.name);
		}
		format(ltw, 1, "}\n\n");
	}

	void generateToStr(LTW ltw, in Class cls) {
		if(cls.containerType.get("D", "class") == "interface") {
			return;
		}
		foreach(it; 0 .. 3) {
			if(it == 0) {
				if("D" in cls.containerType 
						&& cls.containerType["D"] == "struct")
				{
					format(ltw, 1, "string toString() {\n");
				} else {
					format(ltw, 1, "override string toString() {\n");
				}
				format(ltw, 2, "import std.array : appender;\n");
				format(ltw, 2, "auto sink = appender!string();\n");
			} else if(it == 1) {
				format(ltw, 1, 
					"void toString(scope void delegate(const(char)[]) sink) {\n"
				);
			} else if(it == 2) {
				format(ltw, 1, 
					"void toString(scope void delegate(const(char)[]) " ~
					"@trusted sink) @trusted {\n"
				);
			} else {
				assert(false);
			}

			format(ltw, 2, "import std.format : formattedWrite;\n");
			format(ltw, 2, "formattedWrite(sink, \"%s(\");\n", cls.name);

			First first;
			foreach(mv; MemRange!(const MemberVariable)(cls.members)) {
				format(ltw, 2, "%s", first(
					(){ return "formattedWrite(sink, \",\");\n"; },
					(){ return format(
							"formattedWrite(sink, \"%s='%%s'\", this.%s);\n", 
							mv.name, mv.name
						);})
				);
			}
			format(ltw, 2, "formattedWrite(sink, \")\");\n");

			if(it == 0) {
				format(ltw, 2, "return sink.data;\n");
			}

			format(ltw, 1, "}\n\n");
		}
	}

	void generateProtectedEntity(LTW ltw, in ProtectedEntity pe, 
			in int indent = 0) {
		if("D" in pe.protection) {
			format(ltw, indent, "%s ", pe.protection["D"]);
		} else if(indent > 0) {
			format(ltw, indent, "");
		}
	}

	void generateType(Out)(ref Out ltw, in Type type, in int indent = 0) {
		ensure(type !is null, "Type is null");
		if(auto cls = cast(const(Class))type) {
			format(ltw, indent, "%s ", cls.name);
		} else {
			ensure("D" in type.typeToLanguage, "Variable type\"",
				type.name, "\"has no typeToLanguage entry for key", "D"
			);
			format(ltw, indent, "%s ", type.typeToLanguage["D"]);
		}
	}

	size_t parameterLength(in MemberVariable mv) {
		ensure(mv.type !is null, "MemberVariable of name", mv.name, " has no type");
		ensure("D" in mv.type.typeToLanguage, "MemberVariable.type",
			"has no entry for key", "D"
		);
		return mv.type.typeToLanguage["D"].length + mv.name.length + 2;
	}

	size_t parameterLength(in Composition mv) {
		ensure(mv.fromType !is null, "Composition of name", mv.name, 
				" has no type"
			);
		ensure("D" in mv.fromType.typeToLanguage, "Composition.fromType",
				"has no entry for key", "D"
			);
		return mv.fromType.typeToLanguage["D"].length + mv.name.length + 2;
	}


	string holdsContainerNameTrim(string[] paths) {
		import std.string : indexOf;

		foreach(string str; paths) {
			if(str.indexOf(this.curCon.name) != -1) {
				auto dot = str.indexOf('.');
				if(dot != -1) {
					return str[dot + 1 .. $];
				}
			}
		}

		return "";
	}
}
