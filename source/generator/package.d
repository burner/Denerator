module generator;

import containers.dynamicarray;

import model;

abstract class Generator {
	import std.file : exists, isDir, mkdirRecurse;
	import std.stdio : File, writef, writeln;

	string genFolder;
	const(TheWorld) world;

	this(in TheWorld world) {
		this.world = world;
	}

	abstract void generate();

	static void createFolder(ref DynamicArray!string foldernames) {
		foreach(it; foldernames) {
			writef("%s ", it);
		}
		writeln();
	}

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
	import std.typecons : Rebindable;
	const(Member)[] mem;
	Rebindable!(const(Member)) curMem;

	static auto opCall(const(Member)[] m) {
		MemRange!(T) ret;
		ret.mem = m;
		ret.step();
		return ret;
	}

	void step() {
		import std.array : empty, front;
		while(!this.mem.empty) {
			this.curMem = this.mem.front;
			this.mem = this.mem[1 .. $];
			if(cast(T)(this.curMem)) {
				return;
			} 
		}
		this.curMem = null;
	}

	bool empty() @property const nothrow {
		import std.array : empty;
		return this.mem.empty && this.curMem is null;
	}

	@property T front() {
		import std.array : front;
		return cast(T)this.curMem;
	}

	void popFront() {
		this.step();
	}
}

void removeBack(T)(ref DynamicArray!T stack) {
	stack.remove(stack.length -1);
}
