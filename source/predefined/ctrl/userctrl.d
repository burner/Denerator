module predefined.ctrl.userctrl;

import model.world;
import model.classes;
import model.connections;

struct ClassAndInterface {
	Class cls;
	Class inter;
}

ClassAndInterface userCtrl(Container)(TheWorld world, Container cons) {
	Class userInter = world.getOrNewClass("IUserCtrl", cons);

	userInter.containerType["D"] = "interface";

	MemberFunction createUser = userInter.getOrNew!MemberFunction("createUser");
	createUser.returnType = world.getOrNewClass("User");
	createUser.addParameter("userData", world.getOrNewClass("User"));

	MemberFunction delUser = userInter.getOrNew!MemberFunction("deleteUser");
	delUser.returnType = world.getOrNewClass("void");
	delUser.addParameter("userData", world.getOrNewClass("User"));

	MemberFunction getUser = userInter.getOrNew!MemberFunction("getUser");
	getUser.returnType = world.getOrNewClass("User");
	getUser.addParameter("userData", world.getOrNewClass("User"));

	MemberFunction modifyUser = userInter.getOrNew!MemberFunction("modifyUser");
	modifyUser.returnType = world.getOrNewClass("void");
	modifyUser.addParameter("moddedUser", world.getOrNewClass("User"));


	Class userAC = world.getOrNewClass("AUserCtrl", cons);
	userAC.containerType["D"] = "abstract class";

	world.getOrNew!Realization("IUserCtrl_AUserCtrl", userAC, userInter);

	ClassAndInterface ret;
	ret.inter = userInter;
	ret.cls = userAC;

	return ret;
}
