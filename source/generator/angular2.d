module generator.angular2;

import std.experimental.logger;

import generator.cstyle;

class Angular2 : CStyle {
	import predefined.angular.component;
	import std.uni : toLower;

	this(in TheWorld world, in string outputDir) {
		super(world, outputDir);
	}

	override void generate() {
		super.generate("Angular2");
	}

	override string genFileName(const(Class) cls) {
		if(!entityRangeFromTo!(Dependency)(
					&this.world.connections, cls,
					getAngularService(super.world)).empty) 
		{
			return toLower(cls.name) ~ ".service.ts";
		} else if(!entityRangeFromTo!(Dependency)(
					&this.world.connections, cls,
					getAngularComponent(super.world)).empty) 
		{
			return toLower(cls.name) ~ ".component.ts";
		} else if(!entityRangeFromTo!(Dependency)(
					&this.world.connections, cls,
					getAngularDirective(super.world)).empty) 
		{
			return toLower(cls.name) ~ ".directive.ts";
		} else if(!entityRangeFromTo!(Dependency)(
					&this.world.connections, cls,
					getAngularDirective(super.world)).empty) 
		{
			return toLower(cls.name) ~ ".directive.ts";
		} else {
			return toLower(cls.name) ~ ".ts";
		}
		assert(false);
	}

	override void generateClass(LTW ltw, const(Class) cls) {
		import model.connections : Dependency;
		if(cls.doNotGenerate == DoNotGenerate.yes) {
			return;
		}
		if(!entityRangeFromTo!(Dependency)(
					&this.world.connections, cls,
					getAngularService(super.world)).empty) 
		{
			format(ltw, 0, "import { Injectable } from '@angular/core';\n");
		}
		if(!entityRangeFromTo!(Dependency)(
					&this.world.connections, cls,
					getAngularComponent(super.world)).empty) 
		{
			format(ltw, 0, "import { Component } from '@angular/core';\n");
			format(ltw, 0, "Component\n");
		}
	}

	override void generateAggregation(LTW ltw, in Aggregation agg) {

	}
}
