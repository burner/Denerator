module generator.seqts;

import std.experimental.logger;

import generator.cstyle;

private enum ST = "SeqTS";

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
