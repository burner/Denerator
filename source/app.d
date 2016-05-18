import std.stdio : writeln;

import model;
import duplicator;
import generator.graphviz;
import generator.graphviz2;
import generator.graphviz3;
import generator.mysql;
import std.stdio : writeln;
import std.typecons;
import std.experimental.logger;
import containers.hashmap;

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
	auto world = new TheWorld("TheWorld");
	Actor users = world.getOrNewActor("The Users");
	users.description = "This is a way to long description for something "
		~ "that should be obvious.";

	writeln(users.toString());

	auto system = world.getOrNewSoftwareSystem("AwesomeSoftware");
	system.description = "The awesome system to develop.";
	Container frontend = system.getOrNewContainer("Frontend");
	frontend.technology = "Angular";
	auto frontendUserCtrl = frontend.getOrNewComponent("frontUserCtrl");
	auto frontendStuffCtrl = frontend.getOrNewComponent("frontStuffCtrl");
	auto hardware = world.getOrNewHardwareSystem("SomeHardware");

	auto system2 = world.getOrNewSoftwareSystem("LagacySoftwareSystem");
	system2.description = "You don't want to touch this.";

	auto usersFrontend = world.getOrNew!Connection("userDepFrontend",
		users, frontendUserCtrl
	);
	usersFrontend.description = "Uses the frontend to do stuff.";
	world.getOrNew!Connection("userDepStuffCtrl",
		users, frontendStuffCtrl
	).description = "Uses the Stuff Logic of the Awesome Software";
	usersFrontend.description = "Uses the frontend to do stuff.";

	Container server = system.getOrNewContainer("Server");
	server.technology = "D";
	world.getOrNew!Connection("frontendServerDep", frontend, server)
		.description = "HTTPS";

	world.getOrNew!Connection("serverSS2", server, system2).description =
		"To bad we have to use that.";

	auto serverUserCtrl = server.getOrNewComponent("serverUserCtrl");
	auto frontendHardwareLink = world.getOrNew!Connection("frontendUsesHardware",
		serverUserCtrl, hardware
	);

	auto serverUserSub = serverUserCtrl.getOrNewSubComponent("utils").
		description = "Best component name ever!";

	auto database = system.getOrNewContainer("Database");
	database.technology = "MySQL";
	world.getOrNew!Connection("serverDatabase",
		server, database
	).description = "CRUD";

	Type str = world.getOrNewType("String");
	str.typeToLanguage["D"] = "string";
	str.typeToLanguage["Angular"] = "string";
	str.typeToLanguage["MySQL"] = "TEXT";

	Type integer = world.getOrNewType("Int");
	integer.typeToLanguage["D"] = "long";
	integer.typeToLanguage["Angular"] = "number";
	integer.typeToLanguage["MySQL"] = "LONG";

	Class user = getOrNewClass("User", frontendUserCtrl, 
		serverUserCtrl, database
	);

	user.containerType["D"] = "struct";
	user.containerType["class"] = "struct";

	MemberVariable userId = user.getOrNew!MemberVariable("id");
	userId.type = integer;
	userId.protection["D"] = "private";
	userId.addLandSpecificAttribute("MySQL", "PRIMARY KEY");
	userId.addLandSpecificAttribute("MySQL", "AUTO INCREMENT");
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

	MemberVariable addressId = address.getOrNew!MemberVariable("id");
	addressId.type = integer;
	addressId.addLandSpecificAttribute("MySQL", "PRIMARY KEY");

	Aggregation userAddress = world.getOrNew!Aggregation("addressUser",
		address, user
	);

	Class postalCode = getOrNewClass("PostalCode", database);
	MemberVariable pcID = postalCode.getOrNew!MemberVariable("id");
	pcID.type = integer;
	pcID.addLandSpecificAttribute("MySQL", "PRIMARY KEY");
	pcID.addLandSpecificAttribute("MySQL", "AUTO INCREMENT");
	MemberVariable pcCode = postalCode.getOrNew!MemberVariable("code");
	pcCode.type = integer;

	auto addressPC = world.getOrNew!Composition("addressPostalCode",
		postalCode, address
	);

	auto copy = duplicateNodes(world);

	//Graphvic gv = new Graphvic(world, "GraphvizOutput");
	//gv.generate();

	//Graphvic2 gv2 = new Graphvic2(world, "GraphvizOutput2");
	//gv2.generate();

	Graphvic3 gv3 = new Graphvic3(world, "GraphvizOutput3");
	gv3.generate();

	//MySQL mysql = new MySQL(world, "MySQL");
	//mysql.generate(database);
}
