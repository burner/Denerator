module generator.mysql;

import std.exception : enforce;
import std.stdio;
import std.algorithm.iteration : map, filter, joiner;
static import std.format;
import std.typecons : Rebindable;

import generator;
import model;

class MySQL : Generator {
	const(string) outputDir;
	Rebindable!(const(Container)) currentContainer;

	this(in TheWorld world, in string outputDir) {
		super(world);
		this.outputDir = outputDir;
		deleteFolder(this.outputDir);
		enforce(Generator.createFolder(outputDir));
	}

	override void generate() {}	

	void generate(in Container con) {
		assert(con.technology == "MySQL");
		this.currentContainer = con;

		foreach(it; con.classes.keys()) {
			const(Class) cls = con.classes[it]; 
			this.generateClass(cls);
		}

		EntityHashSet!(Entity) es;
		es.insert(cast(Entity)con);
		foreach(it; this.world.connections.keys()) {
			Aggregation com = cast(Aggregation)this.world.connections[it]; 
			if(com && com.to && com.from) {
				if(com.to.areYouIn(es) is con && com.from.areYouIn(es) is con) {
					this.generateAggregation(com);
				}
			}
		}
	}

	void generateAggregation(Aggregation agg) {
		writeln(agg.name);
		auto f = Generator.createFile([this.outputDir, 
			std.format.format("%s_%s.sql", agg.from.name, agg.to.name)
		]);
		auto ltw = f.lockingTextWriter();
		format(ltw, 0, "CREATE TABLE %s_%s {\n", 
			agg.from.name, agg.to.name
		);

		bool first = true;

		const(MemberVariable)[] foreignKeys = 
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

	void genForeignKeyFromMemberVariables(O)(ref O ltw, string name, 
			const(MemberVariable)[] foreignKeys, ref bool first) 
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
		ltw.format(1, 
			"FOREIGN KEY(%s) REFERENCES %s(%s) ON UPDATE CASCADE " ~
		    "ON DELETE CASCADE",
			foreignKeys.map!(a => std.format.format("%s_%s", name, a.name))
				.joiner(", "),
			name,
			foreignKeys.map!(a => std.format.format("%s", a.name))
				.joiner(", ")
		);
	}

	void generateMember(Out)(ref Out ltw, ref bool first, in MemberVariable mv,
		   	in string prefix = "") 
	{
		import std.array : empty;
		if(mv is null) {
			return;
		}
		if(!first) {
			ltw.format(0, ",\n");
		}
		first = false;

		if(prefix.empty) {
			ltw.format(1, "%s ", mv.name);
		} else {
			ltw.format(1, "%s_%s ", prefix, mv.name);
		}
		assert(this.currentContainer.technology in mv.type.typeToLanguage);
		ltw.format(0, "%s", 
			mv.type.typeToLanguage[this.currentContainer.technology]
		);
	}

	void generateAlterTables(in Class to, in Class from, in MemberVariable mv) {
		auto f = Generator.createFile([this.outputDir, 
			from.name ~ "_alter.sql"], "a"
		);
		auto ltw = f.lockingTextWriter();
		format(ltw, 0, 
			"ALTER TABLE %s ADD FOREIGN KEY(%s_%s) REFERENCES %s(%s);\n",
			from.name, to.name, mv.name, to.name, mv.name
		);
		format(ltw, 0, 
			"ALTER TABLE %s ADD CONSTRAINT %s_%s_FK FOREIGN KEY(%s_%s) " ~
			"REFERENCES %s(%s) ON UPDATE CASCADE ON DELETE CASCADE;\n",
			from.name, to.name, from.name, to.name, mv.name, to.name, mv.name
		);
	}

	void generateClass(in Class cls) {
		writeln(cls.name);
		auto f = Generator.createFile([this.outputDir, cls.name ~ ".sql"]);
		auto ltw = f.lockingTextWriter();

		format(ltw, 0, "CREATE TABLE %s (\n", cls.name);

		bool first = true;
		foreach(mv; MemRange!(const MemberVariable)(&cls.members)) {
			generateMember(ltw, first, mv);

			if(mv && 
					this.currentContainer.technology in mv.langSpecificAttributes) 
			{
				const(string[]) lsa = mv.langSpecificAttributes[
					this.currentContainer.technology
				];
				foreach(jt; lsa) {
					ltw.format(0, " %s", jt);
				}
			}
		}

		foreach(it; this.world.connections.keys()) {
			auto com = cast(const Composition)this.world.connections[it];
			if(com !is null && com.from is cls) {
				const(MemberVariable)[] foreignKeys = 
					this.getPrivateKeyFromMemberVariable(cast(const Class)com.to);
				writefln("\t%s", com.to.name);
				foreach(const(MemberVariable) jt; foreignKeys) {
					generateMember(ltw, first, jt, com.to.name);
					generateAlterTables(cast(const Class)com.to, 
						cast(const Class)com.from, jt
					);
				}
			}
		}

		ltw.format(0, "\n);\n");
	}

	private const(MemberVariable)[] getPrivateKeyFromMemberVariable(in Class cls) {
		import std.algorithm.searching : canFind;
		assert(cls !is null);

		const(MemberVariable)[] ret;

		foreach(mv; MemRange!(const MemberVariable)(&cls.members)) {
			if(this.currentContainer.technology in mv.langSpecificAttributes
				&& mv.langSpecificAttributes[this.currentContainer.technology]
					.canFind("PRIMARY KEY"))
			{
				ret ~= mv;
			}
		}

		return ret;
	}
}
