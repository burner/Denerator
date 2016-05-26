module predefined.types.user;

import predefined.types.basictypes;

import model.world;
import model.type;
import model.class;

Class userClass(Con...)(TheWorld world, Con cons) {
	Class user = getOrNewClass("User", cons);

	user.containerType["D"] = "struct";
	user.containerType["Angular"] = "struct";
	user.containerType["MySQL"] = "Table";

	MemberVariable userId = user.getOrNew!MemberVariable("id");
	userId.type = world.getOrNewType("ULong");
	userId.protection["D"] = "private";
	userId.addLangSpecificAttribute("MySQL", "PRIMARY KEY");
	userId.addLangSpecificAttribute("MySQL", "AUTO INCREMENT");

	MemberVariable firstname = user.getOrNew!MemberVariable("firstname");
	firstname.type = world.getOrNewType("String");

	MemberVariable middlename = user.getOrNew!MemberVariable("middlename");
	firstname.type = world.getOrNewType("String");

	MemberVariable lastname = user.getOrNew!MemberVariable("lastname");
	lastname.type = world.getOrNewType("String");

	return user;
}
