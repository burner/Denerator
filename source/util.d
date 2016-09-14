module util;

auto chain(ET = Exception, F, int line = __LINE__, string file = __FILE__, Args...)
		(lazy F exp, lazy Args args)
{
	try {
		return exp();
	} catch(Exception e) {
		throw new ET(joinElem(args), file, line, e);
	}
}

struct First {
	bool first = true;

	auto opCall(Frst,NtFrst)(auto ref Frst f, auto ref NtFrst n) {
		import std.traits : isCallable;

		static assert(isCallable!Frst);
		static assert(isCallable!NtFrst);

		if(this.first) {
			this.first = false;
			return f();
		} else {
			return n();
		}
	}

	void reset() @safe pure nothrow @nogc {
		this.first = true;
	}

	auto opCast(T)() @safe pure nothrow @nogc {
		static if(is(T == bool)) {
			bool ret = this.first;
			this.first = false;
			return ret;
		} else {
			static assert(false, "The First type can only cast itself "
				~ "to bool not "~ T.stringof
			);
		}
	}
}

string joinElem(Args...)(lazy Args args) {
	import std.array : appender;
	import std.format : formattedWrite;	

	auto app = appender!string();
	foreach(arg; args) {
		formattedWrite(app, "%s ", arg);
	}
	return app.data;
}
