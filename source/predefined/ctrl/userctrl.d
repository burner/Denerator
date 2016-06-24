module predefined.ctrl.userctrl;

import model.world;
import model.classes;

Class userCtrl(Container)(TheWorld world, Container cons) {
	Class user = world.getOrNewClass("UserCtrl", cons);

	user.containerType["D"] = "class";

	MemberFunction createUser = user.getOrNew!MemberFunction("createUser");
	createUser.returnType = world.getOrNewClass("User");

	createUser.addParameter("userData", world.getOrNewClass("User"));

	return user;
}
