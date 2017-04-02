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
					getAngularPipe(super.world)).empty) 
		{
			return toLower(cls.name) ~ ".pipe.ts";
		} else {
			return toLower(cls.name) ~ ".ts";
		}
		assert(false);
	}

	override void generateClass(LTW ltw, const(Class) cls) {
		if(cls.doNotGenerate == DoNotGenerate.yes) {
			return;
		}

		this.generateImports(ltw, cls);
		if(!entityRangeFromTo!(Dependency)(
					&this.world.connections, cls,
					getAngularService(super.world)).empty) 
		{
			this.generateNgService(ltw, cls);
		} else if(!entityRangeFromTo!(Dependency)(
					&this.world.connections, cls,
					getAngularComponent(super.world)).empty) 
		{
			this.generateNgComponent(ltw, cls);
		} else if(!entityRangeFromTo!(Dependency)(
					&this.world.connections, cls,
					getAngularEnum(super.world)).empty) 
		{
			this.generateNgEnum(ltw, cls);
		}

		this.generateMembers(ltw, cls);
		format(ltw, 0, "}\n");
	}

	void generateImports(LTW ltw, const(Class) cls) {
		import model.connections : Dependency;
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
			format(ltw, 0, "import { Component, OnInit } from '@angular/core';" ~
				"\n"
			);
		}
	}

	override void generateAggregation(LTW ltw, in Aggregation agg) {
	}

	void generateMembers(LTW ltw, const(Class) cls) {
	}

	void generateNgEnum(LTW ltw, const(Class) cls) {
		format(ltw, 0, "export Enum %s {\n", cls.name);
	}

	void generateNgClass(LTW ltw, const(Class) cls) {
		format(ltw, 0, "export class %s {\n", cls.name);
	}

	void generateNgService(LTW ltw, const(Class) cls) {
		format(ltw, 0, 
			"@Injectable()\n" ~
		    "export class %sService {\n" ~
		    "\tconstructor() { }\n"
			, cls.name
		);
	}

	void generateNgComponent(LTW ltw, const(Class) cls) {
		format(ltw, 0,
			"@Component({\n" ~
			"\tselector: 'app-%s',\n" ~
			"\ttemplateUrl: './%1$s.component.html',\n" ~
			"\tstyleUrls: ['./%1$s.component.css']\n" ~
			"})\n" ~
			"export class %1$sComponent implements OnInit {\n"
			, cls.name
		);

		format(ltw, 1, "constructor() {}\n");
		format(ltw, 1, "abstract ngOnInit();\n");
	}
}
