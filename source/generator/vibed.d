module generator.vibed;

import std.experimental.logger;
import generator;
import model;
import std.array : empty, front;
import std.meta : AliasSeq;

import containers.dynamicarray;

class VibeD : Generator {
	import std.exception : enforce;
	import std.typecons : Rebindable, Flag;
	import std.stdio : stdout;
	import std.uni : toLower;
	import util;

	const(string) outputDir;
	DynamicArray!string outDirPath;
	EntityHashSet!Entity con;
	Rebindable!(const Container) curCon;

	this(in TheWorld world, in string outputDir) {
		super(world);
		this.outputDir = outputDir;
		this.outDirPath.insert(outputDir);
		enforce(Generator.createFolder(outputDir));
	}

	override void generate() {
		foreach(const(string) ssK, const(SoftwareSystem) ss;
				this.world.softwareSystems) 
		{
			foreach(const(string) conK, const(Container) con; ss.containers) {
				if(con.technology == "D") {
					this.generate(con);
				}
			}
		}

		foreach(const(string) conK, const(Entity) con; this.world.connections)
		{
			if(auto agg = cast(const(Aggregation))con) {
				auto ltw = stdout.lockingTextWriter();
				this.generate(ltw, agg);
			}
		}
	}

	void generate(Out)(ref Out ltw, in Aggregation agg) {
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

	void generate(in Container con) {
		this.curCon = con;
		this.con.clear();
		this.con.insert(cast(Entity)con);

		auto ltw = stdout.lockingTextWriter();
		foreach(const(string) cn, const(Component) com; con.components) {
			this.generate(ltw, com);
		}

		foreach(const(string) cn, const(Class) cls; con.classes) {
			this.generate(ltw, cls);
		}
	}

	void generate(Out)(ref Out ltw, in Component com) {
		this.outDirPath.insert(com.name);
		scope(exit) removeBack(this.outDirPath);
		createFolder(this.outDirPath);

		foreach(const(string) cn, const(Component) scom; com.subComponents) {
			this.generate(ltw, scom);
		}

		foreach(const(string) cn, const(Class) cls; com.classes) {
			this.generate(ltw, cls);
		}
	}

	void generateImports(Out)(ref Out ltw, in Class cls) {
		assert(cls !is null);
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

	void generateImport(Out)(ref Out ltw, in Class cls) {
		import std.string : indexOf;
		auto name = holdsContainerNameTrim(cls.pathsToRoot());
		auto dot = name.indexOf('.');
		if(dot != -1) {
			name = name[dot+1 .. $];
		}
		format(ltw, 0, "import %s;\n", toLower(name));
	}

	void generateModuleDecl(Out)(ref Out ltw, in Entity en) {
		format(ltw, 0, "module ");
		bool first = true;
		if(this.outDirPath.length > 0) {
			foreach(it; this.outDirPath[1 .. $]) {
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

	void generateCompositionImports(Out)(ref Out ltw, in Class cls) {
		foreach(const(string) key, const(Entity) con; this.world.connections)
		{
			if(auto cImpl = cast(const Composition)con) {
				if(cImpl.to is cls) {
					//logf("%s %s", cls.name, cImpl.from.name);
					this.generateImport(ltw, cast(const Class)cImpl.from);
				}
			}
		}
	}

	void generate(Out)(ref Out ltw, in Class cls) {
		import std.range : isInputRange;

		expect(cls !is null, "Class must not be null.");
		generateModuleDecl(ltw, cls);
		generateImports(ltw, cls);
		format(ltw, 0, "\n");

		generate(ltw, cast(ProtectedEntity)cls);
		format(ltw, 0, "%s %s {\n", cls.containerType.get("D", "class"), 
			cls.name
		);

		auto mvs = MemRange!(const(MemberVariable))(cls.members);
		foreach(mv; mvs) {
			this.generate(ltw, cast(const(ProtectedEntity))(mv), 1);
			chain(
				chain(
					this.generate(ltw, cast(const(Type))(mv.type)),
					"In Member with name", mv.name, "."
				),
				"In Class with name", cls.name, "."
			);

			format(ltw, 0, "%s;\n", mv.name);
		}

		format(ltw, 0, "\n");
		generateCtor(ltw, cls, FilterConst.no);
		generateCtor(ltw, cls, FilterConst.yes);
		generateMemberFunction(ltw, cls);
		generateToStr(ltw, cls);

		format(ltw, 0, "}\n");
	}

	void generateMemberFunction(Out)(ref Out ltw, in Class cls) {
		expect(cls !is null, "Class must not be null.");

		foreach(mv; MemRange!(const(MemberFunction))(cls.members)) {
			format(ltw, 1, "");
			chain(
				chain(
					this.generate(ltw, cast(const(Type))(mv.returnType)),
					"In Member with name", mv.name, "."
				),
				"In Class with name", cls.name, "."
			);

			format(ltw, 0, "%s(", mv.name);
			bool first = true;
			foreach(pa; mv.parameter) {
				chain(
					chain(
						this.generate(ltw, cast(const(Type))(pa.type)),
						"In Member with name", mv.name, "."
					),
					"In Class with name", cls.name, "."
				);
				format(ltw, 0, "%s%s", !first ? "," : "", pa.name);
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

	void generateCtor(Out)(ref Out ltw, in Class cls, const FilterConst fc) {
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

		foreach(mv; MemRange!(const MemberVariable)(cls.members)) {
			if(fc == FilterConst.yes && isConst(mv)) {
				continue;
			}
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
		expect(type, "MemberVariable has no type");
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

	/*string pathToVibeRoot(string[] paths) {
		import std.algorithm.iteration : splitter;
		import std.array : array;
		foreach(it; paths) {
			string[] sp = it.splitter(".").array;
			logf("%s, %s", it, sp);
			if(sp.length > 1) {
				auto en = this.world.get(sp[0 .. 2]);
				if(auto con = cast(const(Container))en) {
					if(con.technology == "D") {
						return it;
					}	
				}
			}
		}
		return "";
	}*/
}
