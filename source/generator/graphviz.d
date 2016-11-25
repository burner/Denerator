module generator.graphviz;

import std.exception : enforce;
import std.experimental.logger;

import generator;
import model;
import duplicator;

import graph;
import writer;

class Graphvic : Generator {
	import std.array : array, empty, front;
	import std.algorithm.iteration : map, joiner, splitter;
	import std.typecons : scoped, Rebindable;
	import std.format : format, formattedWrite;
	import std.conv : to;

	const(string) outputDir;
	string currentTechnology;

	this(in TheWorld world, in string outputDir) {
		super(world);
		this.outputDir = outputDir;
		enforce(Generator.createFolder(outputDir));
	}

	override void generate(string s) {
		this.generate();
	}

	override void generate() {
		this.generateMakefile();
		this.generateAll();
		this.generateSystemContext();
		this.generateSoftwareSystem();
		this.generateSystemOnly();
		this.generateContainerOnly();
		this.generateTopComponentsOnly();
		this.generateClasses();
	}

	void generateMakefile() {
		auto f = Generator.createFile([this.outputDir, "Makefile"]);
		auto ltw = f.lockingTextWriter();

		ltw.formattedWrite(
			"DOTFILES= $(shell find . -type f -name '*.dot')\n\n"
			"DOTFILESPNG= $(patsubst %%.dot,%%.png,$(DOTFILES))\n\n"
		);

		ltw.formattedWrite(
			"all: $(DOTFILESPNG)\n\n"
			"print:\n\techo \"$(DOTFILESPNG)\"\n\techo \"$(DOTFILES)\"\n\n"
		);

		ltw.formattedWrite("%%.png : %%.dot\n");
		ltw.formattedWrite("\tdot -T png $< -o $@");
	}

	void generateAll() {
		Graph g = new Graph();
		this.generate(this.world, g);

		auto f = Generator.createFile([this.outputDir, "all.dot"]);
		auto ltw = f.lockingTextWriter();
		auto writer = scoped!(Writer!(typeof(ltw)))(g, ltw);
	}

	void generateSystemContext() {
		Graph g = new Graph();
		TheWorld copy = duplicateNodes(this.world);

		StringHashSet empty;

		foreach(const(string) key, SoftwareSystem ss; copy.softwareSystems) {
			ss.drop(empty);
		}

		reAdjustEdges(this.world, copy);

		this.generate(copy, g);

		auto f = Generator.createFile([this.outputDir, "systemcontext.dot"]);
		auto ltw = f.lockingTextWriter();
		auto writer = scoped!(Writer!(typeof(ltw)))(g, ltw);
	}

	void generateSoftwareSystem() {
		foreach(const(string) ssName, const(SoftwareSystem) ss;
				this.world.softwareSystems)
		{
			Graph g = new Graph();
			StringHashSet empty;
			TheWorld copy = duplicateNodes(this.world);
			foreach(const(string) ssNameC, SoftwareSystem ssC;
					copy.softwareSystems)
			{
				if(ssNameC != ssName) {
					ssC.drop(empty);
				}
			}
			reAdjustEdges(this.world, copy);
			this.generate(copy, g);

			assert(createFolder(this.outputDir ~ "/" ~ ssName));
			auto f = Generator.createFile([this.outputDir ~ "/" ~ ssName,
				ssName ~ ".dot"]
			);
			auto ltw = f.lockingTextWriter();
			auto writer = scoped!(Writer!(typeof(ltw)))(g, ltw);
		}
	}

	void generateTopComponentsOnly() {
		foreach(const(string) ssName, const(SoftwareSystem) ss;
				this.world.softwareSystems)
		{
			foreach(const(string) conName, const(Container) con;
					ss.containers)
			{
				foreach(const(string) comName, const(Component) com;
						con.components)
				{
					StringHashSet toKeep;
					Graph g = new Graph();
					toKeep.insert(ssName);
					toKeep.insert(conName);
					toKeep.insert(comName);

					TheWorld copy = duplicateNodes(this.world);
					copy.drop(toKeep);
					removeAll(copy.softwareSystems[ssName].containers, toKeep);
					removeAll(
						copy.softwareSystems[ssName].containers[conName].components,
					   	toKeep
					);

					reAdjustEdges(this.world, copy);
					this.generate(copy, g);

					assert(createFolder(this.outputDir ~ "/" ~ ssName
						~ "/" ~ conName
					));
					auto f = Generator.createFile(
						[this.outputDir, ssName, conName,
						comName ~ ".dot"]
					);
					auto ltw = f.lockingTextWriter();
					auto writer = scoped!(Writer!(typeof(ltw)))(g, ltw);
				}
			}
		}
	}

	void generateContainerOnly() {
		foreach(const(string) ssName, const(SoftwareSystem) ss;
				this.world.softwareSystems)
		{
			foreach(const(string) conName, const(Container) con;
					ss.containers)
			{
				Graph g = new Graph();
				StringHashSet toKeep;
				toKeep.insert(ssName);
				toKeep.insert(conName);

				TheWorld copy = duplicateNodes(this.world);
				copy.drop(toKeep);
				removeAll(copy.softwareSystems[ssName].containers, toKeep);

				reAdjustEdges(this.world, copy);
				this.generate(copy, g);

				assert(createFolder(this.outputDir ~ "/" ~ ssName));
				auto f = Generator.createFile([this.outputDir, 
					ssName, conName ~ ".dot"]
				);
				auto ltw = f.lockingTextWriter();
				auto writer = scoped!(Writer!(typeof(ltw)))(g, ltw);
			}
		}
	}

	void generateClasses() {
		void genClass(const(Class) cls, 
				ref const(Entity)[] path) 
		{
			if(cls.doNotGenerate == DoNotGenerate.yes) {
				return;
			}

			Graph g = new Graph();
			generate(cls, g);

			assert(path.length >= 2);
			string folderName = this.outputDir ~ "/" ~ path[0].name ~ "/" 
				~ path[1].name;

			auto name = path[2 .. $].map!(a => cast(string)a.name);
			string fileName = folderName ~ "/" ~ to!string(name.joiner("_"))
				~ "_" ~ cls.name ~ "_class.dot";

			assert(createFolder(folderName));
			auto f = Generator.createFile([fileName]);
			auto ltw = f.lockingTextWriter();
			auto writer = scoped!(Writer!(typeof(ltw)))(g, ltw);
		}

		void genComponent(const(Component) com, 
				ref const(Entity)[] path) 
		{
			path ~= com;
			scope(exit) path =  path[0 .. $ -1];

			foreach(it, subCom; com.subComponents) {
				genComponent(subCom, path);
			}

			foreach(const(string) clsKey, const(Class) cls; com.classes) {
				genClass(cls, path);
			}
		}

		foreach(const(string) ssName, const(SoftwareSystem) ss;
				this.world.softwareSystems)
		{
			const(Entity)[] path;
			path ~= ss;
			foreach(const(string) conName, const(Container) con;
					ss.containers)
			{
				path ~= con;
				scope(exit) path =  path[0 .. $ -1];

				this.currentTechnology = con.technology;

				foreach(const(string) comName, const(Component) com;
						con.components) 
				{
					genComponent(com, path);
				}

				foreach(const(string) clsKey, const(Class) cls; con.classes) {
					genClass(cls, path);
				}
			}
		}
	}

	void generateSystemOnly() {
		foreach(const(string) ssName, const(SoftwareSystem) ss;
				this.world.softwareSystems)
		{
			generateSystemOnlyImpl(ss);
		}

		foreach(const(string) ssName, const(HardwareSystem) hw;
				this.world.hardwareSystems)
		{
			generateSystemOnlyImpl(hw);
		}
	}

	void generateSystemOnlyImpl(System)(in System ss) {
		Graph g = new Graph();
		StringHashSet toKeep;
		toKeep.insert(ss.name);
		TheWorld copy = duplicateNodes(this.world);

		copy.drop(toKeep);

		reAdjustEdges(this.world, copy);
		this.generate(copy, g);

		assert(createFolder(this.outputDir ~ "/" ~ ss.name));
		auto f = Generator.createFile([this.outputDir, ss.name,
			ss.name ~ "_only.dot"]
		);
		auto ltw = f.lockingTextWriter();
		auto writer = scoped!(Writer!(typeof(ltw)))(g, ltw);
		
	}

	void generate(in TheWorld world, Graph g) {
		foreach(const(string) key, const(Actor) value; world.actors) {
			generate(value, g);
		}

		foreach(const(string) key, const(SoftwareSystem) value;
				world.softwareSystems)
		{
			generate(value, g);
		}

		foreach(const(string) key, const(HardwareSystem) value;
				world.hardwareSystems)
		{
			generate(value, g);
		}

		foreach(const(string) key, const(Entity) value; world.connections) {
			ConnectionImpl con = cast(ConnectionImpl)value;
			assert(con !is null);
			generate(con, g);
		}
	}

	void generate(in ConnectionImpl con, Graph g) {
		void impl(in ConnectionImpl con, string from, string to,
				Graph g)
		{
			Edge edge = g.getUnique!Edge(con.name ~ from ~ to,
				 from, to
			);
			if(edge is null) {
				return;
			} else {
				generate(con, edge);
			}
		}
		// class to class is a special case because these edges might be
		// required to be placed in multible containers or components
		Class fromCls = cast(Class)con.from;
		Class toCls = cast(Class)con.to;
		if(fromCls !is null && toCls !is null) {
			string[] fPaths = fromCls.pathsToRoot();
			string[] tPaths = toCls.pathsToRoot();
			ConnectedPath[] paths = connectedPaths(fPaths, tPaths);
			foreach(it; paths) {
				impl(con, it.from, it.to, g);
			}
		} else {
			auto fromRoot = pathToRoot(con.from);
			auto toRoot = pathToRoot(con.to);
			impl(con, fromRoot[0], toRoot[0], g);
		}
	}

	void generate(in ConnectionImpl con, Edge e) {
		e.label = format(
			"<<table border=\"0\" cellborder=\"0\">\n<tr><td>%s</td></tr>\n%s</table>>",
			con.name,
			buildLabelFromDescription(con)
		);
		if(auto c = cast(const Dependency)con) {
			generate(c, e);
		} else if(auto c = cast(const Connection)con) {
			generate(c, e);
		} else if(auto c = cast(const Aggregation)con) {
			generate(c, e);
		} else if(auto c = cast(const Composition)con) {
			generate(c, e);
		} else if(auto c = cast(const Generalization)con) {
			generate(c, e);
		} else if(auto c = cast(const Realization)con) {
			generate(c, e);
		} else {
			assert(false, con.name);
		}
	}

	void generate(in Dependency dep, Edge e) {
		e.edgeStyle = "dashed";
		e.arrowStyleTo = "\"vee\"";
		e.arrowStyleFrom = "\"none\"";
	}

	void generate(in Connection con, Edge e) {
		e.arrowStyleTo = "\"none\"";
		e.arrowStyleFrom = "\"empty\"";
	}

	void generate(in Aggregation con, Edge e) {
		e.arrowStyleTo = "\"none\"";
		e.arrowStyleFrom = "\"odiamond\"";
		e.labelFrom = generate(con.fromCnt);
		e.labelTo = generate(con.toCnt);
	}

	void generate(in Composition con, Edge e) {
		e.arrowStyleTo = "\"none\"";
		e.arrowStyleFrom = "\"diamond\"";
		e.labelFrom = generate(con.fromCnt);
	}

	void generate(in Generalization con, Edge e) {
		e.arrowStyleTo = "\"empty\"";
		e.arrowStyleFrom = "\"none\"";
	}

	void generate(in Realization con, Edge e) {
		e.arrowStyleTo = "\"none\"";
		e.arrowStyleFrom = "\"none\"";
	}

	void generate(G)(in Actor act, G g) {
		import std.algorithm.iteration : joiner, map;
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
	}

	void generate(G)(in SoftwareSystem ss, G g) {
		immutable string[] ssDescription = ["[SoftwareSystem]"];
		if(ss.containers.empty) {
			make!Node(ss, g, ssDescription);
		} else {
			SubGraph sg = make!SubGraph(ss, g, ssDescription);
			foreach(const(string) key, const(Container) value; ss.containers) {
				generate(value, sg);
			}
		}
	}

	void generate(G)(in HardwareSystem hw, G g) {
		immutable string[] hwDescription = ["[HardwareSystem]"];
		make!Node(hw, g, hwDescription);
	}

	void generate(G)(in Container container, G g) {
		this.currentTechnology = container.technology;
		string[] containerDescription = ["[%s]".format(container.technology)];
		if(container.components.empty && container.classes.empty) {
			make!Node(container, g, containerDescription);
		} else {
			SubGraph sg = make!SubGraph(container, g, containerDescription);
			foreach(const(string) key, const(Component) value;
					container.components)
			{
				generate(value, sg);
			}
			foreach(const(string) key, const(Class) value;
					container.classes)
			{
				generate(value, sg);
			}
		}
	}

	void generate(G)(in Component component, G g) {
		string[] componentDescription;
		if(component.subComponents.length == 0 && component.classes.empty) {
			make!Node(component, g, componentDescription);
		} else {
			SubGraph sg = make!SubGraph(component, g, componentDescription);
			foreach(const(string) key, const(Component) value;
					component.subComponents)
			{
				generate(value, sg);
			}
			foreach(const(string) key, const(Class) value;
					component.classes)
			{
				generate(value, sg);
			}
		}
	}

	string generate(ref in ConnectionCount cc) {
		import std.array : appender;

		if(cc.low == -1 && cc.high == -1) {
			return "";
		}

		auto app = appender!string();
		app.put("\"");
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
		app.put("\"");

		return app.data;
	}

	void generate(G)(in Class cls, G g) {
		Node node = g.get!Node(cls.name);
		node.label = format(
			`<<table border="0" cellborder="0">
			<tr><td>%s</td></tr>
			<tr><td>[%s]</td></tr>
			%s
			</table>>`, cls.name,
			(this.currentTechnology !in cls.containerType)
				? "class" : cls.containerType[this.currentTechnology],
			this.genClassMember(cls.members)
		);
		node.shape = "box";
	}

	string genClassMember(in ref Member[] member) {
		import std.array : appender;
		string buildParameter(in MemberVariable mv) {
			if(mv.type is null
					|| !(this.currentTechnology in mv.type.typeToLanguage))
			{
				return format("%s", mv.name);
			} else {
				return format("%s %s",
					mv.type.typeToLang(this.currentTechnology),
					mv.name
				);
			}
		}

		auto app = appender!string();

		foreach(const(Entity) value; member) {
			auto mem = cast(Member)value;
			assert(mem !is null);

			if(!mem.description.empty) {
				foreach(str; wrapLongString(mem.description, 40)) {
					formattedWrite(app, "<tr><td align=\"left\">%s</td></tr>\n",
						str
					);
				}
			}
			formattedWrite(app, "<tr><td align=\"left\">");
			if(this.currentTechnology in mem.protection)
			{
				formattedWrite(app, "%s ",
					  	mem.protection[this.currentTechnology]
				);
			}

			const MemberVariable mv = cast(MemberVariable)mem;
			if(mv !is null) {
				if(mv.type !is null
						&& (this.currentTechnology in mv.type.typeToLanguage))
				{
					formattedWrite(app, "%s ",
						mv.type.typeToLang(this.currentTechnology)
					);
				}
			}

			const MemberFunction mf = cast(MemberFunction)mem;
			if(mf !is null && mf.returnType) {
				formattedWrite(app, "%s ",
					mf.returnType.typeToLang(this.currentTechnology)
				);
			}

			formattedWrite(app, "%s", mem.name);

			if(mf !is null) {
				formattedWrite(app, "(%s)",
					mf.parameter[].map!(a => buildParameter(a))().joiner(", ")
				);
			}

			formattedWrite(app, "</td></tr>\n");
		}

		return app.data;
	}

	T make(T,G)(in Entity en, G g, in string[] additional) {
		auto tmp = additional.map!(a => format("<tr><td>%s</td></tr>", a))
			.joiner("\n").to!(char[])().idup;
		T n = g.get!T(en.name);
		n.shape = "box";
		n.label = `<<table border="0" cellborder="0">
			<tr><td>%s</td></tr>
			%s
			%s
			</table>>`
		.format(en.name, tmp, buildLabelFromDescription(en));
		return n;
	}

	private static auto buildLabelFromDescription(in Entity en) {
		return wrapLongString(en.description, 40)
			.map!(a => format("<tr><td>%s</td></tr>", a)).joiner("\n");
	}

	private static void removeAll(C)(ref C c, in ref StringHashSet toKeep) {
		auto keys = c.keys();
		foreach(it; keys) {
			if(it !in toKeep) {		
				c[it].drop();
				c.remove(it);
			}
		}
	}
}
