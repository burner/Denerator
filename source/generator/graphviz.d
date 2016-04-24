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
	string prefix;

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

		ltw.generate!Actor(this.world.actors, names, nameMappings);
		ltw.generate!SoftwareSystem(this.world.softwareSystems, names,
			nameMappings
		);
		ltw.generate!HardwareSystem(this.world.hardwareSystems, names,
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

		// collect all the names so we know what edges to draw
		StringHashSet names;
		HashMap!(string, string) nameMappings;
		ltw.generate!Actor(this.world.actors, names, nameMappings);

		foreach(key; this.world.softwareSystems.keys()) {
			auto it = this.world.softwareSystems[key];
			ltw.generateSoftwareSystemAndContainers(it, names, nameMappings);
		}

		ltw.generate!HardwareSystem(this.world.hardwareSystems, names, 
			nameMappings
		);

		this.generateWorldConnections(ltw, names, nameMappings);

		ltw.put("}\n");
	}

	void generateSoftwareSystemsComplete() {
		foreach(it; this.world.softwareSystems.keys()) {
			auto ss = this.world.softwareSystems[it];
			auto f = Generator.createFile([this.outputDir, it ~ ".dot"]);
			auto ltw = f.lockingTextWriter();
			generateTopMatter(ltw);

			StringHashSet names;
			HashMap!(string, string) nameMappings;
			names.insert(ss.name);
			nameMappings[ss.name] = "cluster_" ~ prepareName(ss.name);

			ltw.format(1, "subgraph cluster_%s {\n", prepareName(ss.name));
			ltw.generateSoftwareSystemTopMatter(ss, names, nameMappings);
			
			ltw.format(2, 
				"cluster_%s_dummy [ width=\"0\" shape=none " ~
				"label = \"\", style = invis ];\n", 
				prepareName(ss.name)
			);

			foreach(jt; ss.containers.keys()) {
				const Container con = ss.containers[jt];
				this.currentTechnologie = con.technology;

				generateContainerComplete(ltw, con, names, nameMappings, 0);
			}
			ltw.format(1, "}\n");
			ltw.put("}\n");
		}
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
		ltw.generate!Actor(this.world.actors, names, nameMappings);

		foreach(key; this.world.softwareSystems.keys()) {
			auto it = this.world.softwareSystems[key];
			ltw.generateSoftwareSystemAndContainerComponent(it, names,
				nameMappings
			);
		}

		ltw.generate!HardwareSystem(this.world.hardwareSystems, names,
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
			prepareName(this.prefix),
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
		this.prefix = container.name;
		output.generateContainerTopMatter(container, names, nameMappings);
		foreach(it; container.components.keys()) {
			const auto com = container.components[it];
			generateComponentComplete(output, com, names, nameMappings, ei + 1);
		}

		this.prefix = container.name;
		foreach(it; container.classes.keys()) {
			writeln(it);
			const(Class) cls = container.classes[it];
			generateClass(output, cls, names, nameMappings, ei);
		}

		output.generateContainerBottomMatter(container, names, nameMappings);
	}
	
	void generateComponentComplete(O)(ref O output, in Component com, 
			ref StringHashSet names, ref HashMap!(string,string) nameMappings, 
			in uint ei = 0) 
	{
		names.insert(com.name);
		nameMappings[com.name] = "cluster_" ~ prepareName(com.name);
	
		output.format(3 + ei, "subgraph cluster_%s {\n", prepareName(com.name));
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
			"cluster_%s_dummy [ width=\"0\" shape=none " ~ 
			"label = \"\", style = invis ];\n", 
			prepareName(com.name)
		);
		output.format(3 + ei, "}\n");
	}

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
	output.generateSoftwareSystemTopMatter(ss, names, nameMappings);
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
		output.generateContainer(it, names, nameMappings);
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
		output.generateContainerComponents(it, names, nameMappings);
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
		output.generateContainer(ss, names, nameMappings);
	} else {
		names.insert(ss.name);
		nameMappings[ss.name] = "cluster_" ~ prepareName(ss.name);

		output.format(2 + ei, "subgraph cluster_%s {\n", prepareName(ss.name));
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
		output.generateContainer(ss, names, nameMappings);
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
			output.generateComponents(it, names, nameMappings);
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
			output.generateComponents(it, names, nameMappings, ei + 1);
		}

		output.format(3 + ei, 
			"cluster_%s_dummy [ width=\"0\" shape=none label = \"\", style = invis ];\n", 
			prepareName(ss.name)
		);
		output.format(3 + ei, "}\n");
	}
}
