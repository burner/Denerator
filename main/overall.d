module overall;

import std.stdio : writeln;
import std.typecons;
import std.experimental.logger;

import predefined.types.basictypes;
import model;

import app : appModel;
import next_song_calc;
import predefined.types.basictypes;


class NoTimeLogger : Logger {
	import std.stdio : writefln;
    this(LogLevel lv) @safe {
        super(lv);
    }

    override void writeLogMsg(ref LogEntry payload) {
		import std.string : lastIndexOf;
		auto i = payload.file.lastIndexOf("/");
		string f = payload.file;
		if(i != -1) {
			f = f[i+1 .. $];
		}
		writefln("%s:%s | %s", f, payload.line, payload.msg);
    }
}

void main() {
	sharedLog = new NoTimeLogger(LogLevel.all);

	bool ret;
	version(unittest) {
		ret = true;
	}
	logf("%s", ret);
	if(!ret){
	    //Basic setup
        auto world = new TheWorld("World");
        addBasicTypes(world);
        appModel(world);
        nextSongCalcModel(world);
	}
}
