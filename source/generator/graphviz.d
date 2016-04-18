module generator.graphviz;

import std.array : empty;
import std.exception : enforce;
import std.format : formattedWrite;
import std.algorithm.iteration : map;

import generator;
import model;

class Graphvic : Generator {
	const(string) outputDir;
	this(in TheWorld world, in string outputDir) {
		super(world);
		this.outputDir = outputDir;
		enforce(Generator.createFolder(outputDir));
	}

	override void generate() {
		this.generateWorld();
	}

	void generateWorld() {
		auto f = Generator.createFile([this.outputDir, "theworld.dot"]);
		auto ltw = f.lockingTextWriter();
		generateTopMatter(ltw);

		ltw.generateActors(this.world.actors);

		ltw.put("}\n");
	}

}

private void generateIndent(O)(ref O output, int indent) {
	for(; indent > 0; --indent) {
		output.put("\t");
	}
}

private void generateTopMatter(O)(ref O output) {
	output.put(
`digraph G {
	fontname = "Bitstream Vera Sans"
	fontsize = 10
`
	);
}

private void generateActors(O)(ref O output, 
		in ref StringEntityMap!(Actor) actors) 
{
	auto keys = actors.keys();
	foreach(it; keys) {
		generateActor(output, actors[it]);
	}
}

private void generateActor(O)(ref O output, in Actor actor) {
	generateIndent(output, 1);	
	output.formattedWrite("%s [\n", actor.name);
	generateIndent(output, 2);	
	output.formattedWrite("shape=none;\n");
	generateIndent(output, 2);	
	output.formattedWrite("label = <\n");
	generateIndent(output, 3);	
	output.formattedWrite("<table border=\"0\" cellborder=\"0\">\n");
	generateIndent(output, 3);	
	output.formattedWrite("<tr><td><img src=\"Stick.png\"/></td></tr>\n");
	generateIndent(output, 3);	
	output.formattedWrite("<tr><td>%s</td></tr>\n", actor.name);
	
	if(!actor.description.empty) {
		generateIndent(output, 3);	
		output.formattedWrite("<tr><td>%s</td></tr>\n", actor.description);
	}

	generateIndent(output, 3);	
	output.formattedWrite("</table>\n");
	generateIndent(output, 2);	
	output.formattedWrite(">\n");
	generateIndent(output, 1);	
	output.put("]\n");
}
