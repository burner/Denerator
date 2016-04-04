import std.stdio;

import language.classes;

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
	writeln(UML("interface Foo { args : int : helllo } "));
}
