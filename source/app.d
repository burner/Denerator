import std.stdio;

import language.classes;
import language.peggedtoast;
import language.postprocessing;

void main()
{
	//writeln(UML("Alice -> Bob"));
	//writeln(UML("actor Foo\nFoo o//- Bar"));
	//writeln(UML("Alice -> \"Bob[10]\""));
	//writeln(UML("' Some Comments"));
	//writeln(UML("Alice ->o Joe : Alice calls Joe\nmultiple times\n:and writes him letters"));
	//writeln(UML("class Foo"));
	//writeln(UML("class Bar { void fun(a : const(int)) args: int}"));
	//writeln(UML(`class Bar { {abstract} void fun(a : const(int)) .. args: int
	//			== encrypted == }`));
	//writeln(UML("class A <|-- class B"));
	//writeln(UML("class A --|> class B : does something <"));

	//writeln(UML("class Foo << Frontend,Backend,DB >>"));
	//writeln(UML("note top of Foo : Some note"));
	//writeln(UML("note \"This is a note\" as N1"));
	//writeln(UML("interface Foo"));
	//writeln(UML("interface Foo { args : int : helllo } "));
	string s = 
`class modA.Foo<is!(Class && args)> << SQL, Frontend, Backend >> { 
	args : int /* some note */
	int fun() /* An awesome function
				 Another note about fun */
}`;
	//writeln(UML(s));
	auto cls = peggedToUML(UML(s));
	auto oFile = File("graphvizTest.dot", "w");
	auto outFile = oFile.lockingTextWriter();
	auto gen = new GraphVizClassDiagramm!(typeof(outFile))(cls, outFile);
	gen.generate();
	/*
	writeln(cls.toString());

	s = "Foo <|.. Bar : > Hello <";
	auto context = peggedToUML(UML(s));
	//writeln(UML(s));
	writeln(context.toString());

	s = "note left of Foo : Some Note";
	auto note = peggedToUML(UML(s));
	writeln(note.toString());

	s = "note \"Some string note\" as Args";
	note = peggedToUML(UML(s));
	writeln(note.toString());
	*/
}
