module predefined.angular.component;

import model.world;
import model.container;
import model.classes;
import model.entity;

import std.traits : CopyConstness;

void initAngularBaseClasses(C...)(TheWorld world, C cons) {
	angularComponent(world, cons);
	angularService(world, cons);
	angularDirective(world, cons);
	angularPipe(world, cons);
	angularModule(world, cons);
}

Class angularComponent(C...)(TheWorld world, C cons) {
	Class ngCmp = world.newClass("AngularComponent", cons);
	ngCmp.doNotGenerate = DoNotGenerate.yes;

	return ngCmp;
}

Class angularService(C...)(TheWorld world, C cons) {
	Class ngCmp = world.newClass("AngularService", cons);
	ngCmp.doNotGenerate = DoNotGenerate.yes;

	return ngCmp;
}

Class angularDirective(C...)(TheWorld world, C cons) {
	Class ngCmp = world.newClass("AngularDirective", cons);
	ngCmp.doNotGenerate = DoNotGenerate.yes;

	return ngCmp;
}

Class angularPipe(C...)(TheWorld world, C cons) {
	Class ngCmp = world.newClass("AngularPipe", cons);
	ngCmp.doNotGenerate = DoNotGenerate.yes;

	return ngCmp;
}

Class angularModule(C...)(TheWorld world, C cons) {
	Class ngCmp = world.newClass("AngularModule", cons);
	ngCmp.doNotGenerate = DoNotGenerate.yes;

	return ngCmp;
}

CopyConstness!(W,Class) getAngularComponent(W)(W world) {
	return world.getType!Class("AngularComponent");
}

CopyConstness!(W,Class) getAngularService(W)(W world) {
	return world.getType!Class("AngularService");
}

CopyConstness!(W,Class) getAngularDirective(W)(W world) {
	return world.getType!Class("AngularDirective");
}

CopyConstness!(W,Class) getAngularPipe(W)(W world) {
	return world.getType!Class("AngularPipe");
}

CopyConstness!(W,Class) getAngularModule(W)(W world) {
	return world.getType!Class("AngularModule");
}

Class genAngularService(C...)(string name, TheWorld world, C cons) {
	return genImpl(name, world, 
		 getAngularService(world), "AngularServiceDependency", cons
	);
}

Class genAngularComponent(C...)(string name, TheWorld world, C cons) {
	return genImpl(name, world, 
		 getAngularComponent(world), "AngularComponentDependency", cons
	);
}

Class genAngularDirective(C...)(string name, TheWorld world, C cons) {
	return genImpl(name, world, 
		 getAngularDirective(world), "AngularDirectiveDependency", cons
	);
}

Class genAngularPipe(C...)(string name, TheWorld world, C cons) {
	return genImpl(name, world, 
		 getAngularPipe(world), "AngularPipeDependency", cons
	);
}

Class genAngularModule(C...)(string name, TheWorld world, C cons) {
	return genImpl(name, world, 
		 getAngularModule(world), "AngularModuleDependency", cons
	);
}

Class genImpl(C...)(string name, TheWorld world, Entity to,
	   	string connectionName, C cons) 
{
	import model.connections : Dependency;
	Class ret = world.newClass(name, cons);
	world.newDependency(name ~ connectionName, ret, to);
	return ret;
}

unittest {
	auto w = new TheWorld("TestAngular");
	assert(w !is null);
	auto ss = w.newSoftwareSystem("SS");
	assert(ss !is null);
	auto c = ss.newContainer("Frontend");
	assert(c !is null);
	initAngularBaseClasses(w, c);
}
