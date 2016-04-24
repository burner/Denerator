module generator.mysql;

import std.exception : enforce;
import std.stdio;

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
	}

	private void generateClass(Class cls) {
		writeln(cls.name);
		//auto f = Generator.createFile([this.outputDir, cls.name ~ ".sql"]);
		//auto ltw = f.lockingTextWriter();
		auto ltw = stdout.lockingTextWriter();

		ltw.format(0, "CREATE TABEL %s {\n", cls.name);

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

		ltw.format(0, "\n);\n");
	}
}
