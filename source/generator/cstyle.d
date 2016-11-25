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

	alias FilterConst = Flag!"FilterConst";

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

	override void generate(string technology) {
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

	override string genFileName(const(Class) cls) {
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
			auto f = createFile(this.outDirPath[], this.genFileName(cls), "w");
			auto ltw = f.lockingTextWriter();
			this.generateClass(ltw, cls);
		}
	}

	abstract void generateAggregation(LTW ltw, in Aggregation agg);
	abstract void generateClass(LTW ltw, const(Class) cls);
}
