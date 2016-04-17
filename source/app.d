import std.stdio;

import model;
import std.stdio : writeln;

void main() {
	auto world = new TheWorld("TheWorld");
	auto user = world.getOrNewActor("User");

	auto system = world.getOrNewSoftwareSystem("AwesomeSoftware");
	auto frontend = system.getOrNewContainer("Frontend");
	auto frontendUserCtrl = frontend.getOrNewComponent("frontUserCtrl");

	Container server = system.getOrNewContainer("Server");
	auto serverUserCtrl = server.getOrNewComponent("serverUserCtrl");

	auto database = system.getOrNewContainer("Server");
	auto dbUserDatabase = server.getOrNewComponent("dbUserDatabase");

	Type str = world.getOrNewType("String");
	str.typeToLanguage["D"] = "string";
	str.typeToLanguage["Typestrict"] = "string";
	str.typeToLanguage["MySQL"] = "text";

	Type integer = world.getOrNewType("Int");
	integer.typeToLanguage["D"] = "long";
	integer.typeToLanguage["Typestrict"] = "number";
	integer.typeToLanguage["MySQL"] = "long";

	Class userClass = getOrNewClass("User", frontendUserCtrl, 
		serverUserCtrl, dbUserDatabase
	);

	userClass.containerType["D"] = "struct";
	userClass.containerType["class"] = "struct";

	MemberVariable userId = userClass.getOrNew!MemberVariable("id");
	userId.addLandSpecificAttribue("MySQL", "PRIMARY KEY");
	auto userFirstname = userClass.getOrNew!MemberVariable("firstname");
	auto userLastname = userClass.getOrNew!MemberVariable("lastname");

	Class employee = getOrNewClass("Employee", 
		frontendUserCtrl, serverUserCtrl, dbUserDatabase
	);
}
