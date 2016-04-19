module generator.graphviz;

import std.array : empty;
import std.exception : enforce;
import std.format : formattedWrite;
import std.algorithm.iteration : map;
import std.stdio : writeln;

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
		import std.range : chain;
		auto f = Generator.createFile([this.outputDir, "theworld.dot"]);
		auto ltw = f.lockingTextWriter();
		generateTopMatter(ltw);

		ltw.generate!Actor(this.world.actors);
		ltw.generate!SoftwareSystem(this.world.softwareSystems);
		ltw.generate!HardwareSystem(this.world.hardwareSystems);

		StringHashSet names;
		foreach(it; chain(this.world.actors.keys(),
				this.world.softwareSystems.keys(),
				this.world.hardwareSystems.keys()))
		{
			names.insert(it);
		}

		this.generateWorldConnections(ltw, names);

		ltw.put("}\n");
	}

	void generateWorldConnections(O)(ref O output, 
			ref in StringHashSet publicNames) 
	{
		auto keys = super.world.connections.keys();
		foreach(it; keys) {
			auto con = cast(ConnectionImpl)super.world.connections[it];
			writeln(con.name);
			assert(con.from !is null);
			assert(con.to !is null);

			immutable fromName = con.from.areYouIn(publicNames);
			immutable toName = con.to.areYouIn(publicNames);

			if(!fromName.empty && !toName.empty) {
				output.format(1, "%s -> %s", prepareName(fromName),
					prepareName(toName)
				);
				if(con.description.empty) {
					output.put(";\n");
				} else {
					output.formattedWrite(" [label = <\n");
					output.format(2, "<table border=\"0\" cellborder=\"0\">\n");

					string[] wrapped = wrapLongString(con.description, 20);
					foreach(str; wrapped) {
						output.format(2, "<tr><td align=\"left\">%s</td></tr>\n", str);
					}
					output.format(2, "</table>\n");
					
					output.format(1, ">];\n");
				}
			}
		}
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
		} else static if(is(T == HardwareSystem)) {
			generateHardwareSystem(output, map[it]);
		}
	}
}

private void generateActor(O)(ref O output, in Actor actor) {
	output.format(1, "%s [\n", prepareName(actor.name));
	output.format(2, "shape=none;\n");
	output.format(2, "label = <\n");
	output.format(3, "<table border=\"0\" cellborder=\"0\">\n");
	output.format(3, "<tr><td><img src=\"Stick.png\"/></td></tr>\n");
	output.format(3, "<tr><td>%s</td></tr>\n", actor.name);
	
	if(!actor.description.empty) {
		string[] wrapped = wrapLongString(actor.description, 40);
		foreach(str; wrapped) {
			output.format(3, "<tr><td>%s</td></tr>\n", str);
		}
	}

	output.format(3, "</table>\n");
	output.format(2, ">\n");
	output.format(1, "]\n");
}

private void generateSoftwareSystem(O)(ref O output, in SoftwareSystem ss) {
	output.format(1, "%s [\n", prepareName(ss.name));
	output.format(2, "shape=box;\n");
	output.format(2, "label = <\n");
	output.format(3, "<table border=\"0\" cellborder=\"0\">\n");
	output.format(3, "<tr><td>%s</td></tr>\n", ss.name);
	output.format(3, "<tr><td>[Software System]</td></tr>\n");
	
	if(!ss.description.empty) {
		string[] wrapped = wrapLongString(ss.description, 40);
		foreach(str; wrapped) {
			output.format(3, "<tr><td align=\"left\">%s</td></tr>\n", str);
		}
	}

	output.format(3, "</table>\n");
	output.format(2, ">\n");
	output.format(1, "]\n");
}

private void generateHardwareSystem(O)(ref O output, in HardwareSystem ss) {
	output.format(1, "%s [\n", prepareName(ss.name));
	output.format(2, "shape=box;\n");
	output.format(2, "label = <\n");
	output.format(3, "<table border=\"0\" cellborder=\"0\">\n");
	output.format(3, "<tr><td>%s</td></tr>\n", ss.name);
	output.format(3, "<tr><td>[Hardware System]</td></tr>\n");
	
	if(!ss.description.empty) {
		string[] wrapped = wrapLongString(ss.description, 40);
		foreach(str; wrapped) {
			output.format(3, "<tr><td align=\"left\">%s</td></tr>\n", str);
		}
	}

	output.format(3, "</table>\n");
	output.format(2, ">\n");
	output.format(1, "]\n");
}
