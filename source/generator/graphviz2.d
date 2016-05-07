module generator.graphviz2;

import std.exception : enforce;
import std.experimental.logger;

import generator;
import model;

import graph;
import writer;

alias EntitySet = EntityHashSet!(Entity);

class Graphvic2 : Generator {
	import std.format : format, formattedWrite;
	import std.algorithm.iteration : map, joiner;
	import std.typecons : scoped;

	const(string) outputDir;

	this(in TheWorld world, in string outputDir) {
		super(world);
		this.outputDir = outputDir;
		enforce(Generator.createFolder(outputDir));
	}

	override void generate() {
		this.generateMakefile();
		this.generateSystemContext();
		this.generateSystemContainers();
		this.generateSoftwareSystemsContainerComponents();
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
		EntitySet names;
		this.addActors(g, names);
		this.addSystems!Node(g, names);
		this.addEdges(g, names, 1);

		auto f = Generator.createFile([this.outputDir, "systemcontext.dot"]);
		auto ltw = f.lockingTextWriter();
		auto writer = scoped!(Writer!(typeof(ltw)))(g, ltw);
	}

	void generateSystemContainers() {
		Graph g = new Graph();
		EntitySet names;
		this.addActors(g, names);
		this.addSystems!SubGraph(g, names);
		this.addEdges(g, names, 3);

		auto f = Generator.createFile([this.outputDir,
			"systemcontextcontainers.dot"]
		);
		auto ltw = f.lockingTextWriter();
		auto writer = scoped!(Writer!(typeof(ltw)))(g, ltw);
	}

	void generateSoftwareSystemsContainerComponents() {
		foreach(ssKey; this.world.softwareSystems.keys()) {
			const(SoftwareSystem) ss = this.world.softwareSystems[ssKey];

			Graph g = new Graph();
			EntitySet names;

			if(ss.containers.empty) {
				this.addSystem!Node(g, ss);
				names.insert(cast(Entity)(ss));
			} else {
				auto sg = this.addSystem!SubGraph(g, ss);
				names.insert(cast(Entity)(ss));

				foreach(conKey; ss.containers.keys()) {
					const(Container) con = ss.containers[conKey];
					if(con.components.empty) {
						this.addContainer!Node(sg, con, names);
					} else {
						auto conSg = this.addContainer!SubGraph(sg, con, names);

						foreach(comKey; con.components.keys()) {
							const(Component) com = con.components[comKey];
							this.addComponent!Node(conSg, com, names);
						}
					}
				}
			}
			auto f = Generator.createFile([this.outputDir, ssKey ~ ".dot"]);
			auto ltw = f.lockingTextWriter();
			auto writer = scoped!(Writer!(typeof(ltw)))(g, ltw);
		}
	}

	void addActors(Graph g, ref EntitySet names) {
		foreach(key; this.world.actors.keys()) {
			this.addActor(g, this.world.actors[key]);
			names.insert(cast(Entity)(this.world.actors[key]));
		}
	}

	Node addActor(Graph g, in Actor act) {
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

	void addSystems(T)(Graph g, ref EntitySet names) {
		foreach(key; this.world.softwareSystems.keys()) {
			const(SoftwareSystem) ss = this.world.softwareSystems[key];
			auto sg = this.addSystem!T(g, ss);
			names.insert(cast(Entity)(ss));

			static if(is(T == SubGraph)) {
				foreach(comKey; ss.containers.keys()) {
					auto com = ss.containers[comKey];
					auto consg = this.addContainer!Node(sg, com, names);
				}
			}
		}
		
		foreach(key; this.world.hardwareSystems.keys()) {
			this.addSystem!Node(g, this.world.hardwareSystems[key]);
			names.insert(cast(Entity)(this.world.hardwareSystems[key]));
		}
	}

	T addSystem(T)(Graph g, in SoftwareSystem ss) {
		return addSystemImpl!T(g, ss, "SoftwareSystem");
	}

	T addSystem(T)(Graph g, in HardwareSystem hs) {
		return addSystemImpl!T(g, hs, "HardwareSystem");
	}

	private static T addSystemImpl(T)(Graph g, in Entity en, 
			in string type) 
	{
		T n = g.get!T(en.name);
		n.shape = "box";
		n.label = `<<table border="0" cellborder="0">
			<tr><td>%s</td></tr>
			<tr><td>[%s]</td></tr>
			%s
			</table>>`
		.format(en.name, type, buildLabelFromDescription(en));

		return n;
	}

	private T addContainer(T)(SubGraph sg, in Container com, 
			ref EntitySet names) 
	{
		T n = sg.get!T(com.name);
		n.shape = "box";
		n.label = `<<table border="0" cellborder="0">
			<tr><td>%s</td></tr>
			%s
			</table>>`
		.format(com.name, buildLabelFromDescription(com));

		return n;
	}

	private T addComponent(T)(SubGraph sg, in Component com,
			ref EntitySet names)
	{
		T n = sg.get!T(com.name);
		n.shape = "box";
		n.label = `<<table border="0" cellborder="0">
			<tr><td>%s</td></tr>
			<tr><td>[Component]</td></tr>
			%s
			</table>>`
		.format(com.name, buildLabelFromDescription(com));

		return n;
	}

	private static auto buildLabelFromDescription(in Entity en) {
		return wrapLongString(en.description, 40)
			.map!(a => format("<tr><td>%s</td></tr>", a)).joiner("\n");
	}

	void addEdges(Graph g, in ref EntitySet names, in uint deapth) {
		import std.algorithm.iteration : splitter;
		import std.algorithm.comparison : equal, min;
		import std.array : array;

		foreach(key; this.world.connections.keys()) {
			ConnectionImpl con = cast(ConnectionImpl)this.world.connections[key];
			assert(con !is null);

			const(Entity) from = con.from.areYouIn(names);
			const(Entity) to = con.to.areYouIn(names);
			if(from is null && to is null && from is to && from is to) {
				log();
				continue;
			}
			logf("\n\t%s %s\n\t%s %s", con.from.name, con.to.name, 
				from.name, to.name
			);
			string fromSStr = con.from.pathToRoot();
			string toSStr = con.to.pathToRoot();
			string[] fromS = splitter(fromSStr, ".").array;
			string[] toS = splitter(toSStr, ".").array;

			logf("\n\t%s %s %s %s", fromSStr, toSStr, fromS, toS);
			fromS = fromS[0 .. min(fromS.length, deapth)];
			toS = toS[0 .. min(toS.length, deapth)];

			if(fromS.equal(toS)) {
				continue;			
			}

			this.addEdge(g, con, names);
		}
	}

	Edge addEdge(Graph g, in ConnectionImpl con, 
			in ref EntityHashSet!Entity names) 
	{
		if(auto c = cast(const Dependency)con) {
			return this.addDependency(g, c, names);
		} else if(auto c = cast(const Connection)con) {
			return this.addConnection(g, c, names);
		} else if(auto c = cast(const Aggregation)con) {
			return this.addAggregation(g, c, names);
		} else if(auto c = cast(const Composition)con) {
			return this.addComposition(g, c, names);
		} else if(auto c = cast(const Generalization)con) {
			return this.addGeneralization(g, c, names);
		} else if(auto c = cast(const Realization)con) {
			return this.addRealization(g, c, names);
		} else {
			assert(false);
		}
	}

	Edge addDependency(Graph g, in Dependency con,
		   	in ref EntityHashSet!Entity names)
	{
		Edge e = this.addConnectionImpl(g, con, names);
		e.edgeStyle = "dashed";
		e.arrowStyleTo = "vee";
		return e;
	}

	Edge addConnection(Graph g, in Connection con,
		   	in ref EntityHashSet!Entity names)
	{
		Edge e = this.addConnectionImpl(g, con, names);
		return e;
	}

	Edge addAggregation(Graph g, in Aggregation con,
		   	in ref EntityHashSet!Entity names)
	{
		Edge e = this.addConnectionImpl(g, con, names);
		e.arrowStyleTo = "odiamond";
		e.labelFrom = connectionCountToString(con.fromCnt);
		e.labelTo = connectionCountToString(con.toCnt);
		return e;
	}

	Edge addComposition(Graph g, in Composition con,
		   	in ref EntityHashSet!Entity names)
	{
		Edge e = this.addConnectionImpl(g, con, names);
		e.arrowStyleTo = "diamond";
		e.labelFrom = connectionCountToString(con.fromCnt);
		return e;
	}

	Edge addGeneralization(Graph g, in Generalization con,
		   	in ref EntityHashSet!Entity names)
	{
		Edge e = this.addConnectionImpl(g, con, names);
		e.arrowStyleTo = "empty";
		return e;
	}

	Edge addRealization(Graph g, in Realization con,
		   	in ref EntityHashSet!Entity names)
	{
		Edge e = this.addConnectionImpl(g, con, names);
		e.arrowStyleTo = "empty";
		return e;
	}

	Edge addConnectionImpl(Graph g, in ConnectionImpl con,
		   	in ref EntityHashSet!Entity names)
	{
		auto toRoot = con.from.pathToRoot();
		auto fromRoot = con.to.pathToRoot();
		logf("%s:\n'%s' '%s'\n'%s' '%s'", con.name, 
			con.from.name, con.to.name, toRoot, fromRoot);
		Edge ret = g.get!Edge(con.name, toRoot, fromRoot);
		ret.label = format("<<table border=\"0\" cellborder=\"0\">\n%s</table>>",
			buildLabelFromDescription(con)
		);
		return ret;
	}

	private static string connectionCountToString(ref in ConnectionCount cc) {
		import std.array : appender, empty;

		if(cc.low == -1 && cc.high == -1) {
			return "";
		}

		auto app = appender!string();
		if(cc.low == -2) {
			app.put("*");
		} else if(cc.low <= 0) {
			formattedWrite(app, "%s", cc.low);
		}

		if(!app.data.empty) {
			app.put("..");
		}

		if(cc.high == -2) {
			app.put("*");
		} else if(cc.high <= 0) {
			formattedWrite(app, "%s", cc.high);
		}

		return app.data;
	}
}
