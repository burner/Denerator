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

	void generate(in BelongsToMany con, Edge e) {
		e.arrowStyleTo = "\"none\"";
		e.arrowStyleFrom = "\"odiamond\"";
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
