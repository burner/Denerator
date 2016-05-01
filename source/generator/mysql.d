module generator.mysql;

import std.exception : enforce;
import std.stdio;
import std.algorithm.iteration : map, filter, joiner;
static import std.format;

import generator;
import model;

class MySQL : Generator {
	const(string) outputDir;
	Container currentContainer;

	this(in TheWorld world, in string outputDir) {
		super(world);
		this.outputDir = outputDir;
		enforce(Generator.createFolder(outputDir));
	}

	override void generate() {}	

	void generate(Container con) {
		assert(con.technology == "MySQL");
		this.currentContainer = con;

		foreach(it; con.classes.keys()) {
			Class cls = con.classes[it]; 
			this.generateClass(cls);
		}

		foreach(it; this.world.connections.keys()) {
			Aggregation com = cast(Aggregation)this.world.connections[it]; 
			if(com !is null) {
				this.generateAggregation(com);
			}
		}
	}
	private void generateAggregation(Aggregation agg) {

		SearchResult fromSR = this.currentContainer.holdsEntity(agg.from);
		SearchResult toSR = this.currentContainer.holdsEntity(agg.to);

		if(fromSR.entity !is null 
				&& fromSR.entity !is null
				&& toSR.entity !is null)
		{
			writeln(agg.name);
			auto f = Generator.createFile([this.outputDir, 
				std.format.format("%s_%s.sql", agg.from.name, agg.to.name)
			]);
			auto ltw = f.lockingTextWriter();
			format(ltw, 0, "CREATE TABLE %s_%s {\n", 
				agg.from.name, agg.to.name
			);

			bool first = true;
			//format(ltw, 1, "id LONG PRIMARY KEY AUTO INCREMENT");

			MemberVariable[] foreignKeys = 
				this.getPrivateKeyFromMemberVariable(cast(Class)agg.to);
			this.genForeignKeyFromMemberVariables(ltw, agg.to.name,
				foreignKeys, first
			);

			foreignKeys = 
				this.getPrivateKeyFromMemberVariable(cast(Class)agg.from);
			this.genForeignKeyFromMemberVariables(ltw, agg.from.name,
				foreignKeys, first
			);
			format(ltw, 0, "\n)\n");
		}
	}

	private void generateClass(Class cls) {
		writeln(cls.name);
		auto f = Generator.createFile([this.outputDir, cls.name ~ ".sql"]);
		auto ltw = f.lockingTextWriter();
		//auto ltw = stdout.lockingTextWriter();

		format(ltw, 0, "CREATE TABLE %s {\n", cls.name);

		bool first = true;
		foreach(it; cls.members.keys()) {
			Member mem = cls.members[it];
			MemberVariable mv = cast(MemberVariable)mem;
			if(mv is null) {
				continue;
			}
			if(!first) {
				ltw.format(0, ",\n");
			}
			first = false;

			ltw.format(1, "%s ", mv.name);
			assert(this.currentContainer.technology in mv.type.typeToLanguage);
			ltw.format(0, "%s", 
				mv.type.typeToLanguage[this.currentContainer.technology]
			);

			if(this.currentContainer.technology in mv.langSpecificAttributes) {
				string[] lsa = mv.langSpecificAttributes[
					this.currentContainer.technology
				];
				foreach(jt; lsa) {
					ltw.format(0, " %s", jt);
				}
			}
		}

		foreach(it; this.world.connections.keys()) {
			Composition com = cast(Composition)this.world.connections[it];
			if(com !is null && com.from is cls) {
				MemberVariable[] foreignKeys = 
					this.getPrivateKeyFromMemberVariable(cast(Class)com.to);
				this.genForeignKeyFromMemberVariables(ltw, com.to.name,
					foreignKeys, first
				);
			}
		}

		ltw.format(0, "\n);\n");
	}

	private void genForeignKeyFromMemberVariables(O)(ref O ltw, string name, 
			MemberVariable[] foreignKeys, ref bool first) 
	{
		foreach(mem; foreignKeys) {
			if(!first) {
				ltw.format(0, ",\n");
			}
			first = false;
			ltw.format(1, "%s_%s %s", name, mem.name,
				mem.type.typeToLanguage[this.currentContainer.technology]
			);
		}

		ltw.format(0, "\n");
		ltw.format(1, "FOREIGN KEY(%s) REFERENCES %s(%s) ON UPDATE CASCADE ON DELETE CASCADE",
			foreignKeys.map!(a => std.format.format("%s_%s", name, a.name)
			)
			.joiner(", "),
			name,
			foreignKeys.map!(a => std.format.format("%s", a.name))
			.joiner(", ")
		);
	}

	private MemberVariable[] getPrivateKeyFromMemberVariable(Class cls) {
		import std.algorithm.searching : canFind;
		assert(cls !is null);

		MemberVariable[] ret;

		foreach(it; cls.members.keys()) {
			MemberVariable mv = cast(MemberVariable)cls.members[it];
			if(mv !is null 
				&& this.currentContainer.technology in mv.langSpecificAttributes
				&& mv.langSpecificAttributes[this.currentContainer.technology]
					.canFind("PRIMARY KEY"))
			{
				ret ~= mv;
			}
		}

		return ret;

	}
}
