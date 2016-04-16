module graphgen.context;

import model;
import generator;

class ContextGenerator : Generator {
	this(string genFolder) {
		super(genFolder);
	}

	override void generate(const(GenerateLevel) from, const(GenerateLevel) to,
		ref const(StringHashSet) excludes)
	{
		assert(false);
	}
}
