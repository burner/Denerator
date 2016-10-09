module generator.angular2;

import generator.cstyle;

class Angular2 : CStyle {
	this(in TheWorld world, in string outputDir) {
		super(world, outputDir);
	}

	override void generateClass(LTW ltw, const(Class) cls) {
		if(cls.doNotGenerate == DoNotGenerate.yes) {
			return;
		}
	}

	override void generateAggregation(LTW ltw, in Aggregation agg) {

	}
}
