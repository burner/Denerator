module generator.cstyle;

import std.stdio;
public import std.experimental.logger;
public import generator;
public import model;

alias LTW = File.LockingTextWriter;

abstract class CStyle : Generator {
	import std.exception : enforce;
	import std.typecons : Rebindable, Flag;
	import std.container.array : Array;
	import std.file : getcwd;
	import std.uni : toLower;
	import util;
	import exceptionhandling;

	alias FilterConst = Flag!"FilterConst";

	const(string) outputDir;
	Array!string outDirPath;
	EntityHashSet!Entity con;
	Rebindable!(const Container) curCon;
	string technology;

	this(in TheWorld world, in string outputDir) {
		super(world);
		this.outputDir = outputDir;
		this.outDirPath.insertBack(outputDir);
		this.outDirPath.insertBack("source");
		logf("%s [%(%s %)]", getcwd(), this.outDirPath[]);
		enforce(Generator.createFolder(outputDir));
	}

	override void generate(string technology) {
		this.technology = technology;
		foreach(const(string) ssK, const(SoftwareSystem) ss;
				this.world.softwareSystems) 
		{
			foreach(const(string) conK, const(Container) con; ss.containers) {
				if(con.technology == technology) {
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

	string genFileName(const(Class) cls) {
		return toLower(cls.name) ~ ".d";
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
			auto f = createFile(this.outDirPath[], this.genFileName(cls), "w");
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
			if(cls.doNotGenerate == DoNotGenerate.no) {
				logf("cls name %s", cls.name);
				auto f = createFile(this.outDirPath[], this.genFileName(cls), "w");
				auto ltw = f.lockingTextWriter();
				this.generateClass(ltw, cls);
			}
		}
	}

	void generateLangSpecificAttributes(Out)(ref Out ltw, const(Member) mem,
			const int indent = 0)
	{
		ensure(mem !is null, "Member is null");
		if(this.technology in mem.langSpecificAttributes) {
			First first;

			foreach(attri; mem.langSpecificAttributes[this.technology]) {
				first(
					(){format(ltw, indent, "%s", attri);},
					(){format(ltw, 0, " %s", attri);}
				);
			}
		}
	}

	void generateType(Out)(ref Out ltw, in Type type, in int indent = 0) {
		ensure(type !is null, "Type is null");
		if(auto cls = cast(const(Class))type) {
			format(ltw, indent, "%s", cls.name);
		} else {
			ensure(this.technology in type.typeToLanguage, "Variable type\"",
				type.name, "\"has no typeToLanguage entry for key",
				this.technology
			);
			format(ltw, indent, "%s", type.typeToLanguage[this.technology]);
		}
	}

	void generateProtectedEntity(Out)(Out ltw, in ProtectedEntity pe,
		   	in int indent = 0) 
	{
		if(this.technology in pe.protection) {
			format(ltw, indent, "%s ", pe.protection[this.technology]);
		} else if(indent > 0) {
			format(ltw, indent, "");
		}
	}

	bool isConst(const ProtectedEntity mem) {
		import std.algorithm.searching : canFind;
		if(this.technology in mem.protection) {
			return canFind(mem.protection[this.technology], "const");
		} else {
			return false;
		}
	}

	bool areCtorsDifferent(const Class cls) {
		import std.algorithm.iteration : filter;
		import std.range.primitives : walkLength;
		return MemRange!(const MemberVariable)(cls.members)
				.filter!(a => !isConst(a))
				.walkLength 
			!= MemRange!(const MemberVariable)(cls.members)
					.walkLength;
	}

	abstract void generateAggregation(LTW ltw, in Aggregation agg);
	abstract void generateClass(LTW ltw, const(Class) cls);
}
