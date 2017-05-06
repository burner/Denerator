module generator.vibedbson;

import generator.vibed;
import generator.cstyle;

class VibedBson : VibeD {
	this(in TheWorld world, in string outputDir) {
		super(world, outputDir);
	}

	alias generate = VibeD.generate;

	override void generate() {
		generate("VibedBson");
	}

	override void generateMemberFunction(LTW ltw, in Class cls, 
			string prefix = "") 
	{
		// BSon struct do not have member
	}
}
