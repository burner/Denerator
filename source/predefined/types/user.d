module predefined.types.user;

import predefined.types.basictypes;

import model.world;
import model.type;
import model.classes;

Class userClass(Con...)(TheWorld world, Con cons) {
	Class user = world.newClass("User", cons);

	user.containerType["D"] = "struct";
	user.containerType["Angular"] = "class";
	user.containerType["MySQL"] = "Table";

	MemberVariable userId = user.newMemberVariable("id");
	userId.type = world.getType!Type("ULong");
	assert(userId.type);
	userId.addLangSpecificAttribute("MySQL", "PRIMARY KEY");
	userId.addLangSpecificAttribute("MySQL", "AUTO INCREMENT");
	userId.protection["D"] = "const";
	userId.protection["Typescript"] = "const";
	userId.protection["Angular"] = "const";

	MemberVariable firstname = user.newMemberVariable("firstname");
	firstname.type = world.getType!Type("String");
	assert(firstname.type);

	MemberVariable middlename = user.newMemberVariable("middlename");
	middlename.type = world.getType!Type("String");
	assert(middlename.type);

	MemberVariable lastname = user.newMemberVariable("lastname");
	lastname.type = world.getType!Type("String");
	assert(lastname.type);

	MemberVariable passwordHash = user.newMemberVariable("password");
	passwordHash.type = world.getType!Type("PasswordHash");
	assert(passwordHash.type);

	return user;
}
