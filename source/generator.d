module generator;

abstract class Generator {
	string genFolder;

	this(string genFolder) {
		this.genFolder = genFolder;
	}

	void generate();
}
