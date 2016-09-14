module generator.vibed;

import std.experimental.logger;
import generator;
import model;
import std.array;
import std.meta : AliasSeq;
import std.stdio;

import containers.dynamicarray;

alias LTW = File.LockingTextWriter;

class VibeD : Generator {
	import std.exception : enforce;
	import std.typecons : Rebindable, Flag;
	import std.uni : toLower;
	import std.container.array : Array;
	import std.file : getcwd;
	import util;

	const(string) outputDir;
	Array!string outDirPath;
	EntityHashSet!Entity con;
	Rebindable!(const Container) curCon;

	this(in TheWorld world, in string outputDir) {
		super(world);
		this.outputDir = outputDir;
		this.outDirPath.insertBack(outputDir);
		this.outDirPath.insertBack("source");
		logf("%s [%(%s %)]", getcwd(), this.outDirPath[]);
		enforce(Generator.createFolder(outputDir));
	}

	override void generate() {
		foreach(const(string) ssK, const(SoftwareSystem) ss;
				this.world.softwareSystems) 
		{
			foreach(const(string) conK, const(Container) con; ss.containers) {
				if(con.technology == "D") {
					this.generateContainer(con);
				}
			}
		}

		foreach(const(string) conK, const(Entity) con; this.world.connections)
		{
			if(auto agg = cast(const(Aggregation))con) {
				auto ltw = stdout.lockingTextWriter();
				this.generateAggregation(ltw, agg);
			}
		}
	}

	void generateAggregation(LTW ltw, in Aggregation agg) {
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

	void generateContainer(in Container con) {
		createFolder(this.outDirPath[]);
		this.curCon = con;
		this.con.clear();
		this.con.insert(cast(Entity)con);

		foreach(const(string) cn, const(Component) com; con.components) {
			this.generateComponent(com);
		}

		foreach(const(string) cn, const(Class) cls; con.classes) {
			auto f = createFile(this.outDirPath[], toLower(cls.name) ~ ".d", "w");
			auto ltw = f.lockingTextWriter();
			this.generateClass(ltw, cls);
		}
	}

	void generateComponent(in Component com) {
		this.outDirPath.insertBack(toLower(com.name));
		scope(exit) this.outDirPath.removeBack();

		enforce(createFolder(this.outDirPath[]));
		logf("%(%s %)", this.outDirPath[]);

		foreach(const(string) cn, const(Component) scom; com.subComponents) {
			this.generateComponent(scom);
		}

		foreach(const(string) cn, const(Class) cls; com.classes) {
			auto f = createFile(this.outDirPath[], toLower(cls.name) ~ ".d", "w");
			auto ltw = f.lockingTextWriter();
			this.generateClass(ltw, cls);
		}
	}

	void generateImports(LTW ltw, in Class cls) {
		expect(cls, "Cannot generate imports for null Class");
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
		bool first = true;
		if(this.outDirPath.length > 0) {
			foreach(it; this.outDirPath[2 .. $]) {
				if(first) {
					first = false;
					format(ltw, 0, "%s", toLower(it));
				} else {
					format(ltw, 0, ".%s", toLower(it));
				}
			}
		}
		format(ltw, 0, "%s%s;\n\n", first ? "" : ".", toLower(en.name));
	}

	void generateClass(LTW ltw, in Class cls) {
		import std.range : isInputRange;

		expect(cls !is null, "Class must not be null.");
		generateModuleDecl(ltw, cls);
		generateImports(ltw, cls);
		format(ltw, 0, "\n");

		generateProtectedEntity(ltw, cast(ProtectedEntity)cls);
		logf("%s %s", cls.containerType.get("D", "class"), cls.name);
		format(ltw, 0, "%s %s", cls.containerType.get("D", "class"), 
			cls.name
		);

		bool first = true;
		foreach(EdgeType; AliasSeq!(const(Generalization), const(Realization)))
		{
			foreach(con; entityRange!(EdgeType)(&this.world.connections)) {
				if(con.from is cls) {
					if(first) {
						format(ltw, 0, " : ");
						first = false;
					} else {
						format(ltw, 0, ", ");
					}
					format(ltw, 0, con.to.name);
				}
			}
		}

		format(ltw, 0, " { \n");

		auto mvs = MemRange!(const(MemberVariable))(cls.members);
		foreach(mv; mvs) {
			this.generateProtectedEntity(ltw, cast(const(ProtectedEntity))(mv), 1);
			chain(
				chain(
					this.generateType(ltw, cast(const(Type))(mv.type)),
					"In Member with name", mv.name, "."
				),
				"In Class with name", cls.name, "."
			);

			format(ltw, 0, "%s;\n", mv.name);
		}

		foreach(con; entityRange!(const(Composition))(&this.world.connections)) {
			if(con.from is cls) {
				chain(
					chain(
						this.generateType(ltw, cast(const(Type))(con.fromType), 1),
						"In Member with name", con.name, "."
					),
					"In Class with name", cls.name, "."
				);
				format(ltw, 0, "%s;\n", con.name);
			}
		}

		format(ltw, 0, "\n");
		generateCtor(ltw, cls, FilterConst.no);
		generateCtor(ltw, cls, FilterConst.yes);

		if(cls.containerType.get("D", "abstract class")) {
			foreach(con; entityRange!(const(Realization))(&this.world.connections)) 
			{
				if(con.from is cls) {
					generateMemberFunction(ltw, 
						cast(const(Class))(con.to), "abstract " 
					);
				}
			}
		}
		generateMemberFunction(ltw, cls);
		generateToStr(ltw, cls);

		format(ltw, 0, "}\n");
	}

	void generateMemberFunction(LTW ltw, in Class cls, string prefix = "") {
		expect(cls !is null, "Class must not be null.");
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
				chain(
					this.generateType(ltw, cast(const(Type))(mv.returnType)),
					"In Member with name", mv.name, "."
				),
				"In Class with name", cls.name, "."
			);

			format(ltw, 0, "%s(", mv.name);
			bool first = true;
			foreach(pa; mv.parameter) {
				format(ltw, 0, "%s", first ? "" : ", ");
				chain(
					chain(
						this.generateType(ltw, cast(const(Type))(pa.type)),
						"In Member with name", mv.name, "."
					),
					"In Class with name", cls.name, "."
				);
				format(ltw, 0, "%s", pa.name);
				first = false;
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

	alias FilterConst = Flag!"FilterConst";

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

		auto app = appender!string();
		bool first = true;
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
			if(!first) {
				format(app, 0, ", ");
			}
			generateType(app, mv.type);
			format(app, 0, "%s", mv.name);
			first = false;
		}

		foreach(con; entityRange!(const(Composition))(&this.world.connections)) {
			if(con.from is cls) {
				if(app.data.length + parameterLength(con) > 80) {
					format(ltw, 0, "%s\n", app.data);
					app = appender!string();
					format(app, 3, "");
					wrap = true;
				} 
				if(!first) {
					format(app, 0, ", ");
				}
				chain(
					chain(
						generateType(app, cast(const(Type))(con.fromType)),
						"In Member with name", con.name, "."
					),
					"In Class with name", cls.name, "."
				);
				format(app, 0, "%s", con.name);
				first = false;
			}
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
		foreach(con; entityRange!(const(Composition))(&this.world.connections)) {
			if(con.from is cls) {
				format(ltw, 2, "this.%s = %1$s;\n", con.name);
			}
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

			bool first = true;
			foreach(mv; MemRange!(const MemberVariable)(cls.members)) {
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
		expect(type, "Type is null");
		if(auto cls = cast(const(Class))type) {
			format(ltw, indent, "%s ", cls.name);
		} else {
			expect("D" in type.typeToLanguage, "Variable type\"",
				type.name, "\"has no typeToLanguage entry for key", "D"
			);
			format(ltw, indent, "%s ", type.typeToLanguage["D"]);
		}
	}

	size_t parameterLength(in MemberVariable mv) {
		expect(mv.type, "MemberVariable of name", mv.name, " has no type");
		expect("D" in mv.type.typeToLanguage, "MemberVariable.type",
			"has no entry for key", "D"
		);
		return mv.type.typeToLanguage["D"].length + mv.name.length + 2;
	}

	size_t parameterLength(in Composition mv) {
		expect(mv.fromType, "Composition of name", mv.name, " has no type");
		expect("D" in mv.fromType.typeToLanguage, "Composition.fromType",
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
