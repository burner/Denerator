module language.postprocessing;

import language.peggedtoast;

private class Module {
	Class[] classes;
	Module[string] subModules;
	string moduleName;

	this(string modName) {
		this.moduleName = modName;
	}
}

abstract class ClassDiagramm {
	enum string defaultModuleName = "source";
	UMLCls uml;

	Module[string] modules;

	this(UMLCls uml) {
		this.uml = uml;
		this.modules[defaultModuleName] = new Module(defaultModuleName);
		this.genModules();
	}

	void genModules() {
		import std.string : lastIndexOf;
		import std.algorithm.iteration : splitter;
		import std.array : array;

		Module cur = this.modules[defaultModuleName];
		foreach(it; this.uml.classes) {
			foreach(jt; splitter(it.className, ".").array[0 .. $-1]) {
				if(jt !in cur.subModules) {
					cur.subModules[jt] = new Module(jt);
				}
				cur = cur.subModules[jt];
			}
			assert(cur !is null);
			cur.classes ~= it;
		}
	}

	abstract void generate();
}

import std.range : isOutputRange;

final class GraphVizClassDiagramm(Output) : ClassDiagramm 
	if(isOutputRange!(Output, dchar))
{
	import std.array : appender, empty;
	import std.algorithm.iteration : joiner, map, filter;
	import std.format : format;
	import std.range : chain;

	Output output;

	this(UMLCls uml, Output output) {
		super(uml);
		this.output = output;
	}

	override void generate() {
		this.genTopMatter();
		foreach(it; this.modules[defaultModuleName].subModules.byKey()) {
			this.genModules(this.modules[defaultModuleName].subModules[it], 1);
		}

		foreach(it; this.modules[defaultModuleName].classes) {
			this.genClass(it, 1);
		}

		this.genFinalMatter();
	}

	final void genIndent(in int indent) {
		for(int i = 0; i < indent; ++i) {
			this.output.put('\t');
		}
	}

	final void genModules(Module mod, in int indent) {
		this.genIndent(indent);
		this.output.put("subgraph cluster");
		this.output.put(mod.moduleName);
		this.output.put(" {\n");
		this.genIndent(indent + 1);
		this.output.put("style = \"folder\";\n");
		this.genIndent(indent + 1);
		this.output.formattedWrite("label = \"module %s\";\n", mod.moduleName);

		foreach(it; mod.subModules.byKey()) {
			this.genModules(mod.subModules[it], indent + 1);
		}

		foreach(it; mod.classes) {
			this.genClass(it, indent + 1);
		}

		this.genIndent(indent);
		this.output.put("}\n");
	}

	final static string fixClassName(string clsName) {
		import std.string : translate;
		dchar[dchar] tr = ['.':'_'];
		return translate(clsName, tr);
	}

	final void genClass(Class cls, in int indent) {
		this.genIndent(indent);
		this.output.formattedWrite("%s [\n", fixClassName(cls.className));
		this.genIndent(indent+1);
		this.output.put("label = \"{");
		this.output.put(cls.classType);
		this.output.put(" ");
		this.output.put(genClassLabel(cls));
		this.output.put("}\";\n");
		this.genIndent(indent);
		this.output.put("]\n");
	}

	final static string genClassLabel(Class cls) {
		import std.string : lastIndexOf;

		auto idx = cls.className.lastIndexOf('.');
		if(idx == -1) {
			idx = 0;
		} else {
			++idx;
		}
		
		auto app = appender!string();
		app.put(cls.className[idx .. $]);
		app.put("|");

		if(!cls.constraint.empty) {
			app.put("\\<");
			app.put(cls.constraint);
			app.put("\\>|\\n");
		}

		if(!cls.stereoTypes.empty) {
			app.put("\\<\\<");
			app.put(cls.stereoTypes.joiner(", "));
			app.put("\\>\\>|\\n");
		}

		auto ma = map!(function(Member a) { return genMember(a); })(cls.members);
		app.put(ma.joiner("|\\n"));

		return app.data;
	}

	final static void genType(Out)(Type type, Out output) {
		if(type.modifier !is null) {
			formattedWrite(output, "%s(", type.modifier.modifier);
		}
		if(!type.type.empty) {
			output.put(type.type);
		} else {
			assert(type.follow !is null);
			genType(type.follow, output);
		}

		if(type.modifier !is null) {
			output.put(")");
		}
	}

	final static string genTypeStr(Type type) {
		auto app = appender!string();
		genType(type, app);
		return app.data;
	}

	final static string genMemberFunction(MemberFunction mem) {
		auto app = appender!string();
		if(mem.protection != ' ') {
			app.formattedWrite("%s ", mem.protection);
		}

		genType(mem.type, app);
		app.formattedWrite(" %s ", mem.identifier);
		app.put("(");
		if(mem.parameterList !is null) {
			auto ma = map!(function(MemberVariable a) { 
				return genMemberVariable(a); 
			})(mem.parameterList.parameter);
			app.put(ma.joiner(", "));
		}
		app.put(")");
		if(!mem.notes.empty) {
			app.put(" /* ");
			auto nt = mem.notes.chain().map!(function(Note n) { return n.str.joiner();});
			app.put(nt.joiner(" ").filter!(a => (a != '\n' && a != '\t')));
			app.put(" */");
		}

		return app.data;
	}

	final static string genMemberVariable(MemberVariable mem) {
		return format("%s : %s%s%s%s", mem.identifier, genTypeStr(mem.type),
			mem.notes !is null ? " /* " : "",
			mem.notes.chain().map!(function(Note n) { return n.str.joiner();})
				.joiner(" ").filter!(a => (a != '\n' && a != '\t')),
			mem.notes !is null ? " */" : ""
		);
	}

	final static string genMember(Member mem) {
		MemberFunction mf = cast(MemberFunction)mem;
		if(mf !is null) {
			return genMemberFunction(mf);
		} 

		MemberVariable mv = cast(MemberVariable)mem;
		if(mv !is null) {
			return genMemberVariable(mv);
		} 

		MemberSeperator ms = cast(MemberSeperator)mem;
		assert(ms !is null);

		if(!ms.notes.empty) {
			return ms.seperatorText;
		}

		assert(false);
	}

	final void genTopMatter() {
		this.output.put(`
graph G {
	fontname = "Bitstream Vera Sans"
	fontsize = 8

	node [
		fontname = "Bitstream Vera Sans"
		fontsize = 8
		shape = "record"
	]

	edge [
		fontname = "Bitstream Vera Sans"
		fontsize = 8
	]
`
		);
	}

	final void genFinalMatter() {
		this.output.put("}\n");
	}
}
