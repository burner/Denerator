module generator;

import containers.hashset;
public alias StringHashSet = HashSet!(string);

enum GenerateLevel {
	Context,
	Entity,
	Container,
	Component,
}

abstract class Generator {
	string genFolder;

	this(string genFolder) {
		this.genFolder = genFolder;
	}

	void generate(const(GenerateLevel) from, const(GenerateLevel) to,
		ref const(StringHashSet) excludes
	);
}
