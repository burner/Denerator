module predefined.ctrl.userctrl;

import model.world;
import model.classes;

Class userCtrl(Container)(TheWorld world, Container cons) {
	Class user = world.getOrNewClass("UserCtrl", cons);

	user.containerType["D"] = "class";

	MemberFunction createUser = user.getOrNew!MemberFunction("createUser");
	createUser.returnType = world.getOrNewClass("User");
	createUser.addParameter("userData", world.getOrNewClass("User"));

	MemberFunction delUser = user.getOrNew!MemberFunction("deleteUser");
	delUser.returnType = world.getOrNewClass("void");
	delUser.addParameter("userData", world.getOrNewClass("User"));

	MemberFunction getUser = user.getOrNew!MemberFunction("getUser");
	getUser.returnType = world.getOrNewClass("User");
	getUser.addParameter("userData", world.getOrNewClass("User"));


	MemberFunction modifyUser = user.getOrNew!MemberFunction("modifyUser");
	modifyUser.returnType = world.getOrNewClass("void");
	modifyUser.addParameter("moddedUser", world.getOrNewClass("User"));

	return user;
}
