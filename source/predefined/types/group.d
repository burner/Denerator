module predefined.types;

import predefined.types.basictypes;

import model.world;
import model.type;
import model.classes;

Class groupClass(Con...)(TheWorld world, Con cons) {
	Class group = world.getOrNewClass("Group", cons);

	user.containerType["D"] = "struct";
	user.containerType["Angular"] = "class";
	user.containerType["MySQL"] = "Table";

	MemberVariable userId = user.getOrNew!MemberVariable("id");
	userId.type = world.getOrNewType("const ULong");
	assert(userId.type);
	userId.addLangSpecificAttribute("MySQL", "PRIMARY KEY");
	userId.addLangSpecificAttribute("MySQL", "AUTO INCREMENT");
	userId.addLangSpecificAttribute("D", "const");
	userId.addLangSpecificAttribute("Typescript", "const");

	MemberVariable groupname = user.getOrNew!MemberVariable("name");
	groupname.type = world.getOrNewType("String");
	assert(groupname.type);

	return group;
}
