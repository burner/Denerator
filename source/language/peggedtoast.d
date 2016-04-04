module language.peggedtoast;

import pegged.grammar;
import language.ast;

Start parseToUML(ParseTree p) {
	switch(p.name) {
		case "UML":
			return parseToStart(p.children[0]);
		default:
			assert(false);
	}
}

Start parseToStart(ParseTree p) {
	auto ret = new Start();
	switch(p.name) {
		case "UML.Start": {
			foreach(it; p.children) {
				if(it.name == "UML.Comment") {
					ret.comment ~= parseToComment(it);
				} else if(it.name == "UML.ClassStart") {
					ret.classStart ~= parseToClassStart(it);
				}  else {
					assert(false);
				}
			}
			break;
		}
		default:
			assert(false);
	}

	return ret;
}

Comment parseToComment(ParseTree p) {
	return new Comment();
}

ClassStart parseToClassStart(ParseTree p) {
	return new ClassStart();
}
