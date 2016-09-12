module generator;

import std.experimental.logger;

import containers.dynamicarray;

import model;

abstract class Generator {
	import std.file : exists, isDir, mkdirRecurse;
	import std.stdio : File, writef, writeln;
	import std.algorithm.iteration : joiner;
	import std.conv : to;
	import std.uni : toLower;

	string genFolder;
	const(TheWorld) world;

	this(in TheWorld world) {
		this.world = world;
	}

	abstract void generate();

	static bool createFolder(Strs)(auto ref Strs foldernames) {
		return createFolder(joiner(foldernames, "/").to!string());
	}

	static bool createFolder(string foldername) {
		//foldername = toLower(foldername);	
		if(exists(foldername) && isDir(foldername)) {
			return true;
		} else if(exists(foldername) && !isDir(foldername)) {
			return false;
		} else {
			mkdirRecurse(foldername);
			return exists(foldername) && isDir(foldername);
		}
	}

	static File createFile(string filename, in string openType = "w") {
		//filename = toLower(filename);
		auto ret = File(filename, openType);
		assert(ret.isOpen());
		return ret;
	}

	static File createFile(string[] filenames, in string openType = "w") {
		return createFile(filenames.joiner("/").to!string(), openType);
	}

	static File createFile(Strs)(auto ref Strs filenames, string filename, in string openType = "w") {
		return createFile(filenames.joiner("/").to!string() ~ "/" ~ filename, openType);
	}

	static void deleteFolder(string dir) {
		import std.file : rmdirRecurse;
		//dir = toLower(dir);
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

auto entityRange(T,S)(S* src) {
	auto ret = EntityRange!(T,S)(src);
	return ret;
}

struct EntityRange(T,S) {
	import std.typecons : Rebindable, Unique, RefCounted;
	Rebindable!(T) curFront;
	bool isEmpty;
	RefCounted!(string[]) names;
	size_t curIdx;
	S* source;

	static auto opCall(S)(S* source) {
		EntityRange!(T,S) ret;
		ret.curIdx = 0;
		ret.source = source;	
		ret.names = source.keys();

		ret.isEmpty = ret.prepareStep();
		//logf("%s", ret.isEmpty);
		ret.step();
		ret.isEmpty = ret.prepareStep();
		return ret;
	}

	bool prepareStep() {
		while(this.curIdx < names.length) {
			string idx = this.names[this.curIdx];
			if(cast(T)((*this.source)[idx])) {
				return false;
			} else {
				++curIdx;
			}
		}
		return true;
	}

	void step() {
		import std.array : empty, front;
		if(this.isEmpty) {
			this.curFront = null;
		} else {
			size_t cIdx = this.curIdx;
			//logf("%s %s", cIdx, this.names.length);
			string idx = this.names[cIdx];
			//logf(idx);
			this.curFront = cast(T)(*this.source)[idx];
			++this.curIdx;
			this.isEmpty = this.prepareStep();
		}
	}

	bool empty() @property const nothrow {
		import std.array : empty;
		return this.isEmpty && this.curFront is null;
	}

	@property T front() {
		import std.array : front;
		return cast(T)this.curFront;
	}

	void popFront() {
		this.step();
		//logf("%s %s empty %s", this.curIdx, this.names.length, this.isEmpty);
	}
}

void removeBack(T)(ref DynamicArray!T stack) {
	stack.remove(stack.length -1);
}
