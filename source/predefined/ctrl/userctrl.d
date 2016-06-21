module predefined.ctrl.userctrl;

Class userCtrl(Container)(TheWorld world, Container cons) {
	Class user = getOrNewClass("UserCtrl", cons);

	user.containerType["D"] = "class";

	MemberFunction createUser = user.getOrNew!MemberFunction("createUser");
	//createUser.returnType = world.get
}
