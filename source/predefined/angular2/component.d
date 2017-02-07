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

Class angularDirective(C)(TheWorld world, C cons) {
	Class ngCmp = world.newClass("AngularDirective", cons);

	return ngCmp;
}

Class angularPipe(C)(TheWorld world, C cons) {
	Class ngCmp = world.newClass("AngularPipe", cons);
	ngCmp.doNotGenerate = DoNotGenerate.yes;

	return ngCmp;
}

Class angularModule(C)(TheWorld world, C cons) {
	Class ngCmp = world.newClass("AngularModule", cons);
	ngCmp.doNotGenerate = DoNotGenerate.yes;

	return ngCmp;
}

const(Class) angularComponent(const(TheWorld) world) {
	return world.getType!Class("AngularComponent");
}

const(Class) angularService(const(TheWorld) world) {
	return world.getType!Class("AngularService");
}

const(Class) angularDirective(const(TheWorld) world) {
	return world.getType!Class("AngularDirective");
}

const(Class) angularPipe(const(TheWorld) world) {
	return world.getType!Class("AngularPipe");
}

const(Class) angularModule(const(TheWorld) world) {
	return world.getType!Class("AngularModule");
}

Class genAngularService(C...)(string name, TheWorld world, C cons) {
	return genImpl(name, world, 
		 angularService(world, cons), "AngularServiceDependency", cons
	);
}

Class genAngularComponent(C...)(string name, TheWorld world, C cons) {
	return genImpl(name, world, 
		 angularComponent(world, cons), "AngularComponentDependency", cons
	);
}

Class genAngularDirective(C...)(string name, TheWorld world, C cons) {
	return genImpl(name, world, 
		 angularDirective(world, cons), "AngularDirectiveDependency", cons
	);
}

Class genAngularPipe(C...)(string name, TheWorld world, C cons) {
	return genImpl(name, world, 
		 angularPipe(world, cons), "AngularPipeDependency", cons
	);
}

Class genAngularModule(C...)(string name, TheWorld world, C cons) {
	return genImpl(name, world, 
		 angularModule(world, cons), "AngularModuleDependency", cons
	);
}

Class genImpl(C...)(string name, TheWorld world, Class to,
	   	string connectionName, C cons) 
{
	import model.connections : Dependency;
	Class ret = world.newClass(name, cons);
	ret.doNotGenerate = DoNotGenerate.yes;
	world.newDependency(name ~ connectionName, ret, to);
	return ret;
}
