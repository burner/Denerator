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

		ltw.generate!Actor(this.world.actors);
		ltw.generate!SoftwareSystem(this.world.softwareSystems);

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

private void generate(T,O)(ref O output, 
		in ref StringEntityMap!(T) map) 
{
	auto keys = map.keys();
	foreach(it; keys) {
		static if(is(T == Actor)) {
			generateActor(output, map[it]);
		} else static if(is(T == SoftwareSystem)) {
			generateSoftwareSystem(output, map[it]);
		}
	}
}

private void generateActor(O)(ref O output, in Actor actor) {
	generateIndent(output, 1);	
	output.formattedWrite("%s [\n", prepareName(actor.name));
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
		string[] wrapped = wrapLongString(actor.description, 40);
		foreach(str; wrapped) {
			generateIndent(output, 3);	
			output.formattedWrite("<tr><td>%s</td></tr>\n", str);
		}
	}

	generateIndent(output, 3);	
	output.formattedWrite("</table>\n");
	generateIndent(output, 2);	
	output.formattedWrite(">\n");
	generateIndent(output, 1);	
	output.put("]\n");
}

private void generateSoftwareSystem(O)(ref O output, in SoftwareSystem ss) {
	generateIndent(output, 1);	
	output.formattedWrite("%s [\n", prepareName(ss.name));
	generateIndent(output, 2);	
	output.formattedWrite("shape=box;\n");
	generateIndent(output, 2);	
	output.formattedWrite("label = <\n");
	generateIndent(output, 3);	
	output.formattedWrite("<table border=\"0\" cellborder=\"0\">\n");
	generateIndent(output, 3);	
	output.formattedWrite("<tr><td>%s</td></tr>\n", ss.name);
	generateIndent(output, 3);	
	output.formattedWrite("<tr><td>[Software System]</td></tr>\n");
	
	if(!ss.description.empty) {
		string[] wrapped = wrapLongString(ss.description, 40);
		foreach(str; wrapped) {
			generateIndent(output, 3);	
			output.formattedWrite("<tr><td>%s</td></tr>\n", str);
		}
	}

	generateIndent(output, 3);	
	output.formattedWrite("</table>\n");
	generateIndent(output, 2);	
	output.formattedWrite(">\n");
	generateIndent(output, 1);	
	output.put("]\n");
}
