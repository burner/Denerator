module language.classes;

import pegged.grammar;
import language.helper;

mixin(grammar(`
UML:
	Start < Comment / ClassStart

	Note < :":" NoteText+
	NoteText <- Text+

	ClassStart < Context / Class / RealNote
	Class < ClassPrefix StereoTypes? ClassBody?
	ClassPrefix < ClassType ClassName
	ClassType < "class" / "struct" / "enum" / "interface"
	ClassName < identifier
	ClassBody < :'{' ClassDecls* :'}'
	ClassDecls < Method / Member / Seperator

	GenericConstraint < '<' String '>'

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

	Method < AbstractStatic? Protection? Type MethodName :'(' ParameterList?  :')' Note*
	Protection < '-' / '#' / '~' / '+'
	Type < Modifier ( '(' Type ')' ) / identifier
	MethodName < identifier
	Modifier < "const" / "in" / "out" / "ref" / "immutable" 
	ParameterList < Parameter (',' ParameterList)?
	Parameter < identifier :':' Type
	Member < Parameter Note*
	AbstractStatic < :"{" ("abstract" / "static") :"}"

	Seperator < ".." (NoteText :"..")? Note*
		/ "==" (NoteText :"==")? Note* 
		/ "__" (NoteText :"__")? Note*

	StereoTypes < :"<<" StereoType (:',' StereoType)* :">>"
	StereoType < "DB" / "Frontend" / "Backend"

	RealNote < :"note" (RealNoteAssign / RealNoteStandalone)
	RealNoteAssign < RealNotePos? identifier Note?
	RealNoteStandalone < String RealNoteName
	RealNotePos < "left" "of" / "right" "of" / "bottom" "of" / "top" "of"
	RealNoteName < :"as" identifier
` ~ basic));
