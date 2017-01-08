module predefined.angular.component;

import model.world;
import model.container;
import model.classes;

Class angularComponent(C)(TheWorld world, C cons) {
	Class ngCmp = world.newClass("AngularComponent", cons);
	ngCmp.doNotGenerate = DoNotGenerate.yes;

	return ngCmp;
}
Class angularService(C)(TheWorld world, C cons) {
	Class ngCmp = world.newClass("AngularService", cons);
	ngCmp.doNotGenerate = DoNotGenerate.yes;

	return ngCmp;
}

const(Class) angularComponent(const(TheWorld) world) {
	return world.getType!Class("AngularComponent");
}

const(Class) angularService(const(TheWorld) world) {
	return world.getType!Class("AngularService");
}

Class genAngularService(C)(string name, TheWorld world, C cons) {
	return genImpl(name, world, cons, 
		 angularService(world, cons), "AngularServiceDependency"
	);
}

Class genAngularComponent(C)(string name, TheWorld world, C cons) {
	return genImpl(name, world, cons, 
		 angularComponent(world, cons), "AngularComponentDependency"
	);
}

Class genImpl(C)(string name, TheWorld world, C cons, Class to,
	   	string connectionName) 
{
	import model.connections : Dependency;
	Class ret = world.newClass(name, cons);
	world.getOrNew!Dependency(name ~ connectionName, ret, to);
	return ret;
}
