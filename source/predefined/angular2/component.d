module predefined.angular.component;

Class angularComponent(TheWorld world, Container cons) {
	Class ngCmp = world.getOrNewClass("AngularComponent", cons);

	return ngCmp;
}
