import std.stdio;

import model;
import std.stdio : writeln;

void main() {
	auto world = new TheWorld("TheWorld");
	auto user = world.getOrNewActor("User");

	auto system = world.getOrNewSoftwareSystem("AwesomeSoftware");
	auto frontend = system.getOrNewContainer("Frontend");
	auto server = system.getOrNewContainer("Server");
	auto database = system.getOrNewContainer("Server");

	Class userClass = getOrNewClass("User", frontend, server, database);
}
