module generator.graphviz2;

import std.exception : enforce;
import std.experimental.logger;

import generator;
import model;

import graph;
import writer;

class Graphvic2 : Generator {
	import std.format : format, formattedWrite;
	import std.algorithm.iteration : map, joiner;

	Graph g;
	const(string) outputDir;

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
		StringHashSet names;
		this.addActors(g, names);
		this.addContainers(g, names);

		auto f = Generator.createFile([this.outputDir, "systemcontext.dot"]);
		auto ltw = f.lockingTextWriter();
		auto writer = new Writer!(typeof(ltw))(g, ltw);
	}

	void addActors(Graph g, ref StringHashSet names) {
		foreach(key; this.world.actors.keys()) {
			this.addActor(this.world.actors[key], g);
			names.insert(key);
		}
	}

	Node addActor(in Actor act, Graph g) {
		Node n = g.get!Node(act.name);
		auto tmp = wrapLongString(act.description, 40)
				.map!(a => format("<tr><td>%s</td></tr>", a)).joiner("\n");
		n.shape = "none";
		n.label = `<<table border="0" cellborder="0">
			<tr><td><img src="../Stick.png"/></td></tr>
			<tr><td>%s</td></tr>
			%s
			</table>>`
		.format(act.name, tmp);

		return n;
	}

	void addContainers(Graph g, ref StringHashSet names) {
		foreach(key; this.world.softwareSystems.keys()) {
			this.addContainer(this.world.softwareSystems[key], g);
			names.insert(key);
		}
		
		foreach(key; this.world.hardwareSystems.keys()) {
			this.addContainer(this.world.hardwareSystems[key], g);
			names.insert(key);
		}
	}

	Node addContainer(in SoftwareSystem ss, Graph g) {
		return addContainerImpl(ss, g, "SoftwareSystem");
	}

	Node addContainer(in HardwareSystem hs, Graph g) {
		return addContainerImpl(hs, g, "HardwareSystem");
	}

	private static Node addContainerImpl(in Entity en, Graph g, 
			in string type) 
	{
		Node n = g.get!Node(en.name);
		auto tmp = wrapLongString(en.description, 40)
				.map!(a => format("<tr><td>%s</td></tr>", a)).joiner("\n");
		n.shape = "box";
		n.label = `<<table border="0" cellborder="0">
			<tr><td>%s</td></tr>
			<tr><td>[%s]</td></tr>
			%s
			</table>>`
		.format(en.name, type, tmp);

		return n;
	}

	void addEdges(Graph g, in ref StringHashSet names) {
		foreach(key; this.world.connections.keys()) {
			this.addEdge(g, cast(ConnectionImpl)this.world.connections[key], 
				names
			);
		}
	}

	Edge addEdge(Graph g, in ConnectionImpl con, in ref StringHashSet names) {
		assert(con !is null);
		assert(false);
	}
}
