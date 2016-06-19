module predefined.ctrl.userctrl;

Class userCtrl(Con...)(TheWorld world, Con cons) {
	Class user = getOrNewClass("UserCtrl", cons);

	user.containerType["D"] = "class";

	MemberFunction createUser = user.getOrNew!MemberFunction("createUser");

}
