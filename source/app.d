import std.stdio;

/+import language.classes;
import language.peggedtoast;
import language.postprocessing;

void main() {
	string s = 
`class modA.Foo<is!(Class && args)> << SQL, Frontend, Backend >> { 
	args : int /* some note */
	int fun() /* An awesome function
				 Another note about fun */
}
class Bar {}
class modA.Baz {}
modA.Foo "*"(bars=foo) e.. Bar;
modA.Foo ..c modA.Baz;
Bar "some" c-- "1" modA.Baz;
`;
	writeln(UML(s));
	auto cls = peggedToUML(UML(s));
	auto oFile = File("graphvizTest.dot", "w");
	auto outFile = oFile.lockingTextWriter();
	auto gen = new GraphVizClassDiagramm!(typeof(outFile))(cls, outFile);
	gen.generate();
}+/

import model;
import std.stdio : writeln;

void main() {
	auto container = new Container("someContainer");
	writeln(Container.sizeof);
}
