module generator.golanggin;

import generator.cstyle;

class GoLangGin : CStyle {
	this(in TheWorld world, in string outputDir) {
		super(world, outputDir);
	}

	override void generate() {
		super.generate("golanggin");
	}
}
