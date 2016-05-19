module model;

import std.array : array, empty, front, split, appender;
import std.format : format, formattedWrite;
import std.stdio : writeln;
import std.traits : BaseClassesTuple, functionAttributes, FunctionAttribute;
import std.experimental.allocator.mallocator : Mallocator;
import std.exception : enforce;

public import model.actor;
public import model.classes;
public import model.component;
public import model.connections;
public import model.container;
public import model.entity;
public import model.softwaresystem;
public import model.hardwaresystem;
public import model.type;
public import model.world;

T convert(T,S)(S s) {
	T ret = cast(T)s;
	if(ret is null) {
		return ret;
	} else {
		throw new Exception("Cannot convert " ~ S.stringof ~ " to " ~
				T.stringof);
	}
}
