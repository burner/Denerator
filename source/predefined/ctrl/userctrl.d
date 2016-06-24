module predefined.ctrl.userctrl;

import model.world;
import model.classes;

Class userCtrl(Container)(TheWorld world, Container cons) {
	Class user = world.getOrNewClass("UserCtrl", cons);

	user.containerType["D"] = "class";

	MemberFunction createUser = user.getOrNew!MemberFunction("createUser");
	createUser.returnType = world.getOrNewClass("User");

	createUser.addParameter("userData", world.getOrNewClass("User"));

	MemberVariable userId = user.getOrNew!MemberVariable("id");
	userId.type = world.getOrNewType("const ULong");
	assert(userId.type);
	userId.addLangSpecificAttribute("MySQL", "PRIMARY KEY");
	userId.addLangSpecificAttribute("MySQL", "AUTO INCREMENT");
	userId.addLangSpecificAttribute("D", "const");
	userId.addLangSpecificAttribute("Typescript", "const");

	return user;
}
