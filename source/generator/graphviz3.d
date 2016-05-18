module generator.graphviz3;

import std.exception : enforce;
import std.experimental.logger;

import generator;
import model;
import duplicator;

import graph;
import writer;

class Graphvic3 : Generator {
	import std.typecons : scoped, Rebindable;
	import std.format : format, formattedWrite;

	const(string) outputDir;
	string currentTechnologie;

	this(in TheWorld world, in string outputDir) {
		super(world);
		this.outputDir = outputDir;
		enforce(Generator.createFolder(outputDir));
	}

	override void generate() {
		this.generateMakefile();
		this.generateSystemContext();
	}

	void generateMakefile() {
		auto f = Generator.createFile([this.outputDir, "Makefile"]);
		auto ltw = f.lockingTextWriter();

		ltw.formattedWrite(
			"all: $(patsubst %%.dot,%%.png,$(wildcard *.dot))\n\n"
		);

		ltw.formattedWrite("%%.png : %%.dot\n");
		ltw.formattedWrite("\tdot -T png $< -o $@");
	}

	void generateSystemContext() {
		Graph g = new Graph();
		TheWorld copy = duplicateNodes(this.world);

		StringHashSet empty;

		foreach(const(string) key, SoftwareSystem ss; copy.softwareSystems) {
			ss.drop(empty);
		}

		reAdjustEdges(this.world, copy);

		auto f = Generator.createFile([this.outputDir, "systemcontext.dot"]);
		auto ltw = f.lockingTextWriter();
		auto writer = scoped!(Writer!(typeof(ltw)))(g, ltw);
	}
}
