import std.stdio : writeln;

import std.stdio : writeln;
import std.typecons;
import std.experimental.logger;
import containers.hashmap;

import model;
import duplicator;
import generator.graphviz;
import generator.mysql2;
import generator.vibed;
import predefined.types.user;
import predefined.types.address;
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
	auto world = new TheWorld("TheWorld");
	addBasicTypes(world);

	Actor users = world.getOrNewActor("The Users");
	users.description = "This is a way to long description for something "
		~ "that should be obvious.";

	Actor admin = world.getOrNewActor("The Admin");
	admin.description = "An admin does what an admin does.";

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

	world.getOrNew!Connection("adminUser",
		admin, frontendUserCtrl
	).description = "Manager Users";

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

	Class user = userClass(world, frontendUserCtrl, serverUserCtrl, database);

	Class address = addressClass(world,
		frontendUserCtrl, serverUserCtrl, database
	);

	MemberFunction func = address.getOrNew!MemberFunction("func");
	func.returnType = integer;

	func.getOrNew!MemberVariable("a").type = integer;
	func.getOrNew!MemberVariable("b").type = str;

	Aggregation userAddress = world.getOrNew!Aggregation("addressUser",
		address, user
	);

	Class postalCode = getOrNewClass("PostalCode", database);
	postalCode.containerType["MySQL"] = "Table";
	MemberVariable pcID = postalCode.getOrNew!MemberVariable("id");
	pcID.type = integer;
	pcID.addLangSpecificAttribute("MySQL", "PRIMARY KEY");
	pcID.addLangSpecificAttribute("MySQL", "AUTO INCREMENT");
	MemberVariable pcCode = postalCode.getOrNew!MemberVariable("code");
	pcCode.type = integer;

	auto addressPC = world.getOrNew!Composition("addressPostalCode",
		postalCode, address
	);

	//Graphvic gv = new Graphvic(world, "GraphvizOutput");
	//gv.generate();

	MySQL2 mysql = new MySQL2(world, "MySQL2");
	mysql.generate(database);

	//auto vibed = new VibeD(world, "vibed");
	//vibed.generate(server);
}
