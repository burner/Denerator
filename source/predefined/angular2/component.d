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
	ngCmp.doNotGenerate = DoNotGenerate.yes;

	return ngCmp;
}

Class angularPipe(C)(TheWorld world, C cons) {
	Class ngCmp = world.newClass("AngularPipe", cons);
	ngCmp.doNotGenerate = DoNotGenerate.yes;

	return ngCmp;
}

Class angularClass(C)(TheWorld world, C cons) {
	Class ngCmp = world.newClass("AngularClass", cons);
	ngCmp.doNotGenerate = DoNotGenerate.yes;

	return ngCmp;
}

Class angularInterface(C)(TheWorld world, C cons) {
	Class ngCmp = world.newClass("AngularInterface", cons);
	ngCmp.doNotGenerate = DoNotGenerate.yes;

	return ngCmp;
}

Class angularEnum(C)(TheWorld world, C cons) {
	Class ngCmp = world.newClass("AngularEnum", cons);
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

const(Class) angularClass(const(TheWorld) world) {
	return world.getType!Class("AngularClass");
}

const(Class) angularInterface(const(TheWorld) world) {
	return world.getType!Class("AngularInterface");
}

const(Class) angularEnum(const(TheWorld) world) {
	return world.getType!Class("AngularEnum");
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

Class genAngularDirective(C)(string name, TheWorld world, C cons) {
	return genImpl(name, world, cons, 
		 angularDirective(world, cons), "AngularDirectiveDependency"
	);
}

Class genAngularPipe(C)(string name, TheWorld world, C cons) {
	return genImpl(name, world, cons, 
		 angularPipe(world, cons), "AngularPipeDependency"
	);
}

Class genAngularClass(C)(string name, TheWorld world, C cons) {
	return genImpl(name, world, cons, 
		 angularClass(world, cons), "AngularClassDependency"
	);
}

Class genAngularInterface(C)(string name, TheWorld world, C cons) {
	return genImpl(name, world, cons, 
		 angularInterface(world, cons), "AngularInterfaceDependency"
	);
}

Class genAngularEnum(C)(string name, TheWorld world, C cons) {
	return genImpl(name, world, cons, 
		 angularEnum(world, cons), "AngularEnumDependency"
	);
}

Class genImpl(C)(string name, TheWorld world, C cons, Class to,
	   	string connectionName) 
{
	import model.connections : Dependency;
	Class ret = world.newClass(name, cons);
	world.newDependency(name ~ connectionName, ret, to);
	return ret;
}
