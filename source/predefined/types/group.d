module predefined.types.group;

import predefined.types.basictypes;

import model.world;
import model.type;
import model.classes;
import model.connections;

Class groupClass(Con...)(TheWorld world, Con cons) {
	Class group = world.getOrNewClass("Group", cons);

	group.containerType["D"] = "struct";
	group.containerType["Angular"] = "class";
	group.containerType["MySQL"] = "Table";

	MemberVariable userId = group.getOrNew!MemberVariable("id");
	userId.type = world.newType("const ULong");
	assert(userId.type);
	userId.addLangSpecificAttribute("MySQL", "PRIMARY KEY");
	userId.addLangSpecificAttribute("MySQL", "AUTO INCREMENT");
	userId.addLangSpecificAttribute("D", "const");
	userId.addLangSpecificAttribute("Typescript", "const");

	MemberVariable groupname = group.getOrNew!MemberVariable("name");
	groupname.type = world.newType("String");
	assert(groupname.type);

	auto user = world.getOrNewClass("User");
	Aggregation groupAdmin = world.getOrNew!Aggregation("GroupAdmin",
		user, group
	);

	Aggregation groupMember = world.getOrNew!Aggregation("GroupMember",
		user, group
	);

	return group;
}
