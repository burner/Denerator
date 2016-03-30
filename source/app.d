import std.stdio;
import pegged.grammar;

mixin(grammar(`
UML:
	Start < Comment / SequenceStart

	SequenceStart < (Sequence / SequenceType)*
	Sequence < Participent SequenceArrow Participent Note*
	Participent <- (identifier / String)+
	Note < ":" NoteText+
	NoteText <- Text+
	SequenceArrow < 
		"o<-" / "->o" / "o<->" / "<->o"
		/ "x<-" / "->x" / "<<-" / "->>"
		/ "<-" / "<--" / "->" / "-->" 
		/ "/-" / "\\-" / "-/" / "-\\"
		/ "o//-" / "o\\\\-" / "-//o" / "-\\\\o"
		/ "o/-" / "o\\-" / "-/o" / "-\\o"
		/ "//-" / "\\\\-" / "-//" / "-\\\\"

	SequenceType < 
		"actor" Participent
		/ "boundary" Participent
		/ "control" Participent
		/ "entity" Participent
		/ "database" Participent

	Comment <- "'" Text+
	Text <- identifier / blank

	String < '"' ([a-zA-Z0-9])* '"'
`));

void main()
{
	//writeln(UML("Alice -> Bob"));
	//writeln(UML("actor Foo\nFoo o//- Bar"));
	writeln(UML("Alice -> \"Bob[10]\""));
	//writeln(UML("' Some Comments"));
	//writeln(UML("Alice ->o Joe : Alice calls Joe\nmultiple times\n:and writes him letters"));
}
