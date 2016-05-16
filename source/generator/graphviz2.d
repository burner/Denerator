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
	string currentTechnologie;

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
		this.generateContainerComponents();
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

	void generateContainerComponents() {
		foreach(const(string) key, const(SoftwareSystem) ss;
				this.world.softwareSystems)
		{
			foreach(const(string) conKey, const(Container) con;
					ss.containers)
			{
				this.currentTechnologie = con.technology;
				Graph g = new Graph();
				EntitySet names;

				if(con.components.empty && con.classes.empty) {
					this.addContainer!Node(g, con, names);
				} else {
					SubGraph conSG = this.addContainer!(SubGraph,Graph)
						(g, con, names);

					foreach(const(string) comKey, const(Component) com;
						con.components)
					{
						if(com.subComponents.length == 0 && com.classes.empty) {
							this.addComponent!Node(conSG, com, names);
						} else {
							this.addComponentRecursive(conSG, com, names);
						}
					}

					foreach(const(string) clsKey, const(Class) cls;
						con.classes)
					{
						this.addClass(conSG, cls, names);
					}
				}

				this.addEdgeToContainer(g, con, names);

				auto f = Generator.createFile([this.outputDir, 
					  key ~ '_' ~ conKey ~ ".dot"]);
				auto ltw = f.lockingTextWriter();
				auto writer = scoped!(Writer!(typeof(ltw)))(g, ltw);
			}
		}
	}

	void addEdgesToContainer(Graph g, in Container con, ref EntitySet names) {
		foreach(edgeKey; this.world.connections.keys()) {
			const(ConnectionImpl) con = 
				cast(const(ConnectionImpl))this.world.connections[edgeKey];

			assert(con !is null);
			assert(con !is null);
			logf("%s %s", con.from.name, con.to.name);
			Rebindable!(const Entity) fromEn = con.from.areYouIn(names);
			Rebindable!(const Entity) toEn = con.to.areYouIn(names);

			if(fromEn !is null || toEn !is null) {
				logf("\n\t'%s' '%s' '%s'\n\t'%s' '%s'", con.name, con.from.name,
					con.to.name,
					fromEn !is null ? fromEn.name : "", 
					toEn !is null ? toEn.name : ""
				);

				if(fromEn is null) {
					fromEn = this.getAndComponentOfContainer(g, con.from, con, names);
					assert(fromEn !is null);
					logf("%s", fromEn.name);
				} else if(toEn is null) {
					toEn = this.getAndComponentOfContainer(g, con.to, con, names);
					assert(toEn !is null);
					logf("%s", toEn.name);
				}
			}
		}
	}

	void generateSoftwareSystemsContainerComponents() {
		foreach(const(string) ssKey, const(SoftwareSystem) ss;
				this.world.softwareSystems)
		{
			logf("\n\n\t>>>>%s<<<<\n", ssKey);
			Graph g = new Graph();
			EntitySet names;

			if(ss.containers.empty) {
				this.addSystem!Node(g, ss);
				names.insert(cast(Entity)(ss));
			} else {
				auto sg = this.addSystem!SubGraph(g, ss);
				names.insert(cast(Entity)ss);

				foreach(const(string) conKey, const(Container) con;
						ss.containers) 
				{
					this.currentTechnologie = con.technology;
					scope(exit) this.currentTechnologie = "";

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
			logf("%s %s", con.from.name, con.to.name);
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
					assert(fromEn !is null);
					logf("%s", fromEn.name);
				} else if(toEn is null) {
					toEn = this.getAndAddTopLevel(g, con.to, names);
					assert(toEn !is null);
					logf("%s", toEn.name);
				}
				//logf("'%s' '%s'", fromToRoot, toToRoot);
			}
		}
		this.addEdges(g, names, uint.max);
	}

	const(Entity) getAndComponentOfContainer(SubGraph g, const(Entity) en, 
			const(Container) con, ref EntitySet names) 
	{
		auto rslt = con.holdsEntity(en);
		if(rslt.entity !is null) {
			auto com = cast(const Component)(rslt.entity);
			auto cls = cast(const Class)(rslt.entity);
			if(com !is null) {
				this.addComponent!Node(g, com, names);
			} else if(cls !is null) {
				this.addClass(g, cls, names);
			}
			return rslt.entity;
		} else {
			return this.getAndAddTopLevel(g, en, names);
		}

	}

	const(Entity) getAndAddTopLevel(Graph g, const(Entity) en, 
			ref EntitySet names) 
	{
		auto pathToRoot = en.pathToRoot();
		assert(!pathToRoot.empty);

		string top = splitter(pathToRoot, ".").array[0];
		logf("top %s", top);

		const(Entity) searchResult = en.getRoot();
		assert(searchResult !is null);
		auto act = cast(const Actor)(searchResult);
		auto ss = cast(const SoftwareSystem)(searchResult);
		auto hw = cast(const HardwareSystem)(searchResult);
		logf("%s %b %b %b", searchResult.name, act !is null, ss !is null, 
			hw !is null
		);

		if(act !is null) {
			this.addActor(g, act);
			names.insert(cast(Entity)searchResult);
		} else if(ss !is null) {
			this.addSystem!Node(g, ss);
			names.insert(cast(Entity)searchResult);
		} else if(hw !is null) {
			this.addSystem!Node(g, hw);
			names.insert(cast(Entity)searchResult);
		}

		return searchResult;
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
			names.insert(cast(Entity)ss);

			static if(is(T == SubGraph)) {
				foreach(const(string) comKey,
						const(Container) com;
						ss.containers)
				{

					auto consg =
						this.addContainer!Node(sg, com, names);
				}
			}
		}

		foreach(const(string) key, const(HardwareSystem) hws;
				this.world.hardwareSystems)
		{
			this.addSystem!Node(g, hws);
			names.insert(cast(Entity)hws);
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

	private T addContainer(T,G)(G sg, in Container con, 
			ref EntitySet names) 
	{
		this.currentTechnologie = con.technology;

		T n = sg.get!T(con.name);
		n.shape = "box";
		n.label = `<<table border="0" cellborder="0">
			<tr><td>%s</td></tr>
			<tr><td>[%s]</td></tr>
			%s
			</table>>`
		.format(con.name, con.technology,
			buildLabelFromDescription(con)
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

	SubGraph addComponentRecursive(SubGraph sg, in Component com,
			ref EntitySet names)
	{
		names.insert(cast(Entity)com);

		SubGraph comSG = this.addComponent!SubGraph(sg, com, names);
		this.addClasses(comSG, com, names);

		foreach(const(string) comKey, const(Component) sCom;
			com.subComponents)
		{
			if(sCom.subComponents.length == 0 && sCom.classes.empty) {
				this.addComponent!Node(comSG, sCom, names);
			} else {
				this.addComponentRecursive(comSG, sCom, names);
			}
		}
		return comSG;
	}

	void addClasses(SubGraph sg, in Component com, ref EntitySet names) {
		foreach(const(string) clsName, const(Class) cls; com.classes) {
			this.addClass(sg, cls, names);
		}
	}

	Node addClass(SubGraph sg, in Class cls, ref EntitySet names) {
		names.insert(cast(Entity)cls);

		Node node = sg.get!Node(cls.name);
		node.label = format(
			`<<table border="0" cellborder="0">
			<tr><td>%s</td></tr>
			<tr><td>[Class]</td></tr>
			%s
			</table>>`, cls.name, this.genClassMember(cls.members)
		);
		node.shape = "box";

		return node;
	}

	string genClassMember(in ref StringEntityMap!Member member) {
		import std.array : appender;
		string buildParameter(in MemberVariable mv) {
			if(mv.type is null 
					|| !(this.currentTechnologie in mv.type.typeToLanguage))
			{
				return format("%s", mv.name);
			} else {
				return format("%s %s", 
					mv.type.typeToLanguage[this.currentTechnologie],
					mv.name
				);
			}
		}

		auto app = appender!string();

		foreach(const(string) memName, const(Entity) value; member) {
			auto mem = cast(Member)value;
			assert(mem !is null);

			if(!mem.description.empty) {
				foreach(str; wrapLongString(mem.description, 40)) {
					formattedWrite(app, "<tr><td align=\"left\">%s</td></tr>\n", str);
				}
			}
			formattedWrite(app, "<tr><td align=\"left\">");
			if(this.currentTechnologie in mem.protection)
			{
				formattedWrite(app, "%s ",
					  	mem.protection[this.currentTechnologie]
				);
			}

			const MemberVariable mv = cast(MemberVariable)mem;
			if(mv !is null) {
				if(mv.type !is null 
						&& (this.currentTechnologie in mv.type.typeToLanguage))
				{
					formattedWrite(app, "%s ", 
						mv.type.typeToLanguage[this.currentTechnologie]
					);
				}
			}

			formattedWrite(app, "%s", mem.name);

			const MemberFunction mf = cast(MemberFunction)mem;
			if(mf !is null) {
				formattedWrite(app, "(%s)",
					mf.parameter[].map!(a => buildParameter(a))().joiner(", ")
				);
			}

			formattedWrite(app, "</td></tr>\n");
		}

		return app.data;
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

			fromS = fromS[0 .. min(fromS.length, deapth)];
			toS = toS[0 .. min(toS.length, deapth)];
			logf("\n\t%s %s %s %s %s", deapth, fromSStr, toSStr, fromS, toS);

			if(fromS.equal(toS)) {
				logf("\n\t%s %s", fromS, toS);
				continue;			
			}

			this.addEdge(g, con, names);
		}
	}

	Edge addEdge(Graph g, in ConnectionImpl con, 
			in ref EntitySet names) 
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
		   	in ref EntitySet names)
	{
		Edge e = this.addConnectionImpl(g, con, names);
		e.edgeStyle = "dashed";
		e.arrowStyleTo = "vee";
		return e;
	}

	Edge addConnection(Graph g, in Connection con,
		   	in ref EntitySet names)
	{
		Edge e = this.addConnectionImpl(g, con, names);
		return e;
	}

	Edge addAggregation(Graph g, in Aggregation con,
		   	in ref EntitySet names)
	{
		Edge e = this.addConnectionImpl(g, con, names);
		e.arrowStyleTo = "odiamond";
		e.labelFrom = connectionCountToString(con.fromCnt);
		e.labelTo = connectionCountToString(con.toCnt);
		return e;
	}

	Edge addComposition(Graph g, in Composition con,
		   	in ref EntitySet names)
	{
		Edge e = this.addConnectionImpl(g, con, names);
		e.arrowStyleTo = "diamond";
		e.labelFrom = connectionCountToString(con.fromCnt);
		return e;
	}

	Edge addGeneralization(Graph g, in Generalization con,
		   	in ref EntitySet names)
	{
		Edge e = this.addConnectionImpl(g, con, names);
		e.arrowStyleTo = "empty";
		return e;
	}

	Edge addRealization(Graph g, in Realization con,
		   	in ref EntitySet names)
	{
		Edge e = this.addConnectionImpl(g, con, names);
		e.arrowStyleTo = "empty";
		return e;
	}

	Edge addConnectionImpl(Graph g, in ConnectionImpl con,
		   	in ref EntitySet names)
	{
		auto toRoot = con.from.pathToRoot();
		auto fromRoot = con.to.pathToRoot();
		logf("%s:\n'%s' '%s'\n'%s' '%s'", con.name, 
			con.from.name, con.to.name, toRoot, fromRoot);

		Edge ret = g.getUnique!Edge(con.name, toRoot, fromRoot);
		if(ret is null) {
			return new Edge("", "", "");
		}
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
