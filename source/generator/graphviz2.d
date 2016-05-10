module generator.graphviz2;

import std.exception : enforce;
import std.experimental.logger;

import generator;
import model;

import graph;
import writer;

alias EntitySet = EntityHashSet!(Entity);

class Graphvic2 : Generator {
	import std.array : array, empty;
	import std.format : format, formattedWrite;
	import std.algorithm.iteration : map, joiner, splitter;
	import std.typecons : scoped, Rebindable;

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
		foreach(const(string) ssKey, const(SoftwareSystem) ss;
				this.world.softwareSystems)
		{
			Graph g = new Graph();
			EntitySet names;

			if(ss.containers.empty) {
				this.addSystem!Node(g, ss);
				names.insert(cast(Entity)(ss));
			} else {
				auto sg = this.addSystem!SubGraph(g, ss);
				names.insert(cast(Entity)(ss));

				foreach(const(string) conKey, const(Container) con;
						ss.containers) 
				{
					if(con.components.empty) {
						this.addContainer!Node(sg, con, names);
					} else {
						auto conSg = this.addContainer!SubGraph(sg, con, names);

						foreach(const(string) comKey, const(Component) com;
								con.components)
						{
							this.addComponent!Node(conSg, com, names);
						}
					}
				}
			}
			this.addEdgesToSSCC(g, ss, names);
			auto f = Generator.createFile([this.outputDir, ssKey ~ ".dot"]);
			auto ltw = f.lockingTextWriter();
			auto writer = scoped!(Writer!(typeof(ltw)))(g, ltw);
		}
	}

	void addEdgesToSSCC(Graph g, in SoftwareSystem ss, ref EntitySet names) {
		foreach(edgeKey; this.world.connections.keys()) {
			const(ConnectionImpl) con = 
				cast(const(ConnectionImpl))this.world.connections[edgeKey];

			assert(con !is null);
			Rebindable!(const Entity) fromEn = con.from.areYouIn(names);
			Rebindable!(const Entity) toEn = con.to.areYouIn(names);
			if(fromEn !is null || toEn !is null) {
				logf("\n\t'%s' '%s' '%s'\n\t'%s' '%s'", con.name, con.from.name,
					con.to.name,
					fromEn !is null ? fromEn.name : "", 
					toEn !is null ? toEn.name : ""
				);

				if(fromEn is null) {
					fromEn = this.getAndAddTopLevel(g, con.from, names);
				} else if(toEn is null) {
					toEn = this.getAndAddTopLevel(g, con.to, names);
				}
				//logf("'%s' '%s'", fromToRoot, toToRoot);
			}
		}
		this.addEdges(g, names, uint.max);
	}

	const(Entity) getAndAddTopLevel(Graph g, const(Entity) en, 
			ref EntitySet names) 
	{
		auto pathToRoot = en.pathToRoot();
		assert(!pathToRoot.empty);

		string top = splitter(pathToRoot, ".").array[0];

		const(SearchResult) searchResult = this.world.search(en);
		if(cast(const Actor)(searchResult.entity) !is null) {
			this.addActor(g, cast(const Actor)searchResult.entity);
			names.insert(cast(Entity)searchResult.entity);
		} else if(cast(const SoftwareSystem)(searchResult.entity) !is null) {
			this.addSystem!Node(g, cast(const SoftwareSystem)searchResult.entity);
			names.insert(cast(Entity)searchResult.entity);
		} else if(cast(const HardwareSystem)(searchResult.entity) !is null) {
			this.addSystem!Node(g, cast(const HardwareSystem)searchResult.entity);
			names.insert(cast(Entity)searchResult.entity);
		}

		return searchResult.entity;
	}

	void addActors(Graph g, ref EntitySet names) {
		foreach(const(string) key, const(Actor) act; this.world.actors) {
			this.addActor(g, act);
			names.insert(cast(Entity)act);
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
		foreach(const(string) key, const(SoftwareSystem) ss;
				this.world.softwareSystems)
		{
			auto sg = this.addSystem!T(g, ss);
			names.insert(cast(Entity)(ss));

			static if(is(T == SubGraph)) {
				foreach(const(string) comKey, const(Container) com;
						ss.containers)
				{
					auto consg = this.addContainer!Node(sg, com, names);
				}
			}
		}
		
		foreach(const(string) key, const(HardwareSystem) hws;
				this.world.hardwareSystems)
		{
			this.addSystem!Node(g, hws);
			names.insert(cast(Entity)(hws));
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
			<tr><td>[%s]</td></tr>
			%s
			</table>>`
		.format(com.name, com.technology,
			buildLabelFromDescription(com)
		);

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
		import std.algorithm.comparison : equal, min;

		foreach(key; this.world.connections.keys()) {
			ConnectionImpl con = cast(ConnectionImpl)this.world.connections[key];
			assert(con !is null);

			const(Entity) from = con.from.areYouIn(names);
			const(Entity) to = con.to.areYouIn(names);
			if(from is null || to is null 
					|| (from is to && con.from is con.to)) 
			{
				logf("\n\t%s %s", con.from.name, con.to.name);
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
				logf("\n\t%s %s", fromS, toS);
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
		import std.array : appender;

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