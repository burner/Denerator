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

	abstract void generateContainer(in Container con);
	abstract void generateComponent(in Component com);
	abstract void generateAggregation(LTW ltw, in Aggregation agg);
}
