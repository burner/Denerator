module model;

import std.array : array, empty, front, split, appender;
import std.format : format, formattedWrite;
import std.stdio : writeln;
import std.traits : BaseClassesTuple, functionAttributes, FunctionAttribute;
import std.experimental.allocator.mallocator : Mallocator;
import std.exception : enforce;
import containers.hashmap;
import containers.hashset;
import containers.dynamicarray;

public import model.actor;
public import model.class;
public import model.component;
public import model.connections;
public import model.container;
public import model.entity;
public import model.softwaresystem;
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

const(Entity) holdsEntitySingleImpl(T)(const Entity needle, ref T arg) {
	foreach(key; arg.keys()) {
		auto entity = arg[key];
		if(needle is entity) {
			return entity;
		}
	}

	return null;
}

const(Entity) holdsEntityImpl(T...)(const(Entity) needle, in ref T args) {
	foreach(ref arg; args) {
		foreach(const(string) key, const(Entity) entity; arg) {
			if(needle is entity) {
				return entity;
			}
		}
	}

	return null;
}
