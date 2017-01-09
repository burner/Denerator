module predefined.types.group;

import predefined.types.basictypes;

import model.world;
import model.type;
import model.classes;
import model.connections;

Class groupClass(Con...)(TheWorld world, Con cons) {
	Class group = world.newClass("Group", cons);

	group.containerType["D"] = "struct";
	group.containerType["Angular"] = "class";
	group.containerType["MySQL"] = "Table";

	MemberVariable userId = group.newMemberVariable("id");
	userId.type = world.getType!Type("const ULong");
	assert(userId.type);
	userId.addLangSpecificAttribute("MySQL", "PRIMARY KEY");
	userId.addLangSpecificAttribute("MySQL", "AUTO INCREMENT");
	userId.addLangSpecificAttribute("D", "const");
	userId.addLangSpecificAttribute("Typescript", "const");

	MemberVariable groupname = group.newMemberVariable("name");
	groupname.type = world.getType!Type("String");
	assert(groupname.type);

	auto user = world.getClass("User");
	Aggregation groupAdmin = world.newAggregation("GroupAdmin",
		user, group
	);

	Aggregation groupMember = world.newAggregation("GroupMember",
		user, group
	);

	return group;
}
