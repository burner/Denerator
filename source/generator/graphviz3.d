module generator.graphviz3;

import std.exception : enforce;
import std.experimental.logger;

import generator;
import model;
import duplicator;

import graph;
import writer;

class Graphvic3 : Generator {
	import std.array : empty;
	import std.algorithm.iteration : map, joiner;
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

	override void generate() {
		this.generateMakefile();
		this.generateAll();
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
		}
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

	string genClassMember(in ref StringEntityMap!Member member) {
		import std.array : appender;
		string buildParameter(in MemberVariable mv) {
			if(mv.type is null 
					|| !(this.currentTechnology in mv.type.typeToLanguage))
			{
				return format("%s", mv.name);
			} else {
				return format("%s %s", 
					mv.type.typeToLanguage[this.currentTechnology],
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
						mv.type.typeToLanguage[this.currentTechnology]
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

	T make(T,G)(in Entity en, G g, in string[] additional) {
		auto tmp = additional.map!(a => format("<tr><td>%s</td></tr>", a))
			.joiner("\n").to!(char[])().idup;
		logf("%s %s", additional, tmp);
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
}
