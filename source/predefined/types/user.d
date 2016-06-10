module predefined.types.user;

import predefined.types.basictypes;

import model.world;
import model.type;
import model.classes;

Class userClass(Con...)(TheWorld world, Con cons) {
	Class user = getOrNewClass("User", cons);

	user.containerType["D"] = "struct";
	user.containerType["Angular"] = "struct";
	user.containerType["MySQL"] = "Table";

	MemberVariable userId = user.getOrNew!MemberVariable("id");
	userId.type = world.getOrNewType("ULong");
	userId.typeMod = new TypeModifier("const", null);
	userId.typeMod.addTypeMod("D", "const");
	assert(userId.type);
	userId.addLangSpecificAttribute("MySQL", "PRIMARY KEY");
	userId.addLangSpecificAttribute("MySQL", "AUTO INCREMENT");
	userId.addLangSpecificAttribute("D", "const");
	userId.addLangSpecificAttribute("Typescript", "const");

	MemberVariable firstname = user.getOrNew!MemberVariable("firstname");
	firstname.type = world.getOrNewType("String");
	assert(firstname.type);

	MemberVariable middlename = user.getOrNew!MemberVariable("middlename");
	middlename.type = world.getOrNewType("String");
	assert(middlename.type);

	MemberVariable lastname = user.getOrNew!MemberVariable("lastname");
	lastname.type = world.getOrNewType("String");
	assert(lastname.type);

	MemberVariable passwordHash = user.getOrNew!MemberVariable("password");
	passwordHash.type = world.getOrNewType("PasswordHash");
	assert(passwordHash.type);

	return user;
}
