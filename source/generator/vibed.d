module generator.vibed;

import generator;
import model;

class Graphviz : Generator {
	import std.exception : enforce;

	const(string) outputDir;

	this(in TheWorld world, in string outputDir) {
		super(world);
		this.outputDir = outputDir;
		enforce(Generator.createFolder(outputDir));
	}

	override void generate() {
	}
}
