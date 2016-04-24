import std.stdio : writeln;

import model;
import generator.graphviz;
import generator.mysql;
import std.stdio : writeln;
import std.typecons;

void main() {
	auto world = new TheWorld("TheWorld");
	Actor users = world.getOrNewActor("The Users");
	users.description = "This is a way to long description for something "
		~ "that should be obvious.";

	auto system = world.getOrNewSoftwareSystem("AwesomeSoftware");
	system.description = "The awesome system to develop.";
	Container frontend = system.getOrNewContainer("Frontend");
	frontend.technology = "Angular";
	auto frontendUserCtrl = frontend.getOrNewComponent("frontUserCtrl");
	auto frontendStuffCtrl = frontend.getOrNewComponent("frontStuffCtrl");
	auto hardware = world.getOrNewHardwareSystem("SomeHardware");

	auto usersFrontend = world.getOrNew!Dependency("userDepFrontend",
		users, frontendUserCtrl
	);
	usersFrontend.description = "Uses the frontend to do stuff.";
	world.getOrNew!Dependency("userDepStuffCtrl",
		users, frontendStuffCtrl
	).description = "Uses the Stuff Logic of the Awesome Software";
	usersFrontend.description = "Uses the frontend to do stuff.";

	Container server = system.getOrNewContainer("Server");
	server.technology = "D";
	world.getOrNew!Dependency("frontendServerDep", frontend, server)
		.description = "HTTPS";

	auto serverUserCtrl = server.getOrNewComponent("serverUserCtrl");
	auto frontendHardwareLink = world.getOrNew!Dependency("frontendUsesHardware",
		serverUserCtrl, hardware
	);

	auto serverUserSub = serverUserCtrl.getOrNewSubComponent("utils").
		description = "Best component name ever!";

	auto database = system.getOrNewContainer("Database");
	database.technology = "MySQL";
	world.getOrNew!Dependency("serverDatabase",
		server, database
	).description = "CRUD";

	Type str = world.getOrNewType("String");
	str.typeToLanguage["D"] = "string";
	str.typeToLanguage["Angular"] = "string";
	str.typeToLanguage["MySQL"] = "text";

	Type integer = world.getOrNewType("Int");
	integer.typeToLanguage["D"] = "long";
	integer.typeToLanguage["Angular"] = "number";
	integer.typeToLanguage["MySQL"] = "long";

	Class user = getOrNewClass("User", frontendUserCtrl, 
		serverUserCtrl, database
	);

	user.containerType["D"] = "struct";
	user.containerType["class"] = "struct";

	MemberVariable userId = user.getOrNew!MemberVariable("id");
	userId.type = integer;
	userId.addLandSpecificAttribue("MySQL", "PRIMARY KEY");
	auto userFirstname = user.getOrNew!MemberVariable("firstname");
	userFirstname.type = str;
	auto userLastname = user.getOrNew!MemberVariable("lastname");
	userLastname.type = str;

	Class address = getOrNewClass("Address", 
		frontendUserCtrl, serverUserCtrl, database
	);
	MemberFunction func = address.getOrNew!MemberFunction("func");
	func.returnType = integer;

	func.getOrNew!MemberVariable("a").type = integer;
	func.getOrNew!MemberVariable("b").type = str;

	Aggregation userAddress = world.getOrNew!Aggregation("userEmployee",
		address, user
	);

	Graphvic gv = new Graphvic(world, "GraphvizOutput");
	gv.generate();

	MySQL mysql = new MySQL(world, "MySQL");
	mysql.generate();
	mysql.generate(database);
	
}
