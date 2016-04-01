import std.stdio;
import pegged.grammar;

mixin(grammar(`
UML:
	Start < Comment / ClassStart

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

	Comment <- :"'" Text+
	Text <- identifier / blank

    String <~ doublequote (!doublequote Char)* doublequote

    Char   <~ backslash ( doublequote  # '\' Escapes
                        / quote
                        / backslash
                        / [bfnrt]
                        / [0-2][0-7][0-7]
                        / [0-7][0-7]?
                        / 'x' Hex Hex
                        / 'u' Hex Hex Hex Hex
                        / 'U' Hex Hex Hex Hex Hex Hex Hex Hex
                        )
             / . # Or any char, really

    Hex     <- [0-9a-fA-F]

	ClassStart < Context / Class / RealNote
	Class < ClassPrefix StereoType? ClassBody?
	ClassPrefix < ClassType ClassName
	ClassType < "class" / "struct" / "classDB" / "structDB" / "interface"
	ClassName < identifier
	ClassBody < :'{' ClassDecls* :'}'
	ClassDecls < Method / Member / Seperator

	ArrowSign < '<' / '>'

	Context < ClassPrefix Cardinality? Arrow Cardinality? ClassPrefix ContextNote?
	ContextNote < Note? ArrowSign?
	Cardinality < String
	Arrow < Left? Line Right?
	Left < ExtensionLeft / CompositionLeft / AggregationLeft
	Right < ExtensionRight / CompositionRight / AggregationRight
	ExtensionLeft < "<|"
	ExtensionRight < "|>"
	CompositionLeft < "*"
	CompositionRight < "*"
	AggregationLeft < "o"
	AggregationRight < "o"
	Line < Dotted / Dashed
	Dotted < ".."
	Dashed < "--"

	Method < AbstractStatic? Protection? Type MethodName '(' ParameterList? ')'
	Protection < '-' / '#' / '~' / '+'
	Type < Modifier ( '(' Type ')' ) / identifier
	MethodName < identifier
	Modifier < "const" / "in" / "out" / "ref" / "immutable" 
	ParameterList < Parameter (',' ParameterList)?
	Parameter < identifier :':' Type
	Member < Parameter
	AbstractStatic < :"{" ("abstract" / "static") :"}"

	Seperator < ".." (NoteText :"..")?
		/ "==" (NoteText :"==")?
		/ "__" (NoteText :"__")?

	StereoType < :"<<" Text+ :">>"

	RealNote < :"note" (RealNoteAssign / RealNoteStandalone)
	RealNoteAssign < RealNotePos? identifier Note?
	RealNoteStandalone < String RealNoteName
	RealNotePos < "left" "of" / "right" "of" / "bottom" "of" / "top" "of"
	RealNoteName < :"as" identifier
`));

void main()
{
	//writeln(UML("Alice -> Bob"));
	//writeln(UML("actor Foo\nFoo o//- Bar"));
	//writeln(UML("Alice -> \"Bob[10]\""));
	//writeln(UML("' Some Comments"));
	//writeln(UML("Alice ->o Joe : Alice calls Joe\nmultiple times\n:and writes him letters"));
	writeln(UML("class Foo"));
	writeln(UML("class Bar { void fun(a : const(int)) args: int}"));
	writeln(UML(`class Bar { {abstract} void fun(a : const(int)) .. args: int
				== encrypted == }`));
	writeln(UML("class A <|-- class B"));
	writeln(UML("class A --|> class B : does something <"));

	writeln(UML("class Foo << Some StereoType >>"));
	writeln(UML("note top of Foo : Some note"));
	writeln(UML("note \"This is a note\" as N1"));
	writeln(UML("interface Foo"));
}
