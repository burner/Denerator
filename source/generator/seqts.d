module generator.seqts;

import std.experimental.logger;

import generator.cstyle;

private enum ST = "SeqTS";

class HasOne : ConnectionImpl {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

class HasMany : ConnectionImpl {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

class BelongsTo : ConnectionImpl {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

class BelongsToMany : ConnectionImpl {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

class ForeignKey : ConnectionImpl {
	this(in string name, in Entity parent) {
		super(name, parent);
	}
}

class SeqelizeTS : CStyle {
	import std.uni : toLower;
	import util;
	import exceptionhandling;

	this(in TheWorld world, in string outputDir) {
		super(world, outputDir);
	}

	override string genFileName(const(Class) cls) {
		return toLower(cls.name) ~ ".ts";
	}

	override void generate() {
		super.generate(ST);
	}

	override void generateClass(LTW ltw, const(Class) cls) {
		logf("generateClass");
		if(cls.doNotGenerate == DoNotGenerate.yes) {
			return;
		}

		this.generateImports(ltw, cls);

		format(ltw, 0,
`
@Table({tableName: %1$s})
export class %2$s extends Model<%2$s> {
`, toLower(cls.name), cls.name);

		this.generateMembers(ltw, cls);
		format(ltw, 0, "}\n");
	}

	void generateImports(LTW ltw, const(Class) cls) {
		import model.connections : Dependency;
		format(ltw, 0, 
`import {
	Table,
	Column,
	ForeignKey,
	BelongsTo,
	DataType,
	Default,
	AllowNull,
	AutoIncrement,
	BelongsToMany,
	PrimaryKey,
	Model,
	HasMany
} from 'sequelize-typescript'
`);

		this.generateConnectionImports(ltw, cls);

	}

	override void generateAggregation(LTW ltw, in Aggregation agg) {
	}

	void generateMembers(LTW ltw, const(Class) cls) {
		auto mvs = MemRange!(const(MemberVariable))(cls.members);
		foreach(mv; mvs) {
			foreach(pro; mv.langSpecificAttributes[ST]) {
				format(ltw, 1, "%s\n", pro);
			}
			chain(
				this.generateProtectedEntity(ltw, 
					cast(const(ProtectedEntity))(mv), 1),
				"In Member with name", mv.name, "."
			);
			format(ltw, 0, "%s: ", mv.name);
			chain(
				this.generateType(ltw, cast(const(Type))(mv.type)),
				"In Member with name", mv.name, "."
			);
			format(ltw, 0, ";\n");
		}
		format(ltw, 0, "\n");
		this.generateConnectionMembers(ltw, cls);
	}

	void generateConnectionMembers(LTW ltw, in Class cls) {
		import std.meta : AliasSeq;
		import std.string : lastIndexOf;
		ensure(cls !is null, "Cannot generate imports for null Class");
		EntityHashSet!(ConnectionImpl) allreadyImported;

		foreach(EdgeType; AliasSeq!(ForeignKey, HasMany,
					BelongsTo, BelongsToMany, HasOne
				))
		{
			//logf("%s", EdgeType.stringof);
			foreach(con; entityRange!(const(EdgeType))(&this.world.connections)) {
				auto to = cast(Class)(con.to);
				auto from = cast(Class)(con.from);
				if(to !is null && from is cls 
						&& cast(ConnectionImpl)(con) !in allreadyImported)
				{
					logf("EdgeType %s", EdgeType.stringof);
					if(is(EdgeType == ForeignKey)) {
						format(ltw, 1, "@ForeignKey(() => %s)\n", to.name);
						format(ltw, 1, "%s: %s;\n\n", con.name, to.name);
					} else if(is(EdgeType == BelongsToMany)) {
						logf("Class %s, con %s from %s to %s", cls.name, con.name,
								from.name, to.name);
						auto follow = getOtherJunction(from, con);
						auto follow2 = getOtherJunction(to, con);
						logf("%s follow %s %s %s", cls.name, follow.name, follow.from.name, 
								follow.to.name
							);
						logf("%s follow2 %s %s %s", cls.name, follow2.name, follow2.from.name, 
								follow2.to.name
							);
						format(ltw, 1, "@BelongsToMany(() => %s, () => %s)\n", 
								follow.to.name,
								to.name
							);
						auto u = con.name.lastIndexOf("_");
						format(ltw, 1, "%s: %s[];\n\n", 
								con.name[u != -1 ? u + 1 : 0 .. $],
								follow.to.name
							);
					} else if(is(EdgeType == HasMany)) {
						format(ltw, 1, "@HasMany(() => %s)\n", 
								to.name,
							);
						format(ltw, 1, "%s: %s[];\n\n", con.name, to.name);
					} else if(is(EdgeType == BelongsTo)) {
						format(ltw, 1, "@BelongsTo(() => %s)\n", 
								to.name,
							);
						format(ltw, 1, "%s: %s;\n\n", con.name, to.name);
					} else if(is(EdgeType == HasOne)) {
						format(ltw, 1, "@HasOne(() => %s)\n", 
								to.name,
							);
						format(ltw, 1, "%s: %s;\n\n", con.name, to.name);
					}
					allreadyImported.insert(cast(ConnectionImpl)con);
				}
			}
		}
	}

	ConnectionImpl getOtherJunction(in Class cls, in ConnectionImpl a) {
		foreach(con; entityRange!(ConnectionImpl)(&this.world.connections)) {
			logf("goj %s a.to %s", con.name, a.to.name);
			if(con.from is a.to && con !is a && con.to !is cls) {
				logf("found con %s a %s", con.name, a.name);
				return con;
			}
		}
		ensure(false, "Other Junction side not found");
		assert(false);
	}

	void generateConnectionImports(LTW ltw, in Class cls) {
		import std.meta : AliasSeq;
		ensure(cls !is null, "Cannot generate imports for null Class");
		EntityHashSet!(Class) allreadyImported;

		foreach(EdgeType; AliasSeq!(const(ForeignKey), const(HasMany),
					const(BelongsTo), const(BelongsToMany),
					const(HasOne)
				))
		{
			//logf("%s", EdgeType.stringof);
			foreach(con; entityRange!(EdgeType)(&this.world.connections)) {
				auto to = cast(Class)(con.to);
				if(to !is null && con.from is cls 
						&& to !in allreadyImported && to !is cls) 
				{
					//logf("%s %s %s", cls.name, con.from !is null,
					//	con.from !is null ? con.from.name : ""
					//);
					this.generateImport(ltw, to);
					allreadyImported.insert(to);
				}
			}
		}
	}

	string holdsContainerNameTrim(string[] paths) {
		import std.string : indexOf;

		foreach(string str; paths) {
			if(str.indexOf(this.curCon.name) != -1) {
				auto dot = str.indexOf('.');
				if(dot != -1) {
					return str[dot + 1 .. $];
				}
			}
		}

		return "";
	}

	void generateImport(LTW ltw, in Class cls) {
		import std.string : lastIndexOf, indexOf;
		import std.array : replace;
		import std.algorithm : joiner;
		auto name = holdsContainerNameTrim(cls.pathsToRoot());
		auto dot = name.indexOf('.');
		auto lastDot = name.lastIndexOf('.');
		string iName = name[(lastDot == -1 ? 0 : lastDot + 1) .. $];
		string pname = name[(dot == -1 ? 0 : dot + 1) .. $];
		format(ltw, 0, "import { %s } from \"./%s\";\n", 
				iName,
				toLower(replace(pname,".","/")));
	}

	void generateCtor(LTW ltw, in Class cls, const FilterConst fc) {
	}

	void generateMemberFunctions(LTW ltw, in Class cls, string prefix = "") {
	}

	void generateMemberFunctionImpl(LTW ltw, in Class cls, string prefix = "") {
	}

	void generateProtectedEntity(LTW ltw, in ProtectedEntity pe, 
			in int indent = 0) 
	{
		super.generateProtectedEntity(ltw, pe, indent);
	}

	void generateType(Out)(ref Out ltw, in Type type, in int indent = 0) {
		super.generateType(ltw, type, indent);
	}	
}

import generator.graphviz;

class GraphvicSeqTS : Graphvic {
	import graph;

	this(in TheWorld world, in string outputDir) {
		super(world, outputDir);
	}

	alias generate = super.generate;

	void generate(in ForeignKey con, Edge e) {
		e.arrowStyleTo = "\"none\"";
		e.arrowStyleFrom = "\"diamond\"";
	}

	void generate(in HasMany con, Edge e) {
		e.arrowStyleTo = "\"none\"";
		e.arrowStyleFrom = "\"vee\"";
	}

	void generate(in BelongsTo con, Edge e) {
		e.arrowStyleTo = "\"none\"";
		e.arrowStyleFrom = "\"box\"";
	}

	void generate(in BelongsToMany con, Edge e) {
		e.arrowStyleTo = "\"none\"";
		e.arrowStyleFrom = "\"dot\"";
	}

	override void generate(in ConnectionImpl con, Edge e) {
		e.label = format(
			//"<<table border=\"0\" cellborder=\"0\">\n<tr><td>%s</td></tr>\n%s</table>>",
			"<<table border=\"0\" cellborder=\"0\">\n%s</table>>",
			//con.name,
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
		} else if(auto c = cast(const ForeignKey)con) {
			generate(c, e);
		} else if(auto c = cast(const BelongsToMany)con) {
			generate(c, e);
		} else if(auto c = cast(const BelongsTo)con) {
			generate(c, e);
		} else if(auto c = cast(const HasMany)con) {
			generate(c, e);
		} else {
			//auto c = cast(const ConnectionImpl)con;
			//generate(c, e);
		}
		/*} else if(auto c = cast(const HasOne)con) {
			generate(c, e);
		} else if(auto c = cast(const HasMany)con) {
			generate(c, e);
		} else if(auto c = cast(const BelongsToMany)con) {
			generate(c, e);
		} else if(auto c = cast(const ForeignKey)con) {
			generate(c, e);
		} else {
			assert(false, con.name);
		}*/
	}
}
