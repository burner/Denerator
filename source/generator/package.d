module generator;

import model;

enum GenerateLevel {
	Context,
	Entity,
	Container,
	Component,
}

abstract class Generator {
	import std.file : exists, isDir, mkdirRecurse;
	import std.stdio : File;

	string genFolder;
	const(TheWorld) world;

	this(in TheWorld world) {
		this.world = world;
	}

	abstract void generate();

	static bool createFolder(in string foldername) {
		if(exists(foldername) && isDir(foldername)) {
			return true;
		} else if(exists(foldername) && !isDir(foldername)) {
			return false;
		} else {
			mkdirRecurse(foldername);
			return exists(foldername) && isDir(foldername);
		}
	}

	static File createFile(in string filename, in string openType = "w") {
		auto ret = File(filename, openType);
		assert(ret.isOpen());
		return ret;
	}

	static File createFile(string[] filenames, in string openType = "w") {
		import std.algorithm.iteration : joiner;
		import std.conv : to;
		return createFile(filenames.joiner("/").to!string(), openType);
	}

	static void deleteFolder(string dir) {
		import std.file : rmdirRecurse;
		if(exists(dir)) {
			rmdirRecurse(dir);
		}
		assert(!exists(dir), dir);
	}
}

string[] wrapLongString(string str, in uint lineLength) @safe pure {
	import std.algorithm.iteration : filter;
	import std.string : splitLines, wrap;
	import std.array : array;
	import std.conv : to;
	auto notabnewline = str.filter!(a => a != '\n' && a != '\t')().array.idup;
	return notabnewline.to!string().wrap(lineLength).splitLines();
}

string prepareName(string name) {
	import std.string : translate;
	dchar[dchar] tt = [' ':'_', '\n':'_', '\t':'_'];
	return translate(name, tt);
}

void generateIndent(O)(ref O output, int indent) {
	indent *= 4;
	for(; indent > 0; --indent) {
		output.put(" ");
	}
}

void format(O,Args...)(ref O output, int indent, in string str, Args args) {
	import std.format : formattedWrite;

	output.generateIndent(indent);
	output.formattedWrite(str, args);
}

struct MemRange(T) {
	const(StringEntityMap!(Member))* mem;
	string[] names;
	string curName;

	static auto opCall(const(StringEntityMap!(Member))* m) {
		MemRange!(T) ret;
		ret.mem = m;
		ret.names = ret.mem.keys();
		ret.step();
		return ret;
	}

	void step() {
		import std.array : empty, front;
		while(!this.names.empty) {
			this.curName = this.names.front;
			this.names = this.names[1 .. $];
			if(cast(T)(mem.get(this.curName,null))) {
				break;
			} 
		}
	}

	bool empty() @property const nothrow {
		import std.array : empty;
		return this.names.empty;
	}

	@property T front() {
		import std.array : front;
		return cast(T)(this.mem.get(this.curName, null));
	}

	void popFront() {
		this.step();
	}
}
