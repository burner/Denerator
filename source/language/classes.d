module language.classes;

import pegged.grammar;
import language.helper;

mixin(grammar(`
UML:
	Start < (Comment / Context / ClassStart / RealNote)+

	Note < :"/*" NoteText+ :"*/"
	NoteText <- Text+

	ClassStart < Class
	Class < ClassPrefix ((StereoTypes? ClassBody?) / ";")
	ClassPrefix < ClassType ClassName ClassConstraint?
	ClassType < "class" / "struct" / "enum" / "interface"
	ClassName <~ (identifier / '.')+
	ClassBody < :'{' ClassDecls* :'}'
	ClassDecls < Method / Member / Seperator
	ClassConstraint < :"<" Text+ :">"

	GenericConstraint < '<' String '>'

	ArrowSignLeft < '<' / '>'
	ArrowSignRight < '<' / '>'

	Context < LeftIdentifier CardinalityLeft? Arrow CardinalityRight?  RightIdentifier ContextNote? :';'
	ContextNote < :":" ArrowSignLeft? NoteText? ArrowSignRight?
	CardinalityLeft < Cardinality
	CardinalityRight < Cardinality
	Cardinality < String
	Arrow < Left? Line Right?
	Left < ExtensionLeft / CompositionLeft / AggregationLeft
	Right < ExtensionRight / CompositionRight / AggregationRight
	LeftIdentifier <~ (identifier / '.')+
	RightIdentifier <~ (identifier / '.')+
	ExtensionLeft < ^"e"
	ExtensionRight < ^"e"
	CompositionLeft < ^"c"
	CompositionRight < ^"c"
	AggregationLeft < ^"a"
	AggregationRight < ^"a"
	Line < Dotted / Dashed
	Dotted < ".."
	Dashed < "--"

	Method < AbstractStatic? Protection? Type MethodName :'(' ParameterList?  :')' Note*
	Protection < '-' / '#' / '~' / '+'
	Type < Modifier ( '(' Type ')' ) / ^identifier
	MethodName < identifier
	Modifier < "const" / "in" / "out" / "ref" / "immutable" 
	ParameterList < Parameter (',' ParameterList)?
	Parameter < ^identifier :':' Type
	Member < Parameter Note*
	AbstractStatic < :"{" ("abstract" / "static") :"}"

	Seperator < ".." (NoteText :"..")? Note*
		/ "==" (NoteText :"==")? Note* 
		/ "__" (NoteText :"__")? Note*

	StereoTypes < :"<<" StereoType (:',' StereoType)* :">>"
	StereoType < "SQL" / "Redis" / "MongoDB" / "Frontend" / "Backend"

	RealNote < :"note" (RealNoteAssign / RealNoteStandalone)
	RealNoteAssign < RealNotePos? ^identifier Note?
	RealNoteStandalone < String RealNoteName
	RealNotePos < "left of" / "right of" / "bottom of" / "top of"
	RealNoteName < :"as" ^identifier
` ~ basic));
