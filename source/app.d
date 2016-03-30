import std.stdio;
import pegged.grammar;

mixin(grammar(`
UML:
	Sequence < Participent "->" Participent Node*
	Participent <- (identifier / [(){}\[\]] / digits)+
	Node < ":" NodeText+
	NodeText <- identifier blank
`));

void main()
{
	//writeln(UML("Alice -> Bob"));
	writeln(UML("Alice -> Bob[10]"));
	//writeln(UML("Alice -> Joe : Alice calls Joe\nmultiple times\n:and writes him letters"));
}
