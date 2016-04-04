module language.ast;

import language.visitor;

class Ast {
	void visit(Visitor vis) {
		vis.visit(this);
	}
}

class Start : Ast {
	Comment[] comment;
	ClassStart[] classStart;
}

class Note : Ast {
	NoteText[] noteText;
}

class NoteText : Ast {
	Text[] text;
}

class ClassStart : Ast {
	Context context;
	Class cls;
	RealNote realNote;
}

class Class : Ast {
	ClassPrefix classPrefix;
	StereoTypes stereoTypes;
	ClassBody classBody;
}

class ClassPrefix : Ast {
	string classType;
	string className;
}

class ClassBody : Ast {
	ClassDecls[] classDecls;
}

class ClassDecls : Ast {
	Method method;
	Member member;
	Seperator seperator;
}

class GenericConstraint : Ast {
	string str;
}

class ArrowSign : Ast {
	char sign;
}

class Context {
	ClassPrefix classPrefixLeft;
	Cardinality cardinalityLeft;
	Arrow arrow;
	Cardinality cardinalityRight;
	ClassPrefix classPrefixRight;
	ContextNote contextNote;
}

class ContextNote {
	Note note;
	ArrowSign arrowSign;
}

class Cardinality : Ast {
	string str;
}

class Arrow : Ast {
	Left left;
	Right right;
	Line line;
}

class Left : Ast {
	ExtensionLeft extensionLeft;
	CompositionLeft compositionLeft;
	AggregationLeft aggregationLeft;
}

class Right : Ast {
	ExtensionRight extensionRight;
	CompositionRight compositionRight;
	AggregationRight aggregationRight;
}

class ExtensionLeft : Ast { }
class ExtensionRight : Ast { }
class CompositionLeft : Ast { }
class CompositionRight : Ast { }
class AggregationLeft : Ast { }
class AggregationRight : Ast { }
class Dotted : Ast { }
class Dashed : Ast { }

class Line : Ast {
	Dotted dotted;
	Dashed dashed;
}

class Method : Ast {
	AbstractStatic abstractStatic;
	Protection protection;
	Type type;
	string methodName;
	ParameterList parameterList;
	Note note;
}

class Protection : Ast {
	char protection;
}

class Type : Ast {
	Modifier modifier;
	Type type;
	string identifier;
}

class Modifier : Ast {
	string modifier;
}

class ParameterList : Ast {
	Parameter parameter;
	ParameterList parameterList;
}

class Parameter : Ast {
	string identifier;
	Type type;
}

class Member : Ast {
	Parameter parameter;
	Note[] note;
}

class AbstractStatic : Ast {
	string abstractStatic;
}

class Seperator : Ast {
	string type;
	NoteText noteText;
	Note[] note;
}

class StereoTypes : Ast {
	StereoType[] stereoType;
}

class StereoType : Ast {
	string stereoType;
}

class RealNote : Ast {
	RealNoteAssign realNoteAssign;
	RealNoteStandalone realNoteStandalone;
}

class RealNoteAssign : Ast {
	RealNotePos realNotePos;
	string identifier;
	Note note;
}

class RealNoteStandalone : Ast {
	string str;
	RealNoteName realNoteName;
}

class RealNotePos : Ast {
	string realNotePos;
}

class RealNoteName : Ast {
	string identifier;
}

class Comment : Ast {
	Text[] text;
}

class Text : Ast {
	string identifier;
	string blank;
}

alias String = string;
