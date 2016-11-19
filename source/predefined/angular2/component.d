module predefined.angular.component;

import model.world;
import model.container;
import model.classes;

Class angularComponent(TheWorld world, Container cons) {
	Class ngCmp = world.getOrNewClass("AngularComponent", cons);

	return ngCmp;
}

Class angularService(TheWorld world, Container cons) {
	Class ngCmp = world.getOrNewClass("AngularService", cons);

	return ngCmp;
}
