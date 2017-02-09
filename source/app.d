import std.stdio : writeln;

import std.stdio : writeln;
import std.typecons;
import std.experimental.logger;
import containers.hashmap;

import model;
import duplicator;
import generator.graphviz;
import generator.mysql;
import generator.vibed;
import generator.angular2;
import predefined.types.user;
import predefined.types.group;
import predefined.types.address;
import predefined.types.basictypes;
import predefined.ctrl.userctrl;

import predefined.angular.component;

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
	if(!ret) fun();
}

void fun() {
	auto world = new TheWorld("TheWorld");
	addBasicTypes(world);

	Actor users = world.newActor("The Users");
	users.description = "This is a way to long description for something "
		~ "that should be obvious.";

	Actor admin = world.newActor("The Admin");
	admin.description = "An admin does what an admin does.";

	auto system = world.newSoftwareSystem("AwesomeSoftware");
	system.description = "The awesome system to develop.";
	Container frontend = system.newContainer("Frontend");
	frontend.technology = "Angular2";
	auto frontendUserCtrl = frontend.newComponent("frontUserCtrl");
	auto frontendStuffCtrl = frontend.newComponent("frontStuffCtrl");
	initAngularBaseClasses(world, frontendUserCtrl, frontendStuffCtrl);
	auto hardware = world.newHardwareSystem("SomeHardware");

	auto system2 = world.newSoftwareSystem("LagacySoftwareSystem");
	system2.description = "You don't want to touch this.";

	auto usersFrontend = world.newConnection("userDepFrontend",
		world.getActor("The Users"), frontendUserCtrl
	);
	usersFrontend.description = "Uses the frontend to do stuff.";
	world.newConnection("userDepStuffCtrl",
		users, frontendStuffCtrl
	).description = "Uses the Stuff Logic of the Awesome Software";
	usersFrontend.description = "Uses the frontend to do stuff.";

	{
		const(TheWorld) cw = world;
		const(Actor) ca = world.getActor("The Users");
		assert(ca !is null);
	}

	world.newConnection("adminUser",
		admin, frontendUserCtrl
	).description = "Manager Users";

	Container server = system.newContainer("Server");
	server.technology = "D";
	world.newConnection("frontendServerDep", frontend, server)
		.description = "HTTPS";

	world.newConnection("serverSS2", server, system2).description =
		"To bad we have to use that.";

	auto serverUserCtrl = server.newComponent("serverUserCtrl");
	auto frontendHardwareLink = world.newConnection("frontendUsesHardware",
		serverUserCtrl, hardware
	);

	auto serverUserSub = serverUserCtrl.newSubComponent("utils").
		description = "Best component name ever!";

	auto database = system.newContainer("Database");
	database.technology = "MySQL";
	world.newConnection("serverDatabase",
		server, database
	).description = "CRUD";

	Type str = world.getType("String");
	Type integer = world.getType("Int");

	Class user = userClass(world, frontendUserCtrl, serverUserCtrl, database);
	Class group = groupClass(world, frontendUserCtrl, serverUserCtrl, database);

	Class address = addressClass(world,
		frontendUserCtrl, serverUserCtrl, database
	);

	userCtrl(world, server);

	MemberFunction func = address.newMemberFunction("func");
	func.returnType = integer;

	func.addParameter("a", integer);
	func.addParameter("b", str);

	Aggregation userAddress = world.newAggregation("AddressUser",
		address, user
	);

	Class postalCode = world.newClass("PostalCode", database,
			serverUserCtrl);
	postalCode.containerType["MySQL"] = "Table";
	MemberVariable pcID = postalCode.newMemberVariable("id");
	pcID.type = integer;
	pcID.addLangSpecificAttribute("MySQL", "PRIMARY KEY");
	pcID.addLangSpecificAttribute("MySQL", "AUTO INCREMENT");
	pcID.addLangSpecificAttribute("D", "const");
	MemberVariable pcCode = postalCode.newMemberVariable("code");
	pcCode.type = integer;

	auto addressPC = world.newComposition("addressPostalCode",
		address, postalCode
	);
	addressPC.fromType = world.newType("PostalCode[]");
	addressPC.fromType.typeToLanguage["D"] = "PostalCode[]";

	Class userInfo = genAngularService("UserInfo", world, frontendUserCtrl);

	Graphvic gv = new Graphvic(world, "GraphvizOutput");
	gv.generate();

	MySQL mysql = new MySQL(world, "MySQL");
	mysql.generate(database);

	auto vibed = new VibeD(world, "VibeTestProject");
	vibed.generate();

	auto angular = new Angular2(world, "AngularTestProject");
	angular.generate();
}
