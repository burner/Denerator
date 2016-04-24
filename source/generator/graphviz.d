module generator.graphviz;

import std.array : empty;
import std.exception : enforce;
import std.format : formattedWrite;
import std.algorithm.iteration : map, joiner;
import std.stdio : writeln;
import std.range : chain;

import containers.hashmap;
import containers.dynamicarray;

import generator;
import model;

class Graphvic : Generator {
	const(string) outputDir;
	string TheWorldName = "theworld";
	string TheWorldAndContainerName = "theworldandcontainer";
	string currentTechnologie;
	DynamicArray!string prefix;

	this(in TheWorld world, in string outputDir) {
		super(world);
		this.outputDir = outputDir;
		enforce(Generator.createFolder(outputDir));
	}

	override void generate() {
		this.generateWorld();
		this.generateWorldAndContainer();
		this.generateWorldAndContainerComponents();
		this.generateSoftwareSystemsComplete();
		this.generateMakefile();
	}

	void generateMakefile() {
		auto f = Generator.createFile([this.outputDir, "Makefile"]);
		auto ltw = f.lockingTextWriter();

		auto targets = [TheWorldName,TheWorldAndContainerName];

		ltw.formattedWrite(
			"all: $(patsubst %%.dot,%%.png,$(wildcard *.dot))\n\n"
		);

		ltw.formattedWrite("%%.png : %%.dot\n");
		ltw.formattedWrite("\tdot -T png $< -o $@");
	}

	void generateWorld() {
		auto f = Generator.createFile([this.outputDir, TheWorldName ~ ".dot"]);
		auto ltw = f.lockingTextWriter();
		generateTopMatter(ltw);

		StringHashSet names;
		HashMap!(string, string) nameMappings;

		this.generate!Actor(ltw, this.world.actors, names, nameMappings);
		this.generate!SoftwareSystem(ltw, this.world.softwareSystems, names,
			nameMappings
		);
		this.generate!HardwareSystem(ltw, this.world.hardwareSystems, names,
			nameMappings
		);

		this.generateWorldConnections(ltw, names, nameMappings);

		ltw.put("}\n");
	}

	void generateWorldAndContainer() {
		auto f = Generator.createFile([this.outputDir, 
			TheWorldAndContainerName ~ ".dot"]
		);
		auto ltw = f.lockingTextWriter();
		generateTopMatter(ltw);
		ltw.put("\trankdir=LR;\n");

		// collect all the names so we know what edges to draw
		StringHashSet names;
		HashMap!(string, string) nameMappings;
		generate!Actor(ltw, this.world.actors, names, nameMappings);

		foreach(key; this.world.softwareSystems.keys()) {
			auto it = this.world.softwareSystems[key];
			generateSoftwareSystemAndContainers(ltw, it, names, nameMappings);
		}

		generate!HardwareSystem(ltw, this.world.hardwareSystems, names, 
			nameMappings
		);

		this.generateWorldConnections(ltw, names, nameMappings);

		ltw.put("}\n");
	}

	void generateSoftwareSystemsComplete() {
		this.prefix.push(this.world.name);
		foreach(it; this.world.softwareSystems.keys()) {
			auto ss = this.world.softwareSystems[it];
			auto f = Generator.createFile([this.outputDir, it ~ ".dot"]);
			auto ltw = f.lockingTextWriter();
			generateTopMatter(ltw);

			StringHashSet names;
			HashMap!(string, string) nameMappings;
			names.insert(ss.name);
			nameMappings[ss.name] = "cluster_" ~ prepareName(ss.name);

			ltw.format(1, "subgraph %s_%s {\n", 
				buildPrefixString(this.prefix),
				prepareName(ss.name)
			);
			generateSoftwareSystemTopMatter(ltw, ss, names, nameMappings);
			
			ltw.format(2, 
				"cluster_%s_dummy [ width=\"0\" shape=none " ~
				"label = \"\", style = invis ];\n", 
				prepareName(ss.name)
			);

			this.prefix.push(ss.name);
			foreach(jt; ss.containers.keys()) {
				const Container con = ss.containers[jt];
				this.currentTechnologie = con.technology;

				generateContainerComplete(ltw, con, names, nameMappings, 0);
				this.generateConnectionsComplete(ltw, con);
			}
			ltw.format(1, "}\n");

			this.prefix.pop();
			ltw.put("}\n");
		}
	}

	void generateConnectionsComplete(O)(ref O output, const Container ss) {
		foreach(it; this.world.connections.keys()) {
			ConnectionImpl con = cast(ConnectionImpl)this.world.connections[it];
			assert(con !is null);
			Entity from = con.from;
			Entity to = con.to;

			assert(from !is null);
			assert(to !is null);

			SearchResult fromSR = ss.holdsEntity(from);
			appendParents(fromSR, ss.parent);
			SearchResult toSR = ss.holdsEntity(to);
			appendParents(toSR, ss.parent);

			if(fromSR.entity !is null && toSR.entity !is null) {
				writeln(ss.name, " ", it, " ", fromSR.path, " ", toSR.path);
				output.format(1, "%s -> %s%s;\n",
					buildPrefixStringReverse(fromSR.path) ~ "_" ~ 
					prepareName(from.name),
					buildPrefixStringReverse(toSR.path) ~ "_" ~ 
					prepareName(to.name),
					arrowhead(con)
				);
			}
		}
	}

	string arrowhead(Entity en) {
		Dependency dep = cast(Dependency)en;
		if(dep !is null) {
			return "[arrowhead=\"open\"]";
		}
		Connection con = cast(Connection)en;
		if(con !is null) {
			return "";
		}
		Aggregation agg = cast(Aggregation)en;
		if(agg !is null) {
			return "[arrowhead=\"odiamond\"]";
		}
		Composition com = cast(Composition)en;
		if(com !is null) {
			return "[arrowhead=\"diamond\"]";
		}
		Generalization  gen = cast(Generalization)en;
		if(gen !is null) {
			return "[arrowhead=\"empty\"]";
		}
		Realization  rea = cast(Realization)en;
		if(rea !is null) {
			return "[arrowhead=\"empty\"]";
		}
		ConnectionImpl ci = cast(ConnectionImpl)en;
		if(ci !is null) {
			return "[arrowhead=\"empty\"]";
		}
		return "";
	}

	void generateWorldConnections(O)(ref O output, 
			ref in StringHashSet publicNames,
			ref in HashMap!(string,string) nameMappings) 
	{
		import std.algorithm.searching : startsWith;
		auto keys = super.world.connections.keys();
		foreach(it; keys) {
			auto con = cast(ConnectionImpl)super.world.connections[it];
			//writeln(con.name);
			assert(con.from !is null);
			assert(con.to !is null);

			immutable fromName = con.from.areYouIn(publicNames);
			immutable toName = con.to.areYouIn(publicNames);

			if(fromName == toName) {
				continue;
			}

			if(!fromName.empty && !toName.empty) {
				immutable fromNameRN = nameMappings[fromName];
				immutable toNameRN = nameMappings[toName];

				assert(!fromNameRN.empty);
				assert(!toNameRN.empty);
				if(fromNameRN.startsWith("cluster_") &&
					toNameRN.startsWith("cluster_"))
				{
					output.format(1, "%s -> %s [ltail=%s lhead=%s]",
						fromNameRN ~ "_dummy", toNameRN ~ "_dummy",
						fromNameRN,
						toNameRN,
					);
				} else if(!fromNameRN.startsWith("cluster_") &&
					toNameRN.startsWith("cluster_"))
				{
					output.format(1, "%s -> %s [lhead=%s]", fromNameRN,
						toNameRN ~ "_dummy", toNameRN,
					);
				} else if(fromNameRN.startsWith("cluster_") &&
					!toNameRN.startsWith("cluster_"))
				{
					output.format(1, "%s -> %s [ltail=%s]", 
						fromNameRN ~ "_dummy",
						toNameRN, fromNameRN,
					);
				} else {
					output.format(1, "%s -> %s", fromNameRN, toNameRN);
				}
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

	void generateWorldAndContainerComponents() {
		auto f = Generator.createFile([this.outputDir, 
			"theworldcontainercomponents.dot"]
		);
		auto ltw = f.lockingTextWriter();
		generateTopMatter(ltw);

		// collect all the names so we know what edges to draw
		StringHashSet names;
		HashMap!(string, string) nameMappings;
		generate!Actor(ltw, this.world.actors, names, nameMappings);

		foreach(key; this.world.softwareSystems.keys()) {
			auto it = this.world.softwareSystems[key];
			generateSoftwareSystemAndContainerComponent(ltw, it, names,
				nameMappings
			);
		}

		generate!HardwareSystem(ltw, this.world.hardwareSystems, names,
			nameMappings
		);

		ltw.put("}\n");
	}

	void generateClass(O)(ref O output, 
			ref in Class cls, ref StringHashSet names,
			ref HashMap!(string,string) nameMappings,
			in uint ei = 0) 
	{
		names.insert(cls.name);
		nameMappings[cls.name] = prepareName(cls.name);
	
		output.format(3 + ei, "%s_%s [\n", 
			buildPrefixString(this.prefix),
			prepareName(cls.name)
		);
		output.format(4 + ei, "shape=box;\n");
		output.format(4 + ei, "label = <\n");
		output.format(5 + ei, "<table border=\"0\" cellborder=\"0\">\n");
		output.format(5 + ei, "<tr><td>%s</td></tr>\n", cls.name);
		output.format(5 + ei, "<tr><td>[Class]</td></tr>\n");
		
		if(!cls.description.empty) {
			string[] wrapped = wrapLongString(cls.description, 40);
			foreach(str; wrapped) {
				output.format(5 + ei, "<tr><td align=\"left\">%s</td></tr>\n", str);
			}
		}
	
		foreach(it; cls.members.keys()) {
			const(Member) mem = cls.members[it];
			generateMember(output, mem, names, nameMappings, ei + 1);
		}
	
		output.format(5 + ei, "</table>\n");
		output.format(4 + ei, ">\n");
		output.format(3 + ei, "]\n");
	}
	
	void generateMember(O)(ref O output, 
			in ref Member mem, ref StringHashSet names,
			ref HashMap!(string,string) nameMappings,
			in uint ei = 0) 
	{
		const MemberVariable mv = cast(MemberVariable)mem;
		if(mv !is null) {
			generateMemberVariable(output, mv, names, nameMappings, ei + 1);
		}
	
		const MemberFunction mf = cast(MemberFunction)mem;
		if(mf !is null) {
			generateMemberFunction(output, mf, names, nameMappings, ei + 1);
		}
	}
	
	void generateMemberVariable(O)(ref O output, 
			in ref MemberVariable mem, ref StringHashSet names,
			ref HashMap!(string,string) nameMappings,
			in uint ei = 0) 
	{
		if(!mem.description.empty) {
			string[] wrapped = wrapLongString(mem.description, 40);
			foreach(str; wrapped) {
				output.format(ei, "<tr><td align=\"left\">%s</td></tr>\n", str);
			}
		}
		writeln(this.currentTechnologie, " ", mem.name);
		if(mem.type is null 
				|| !(this.currentTechnologie in mem.type.typeToLanguage))
		{
			output.format(ei, "<tr><td>%s</td></tr>\n", 
				mem.name
			);
		} else {
			output.format(ei, "<tr><td>%s %s</td></tr>\n", 
				mem.type.typeToLanguage[this.currentTechnologie],
				mem.name
			);
		}
	}

	void generateMemberFunction(O)(ref O output, 
			in ref MemberFunction mem, ref StringHashSet names,
			ref HashMap!(string,string) nameMappings,
			in uint ei = 0) 
	{
		if(!mem.description.empty) {
			string[] wrapped = wrapLongString(mem.description, 40);
			foreach(str; wrapped) {
				output.format(ei, "<tr><td align=\"left\">%s</td></tr>\n", str);
			}
		}
		writeln(this.currentTechnologie, " ", mem.name);
		if(mem.returnType is null 
				|| !(this.currentTechnologie in mem.returnType.typeToLanguage))
		{
			output.format(ei, "<tr><td>%s(%s)</td></tr>\n", 
				mem.name, 
				buildParameterList(mem.parameter)
			);
		} else {
			output.format(ei, "<tr><td>%s %s(%s)</td></tr>\n", 
				mem.returnType.typeToLanguage[this.currentTechnologie],
				mem.name, buildParameterList(mem.parameter)
			);
		}
	}

	string buildParameterList(ref in DynamicArray!MemberVariable parameter) {
		import std.array : array;
		import std.conv : to;
		string buildParameter(in MemberVariable mv) {
			import std.format : format;
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

		return parameter[].map!(a => buildParameter(a))().joiner(", ")
			.to!string();
	}

	void generateContainerComplete(O)(ref O output, in Container container, 
			ref StringHashSet names, ref HashMap!(string,string) nameMappings, 
			in uint ei = 0) 
	{
		generateContainerTopMatter(output, container, names, nameMappings);
		this.prefix.push(container.name);
		scope(exit) this.prefix.pop();
		foreach(it; container.components.keys()) {
			const auto com = container.components[it];
			generateComponentComplete(output, com, names, nameMappings, ei + 1);
		}

		foreach(it; container.classes.keys()) {
			writeln(it);
			const(Class) cls = container.classes[it];
			generateClass(output, cls, names, nameMappings, ei);
		}

		generateContainerBottomMatter(output, container, names, nameMappings);
	}
	
	void generateComponentComplete(O)(ref O output, in Component com, 
			ref StringHashSet names, ref HashMap!(string,string) nameMappings, 
			in uint ei = 0) 
	{
		this.prefix.push(com.name);
		scope(exit) this.prefix.pop();

		names.insert(com.name);
		nameMappings[com.name] = "cluster_" ~ prepareName(com.name);
	
		output.format(3 + ei, "subgraph %s_%s {\n", 
			buildPrefixString(this.prefix),
			prepareName(com.name)
		);
		output.format(4 + ei, "shape=box;\n");
		output.format(4 + ei, "label = <\n");
		output.format(5 + ei, "<table border=\"0\" cellborder=\"0\">\n");
		output.format(5 + ei, "<tr><td>%s</td></tr>\n", com.name);
		output.format(5 + ei, "<tr><td>[Component]</td></tr>\n");
		
		if(!com.description.empty) {
			string[] wrapped = wrapLongString(com.description, 40);
			foreach(str; wrapped) {
				output.format(5 + ei, "<tr><td align=\"left\">%s</td></tr>\n", str);
			}
		}
	
		output.format(5 + ei, "</table>\n");
		output.format(4 + ei, ">\n");
	
		foreach(it; com.subComponents) {
			names.insert(it.name);
			generateComponentComplete(output, it, names, nameMappings, ei + 1);
		}

		foreach(it; com.classes.keys()) {
			const(Class) cls = com.classes[it];
			generateClass(output, cls, names, nameMappings, ei + 1);
		}

		foreach(const string key; this.world.connections.keys()) {
			ConnectionImpl con = cast(ConnectionImpl)this.world.connections[key];
			assert(con !is null);
		}
	
		output.format(3 + ei, 
			"%s_%s_dummy [ width=\"0\" shape=none " ~ 
			"label = \"\", style = invis ];\n", 
			buildPrefixString(this.prefix),
			prepareName(com.name)
		);
		output.format(3 + ei, "}\n");
	}

	private void generateTopMatter(O)(ref O output) {
		output.put(
	`digraph G {
		fixedsize=true 
		compound=true 
	`
		);
	}
	
	private void generate(T,O)(ref O output, 
			in ref StringEntityMap!(T) map, ref StringHashSet names,
			ref HashMap!(string,string) nameMappings) 
	{
		auto keys = map.keys();
		foreach(it; keys) {
			static if(is(T == Actor)) {
				generateActor(output, map[it], names, nameMappings);
			} else static if(is(T == SoftwareSystem)) {
				generateSoftwareSystem(output, map[it], names, nameMappings);
			} else static if(is(T == HardwareSystem)) {
				generateHardwareSystem(output, map[it], names, nameMappings);
			}
		}
	}
	
	private void generateActor(O)(ref O output, in Actor actor, ref StringHashSet
			names, ref HashMap!(string,string) nameMappings) 
	{
		names.insert(actor.name);
		nameMappings[actor.name] = prepareName(actor.name);
	
		output.format(1, "%s [\n", prepareName(actor.name));
		output.format(2, "shape=none;\n");
		output.format(2, "label = <\n");
		output.format(3, "<table border=\"0\" cellborder=\"0\">\n");
		output.format(3, "<tr><td><img src=\"../Stick.png\"/></td></tr>\n");
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
	
	private void generateSoftwareSystemTopMatter(O)(ref O output,
		   	in SoftwareSystem ss, ref StringHashSet names, 
			ref HashMap!(string,string) nameMappings, in uint ei = 0) 
	{
		output.format(2 + ei, "shape=box;\n");
		output.format(2 + ei, "label = <\n");
		output.format(3 + ei, "<table border=\"0\" cellborder=\"0\">\n");
		output.format(3 + ei, "<tr><td>%s</td></tr>\n", ss.name);
		output.format(3 + ei, "<tr><td>[Software System]</td></tr>\n");
		
		if(!ss.description.empty) {
			string[] wrapped = wrapLongString(ss.description, 40);
			foreach(str; wrapped) {
				output.format(3 + ei, "<tr><td align=\"left\">%s</td></tr>\n", str);
			}
		}
	
		output.format(3 + ei, "</table>\n");
		output.format(2 + ei, ">\n");
	}
	
	private void generateSoftwareSystem(O)(ref O output, in SoftwareSystem ss, ref
			StringHashSet names, ref HashMap!(string,string) nameMappings) 
	{
		names.insert(ss.name);
		nameMappings[ss.name] = prepareName(ss.name);
	
		output.format(1, "%s [\n", prepareName(ss.name));
		/*output.format(2, "shape=box;\n");
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
		output.format(2, ">\n");*/
		generateSoftwareSystemTopMatter(output, ss, names, nameMappings);
		output.format(1, "]\n");
	}
	
	private void generateHardwareSystem(O)(ref O output, in HardwareSystem ss, ref
			StringHashSet names, ref HashMap!(string,string) nameMappings) 
	{
		names.insert(ss.name);
		nameMappings[ss.name] = prepareName(ss.name);
	
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
	
	private void generateSoftwareSystemAndContainers(O)(ref O output, 
			in ref SoftwareSystem ss, ref StringHashSet names, 
			ref HashMap!(string,string) nameMappings) 
	{
		names.insert(ss.name);
		nameMappings[ss.name] = "cluster_" ~ prepareName(ss.name);
	
		output.format(1, "subgraph cluster_%s {\n", prepareName(ss.name));
		output.put("\trankdir=LR;\n");
		output.format(2, "label = <\n");
		output.format(3, "<table border=\"0\" cellborder=\"0\">\n");
		output.format(3, "<tr><td>%s</td></tr>\n", ss.name);
		output.format(3, "<tr><td>[Software System]</td></tr>\n");
		//output.format(3, "<tr><td>[%s]</td></tr>\n", ss.technology);
		
		if(!ss.description.empty) {
			string[] wrapped = wrapLongString(ss.description, 40);
			foreach(str; wrapped) {
				output.format(3, "<tr><td align=\"left\">%s</td></tr>\n", str);
			}
		}
	
		output.format(3, "</table>\n");
		output.format(2, ">\n");
		//output.format(1, "]\n");
		
		foreach(key; ss.containers.keys()) {
			const Container it = ss.containers[key];
			generateContainer(output, it, names, nameMappings);
		}
		output.format(2, 
			"cluster_%s_dummy [ width=\"0\" shape=none label = \"\", style = invis ];\n", 
			prepareName(ss.name)
		);
		output.format(1, "}\n");
	}
	
	private void generateContainer(O)(ref O output, 
			in ref Container ss, ref StringHashSet names, 
			ref HashMap!(string,string) nameMappings) 
	{
		names.insert(ss.name);
		nameMappings[ss.name] = prepareName(ss.name);
	
		output.format(2, "%s [\n", prepareName(ss.name));
		output.format(3, "shape=box;\n");
		output.format(3, "label = <\n");
		output.format(4, "<table border=\"0\" cellborder=\"0\">\n");
		output.format(4, "<tr><td>%s</td></tr>\n", ss.name);
		output.format(4, "<tr><td>[%s]</td></tr>\n", ss.technology);
		
		if(!ss.description.empty) {
			string[] wrapped = wrapLongString(ss.description, 40);
			foreach(str; wrapped) {
				output.format(4, "<tr><td align=\"left\">%s</td></tr>\n", str);
			}
		}
	
		output.format(4, "</table>\n");
		output.format(3, ">\n");
		output.format(2, "]\n");
	}
	
	private void generateSoftwareSystemAndContainerComponent(O)(ref O output, 
			in ref SoftwareSystem ss, ref StringHashSet names, 
			ref HashMap!(string,string) nameMappings) 
	{
		names.insert(ss.name);
		nameMappings[ss.name] = "cluster_" ~ prepareName(ss.name);
	
		output.format(1, "subgraph cluster_%s {\n", prepareName(ss.name));
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
		
		foreach(key; ss.containers.keys()) {
			auto it = ss.containers[key];
			names.insert(it.name);
			generateContainerComponents(output, it, names, nameMappings);
		}
		output.format(2, 
			"cluster_%s_dummy [ width=\"0\" shape=none label = \"\", style = invis ];\n", 
			prepareName(ss.name)
		);
		output.format(1, "}\n");
	}
	
	private void generateContainerTopMatter(O)(ref O output,
			in ref Container ss, ref StringHashSet names,
			ref HashMap!(string,string) nameMappings, in uint ei = 0) 
	{
		if(ss.components.empty && ss.classes.empty) {
			generateContainer(output, ss, names, nameMappings);
		} else {
			names.insert(ss.name);
			nameMappings[ss.name] = "cluster_" ~ prepareName(ss.name);
	
			output.format(2 + ei, "subgraph cluster_%s_%s {\n", 
				buildPrefixString(this.prefix),
				prepareName(ss.name)
			);
			output.format(3 + ei, "shape=box;\n");
			output.format(3 + ei, "label = <\n");
			output.format(4 + ei, "<table border=\"0\" cellborder=\"0\">\n");
			output.format(4 + ei, "<tr><td>%s</td></tr>\n", ss.name);
			output.format(4 + ei, "<tr><td>[%s]</td></tr>\n", ss.technology);
			
			if(!ss.description.empty) {
				string[] wrapped = wrapLongString(ss.description, 40);
				foreach(str; wrapped) {
					output.format(4 + ei, "<tr><td align=\"left\">%s</td></tr>\n", str);
				}
			}
	
			output.format(4 + ei, "</table>\n");
			output.format(3 + ei, ">\n");
			output.format(3 + ei, 
				"cluster_%s_dummy [ width=\"0\" shape=none label = \"\", style = invis ];\n", 
				prepareName(ss.name)
			);
		}
	}
	
	private void generateContainerBottomMatter(O)(ref O output,
			in ref Container ss, ref StringHashSet names,
			ref HashMap!(string,string) nameMappings, in uint ei = 0) 
	{
		if(ss.components.empty && ss.classes.empty) {
			//output.format(2 + ei, "]\n"); // TODO compare generateContainer
		} else {
			output.format(2 + ei, "}\n");
		}
	}
	
	private void generateContainerComponents(O)(ref O output, 
			in ref Container ss, ref StringHashSet names,
			ref HashMap!(string,string) nameMappings) 
	{
		if(ss.components.empty) {
			generateContainer(output, ss, names, nameMappings);
		} else {
			names.insert(ss.name);
			nameMappings[ss.name] = "cluster_" ~ prepareName(ss.name);
	
			output.format(2, "subgraph cluster_%s {\n", prepareName(ss.name));
			output.format(3, "shape=box;\n");
			output.format(3, "label = <\n");
			output.format(4, "<table border=\"0\" cellborder=\"0\">\n");
			output.format(4, "<tr><td>%s</td></tr>\n", ss.name);
			output.format(4, "<tr><td>[%s]</td></tr>\n", ss.technology);
			
			if(!ss.description.empty) {
				string[] wrapped = wrapLongString(ss.description, 40);
				foreach(str; wrapped) {
					output.format(4, "<tr><td align=\"left\">%s</td></tr>\n", str);
				}
			}
	
			output.format(4, "</table>\n");
			output.format(3, ">\n");
	
			foreach(key; ss.components.keys()) {
				const it = ss.components[key];	
				names.insert(it.name);
				generateComponents(output, it, names, nameMappings);
			}
			output.format(3, 
				"cluster_%s_dummy [ width=\"0\" shape=none label = \"\", style = invis ];\n", 
				prepareName(ss.name)
			);
			output.format(2, "}\n");
		}
	}
	
	private void generateComponents(O)(ref O output, 
			in ref Component ss, ref StringHashSet names,
			ref HashMap!(string,string) nameMappings,
			in uint ei = 0) 
	{
		if(ss.subComponents.length == 0) {
			names.insert(ss.name);
			nameMappings[ss.name] = prepareName(ss.name);
	
			output.format(3 + ei, "%s [\n", prepareName(ss.name));
			output.format(4 + ei, "shape=box;\n");
			output.format(4 + ei, "label = <\n");
			output.format(5 + ei, "<table border=\"0\" cellborder=\"0\">\n");
			output.format(5 + ei, "<tr><td>%s</td></tr>\n", ss.name);
			output.format(5 + ei, "<tr><td>[Component]</td></tr>\n");
			
			if(!ss.description.empty) {
				string[] wrapped = wrapLongString(ss.description, 40);
				foreach(str; wrapped) {
					output.format(5 + ei, "<tr><td align=\"left\">%s</td></tr>\n", str);
				}
			}
	
			output.format(5 + ei, "</table>\n");
			output.format(4 + ei, ">\n");
			output.format(3 + ei, "]\n");
		} else {
			names.insert(ss.name);
			nameMappings[ss.name] = "cluster_" ~ prepareName(ss.name);
	
			output.format(3 + ei, "subgraph cluster_%s {\n", prepareName(ss.name));
			output.format(4 + ei, "shape=box;\n");
			output.format(4 + ei, "label = <\n");
			output.format(5 + ei, "<table border=\"0\" cellborder=\"0\">\n");
			output.format(5 + ei, "<tr><td>%s</td></tr>\n", ss.name);
			output.format(5 + ei, "<tr><td>[Component]</td></tr>\n");
			
			if(!ss.description.empty) {
				string[] wrapped = wrapLongString(ss.description, 40);
				foreach(str; wrapped) {
					output.format(5 + ei, "<tr><td align=\"left\">%s</td></tr>\n", str);
				}
			}
	
			output.format(5 + ei, "</table>\n");
			output.format(4 + ei, ">\n");
	
			foreach(it; ss.subComponents) {
				names.insert(it.name);
				generateComponents(output, it, names, nameMappings, ei + 1);
			}
	
			output.format(3 + ei, 
				"cluster_%s_dummy [ width=\"0\" shape=none label = \"\", style = invis ];\n", 
				prepareName(ss.name)
			);
			output.format(3 + ei, "}\n");
		}
	}
}

private void push(ref DynamicArray!string arr, string str) {
	arr.insert(str);
}

private string pop(ref DynamicArray!string arr) {
	if(arr.empty) {
		return "";
	} else {
		string tmp = arr[$ - 1];
		arr.remove(arr.length - 1);
		return tmp;
	}
}

private string buildPrefixString(T)(const ref T arr) {
	import std.array : appender;
	import std.format : format;

	auto app = appender!string();
	app.put(arr[].map!(a => format("cluster_%s", prepareName(a)))
		.joiner("_"));
	return app.data;
}

private string buildPrefixStringReverse(T)(const ref T arr) {
	import std.algorithm.mutation : reverse;
	auto arrDup = arr[].dup;
	reverse(arrDup);

	return buildPrefixString(arrDup);
}

private void appendParents(ref SearchResult sr, const(Entity) en) {
	if(en !is null) {
		sr.path ~= en.name;
		appendParents(sr, en.parent);
	}
}
