module predefined.ctrl.userctrl;

import model.world;
import model.classes;
import model.type;
import model.connections;

struct ClassAndInterface {
	Class cls;
	Class inter;
}

ClassAndInterface userCtrl(Container)(TheWorld world, Container cons) {
	Class userInter = world.newClass("IUserCtrl", cons);
	Class user = world.getClass("User");

	userInter.containerType["D"] = "interface";

	MemberFunction createUser = userInter.getOrNew!MemberFunction("createUser");
	createUser.returnType = user;
	createUser.addParameter("userData", user);

	MemberFunction delUser = userInter.getOrNew!MemberFunction("deleteUser");
	delUser.returnType = world.getType!Type("Void");
	delUser.addParameter("userData", user);

	MemberFunction getUser = userInter.getOrNew!MemberFunction("getUser");
	getUser.returnType = user;
	getUser.addParameter("userData", user);

	MemberFunction modifyUser = userInter.getOrNew!MemberFunction("modifyUser");
	modifyUser.returnType = world.getType!Type("Void");
	modifyUser.addParameter("moddedUser", user);

	Class userAC = world.newClass("AUserCtrl", cons);
	userAC.containerType["D"] = "abstract class";

	world.getOrNew!Realization("IUserCtrl_AUserCtrl", userAC, userInter);

	ClassAndInterface ret;
	ret.inter = userInter;
	ret.cls = userAC;

	return ret;
}
