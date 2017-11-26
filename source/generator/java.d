module generator.java;

import std.stdio;
import generator;
import model.world;
import model.classes;
import model.entity;
import model.component;
import std.exception : enforce;
import std.typecons;
import std.array : join, replace;
import std.experimental.logger;
import std.algorithm.mutation :reverse;

class Java : Generator {
    import model.container;

    //because the putput dir changes during the progress of generation (i.e. the names of the components are appended as file names)
    //it is no longer a const variable
    //Therefore in every container or component the classes have to be generated first, before the subcomponents are generated
    string outputDir;
    Rebindable!(const(Container)) currentContainer;

    this(in TheWorld world, in string outputDir) {
    		super(world);
    		this.outputDir = outputDir;
    		deleteFolder(this.outputDir);
    		//enforce ensures that a given value is true -> in this case that a folder is created, otherwise throws an exception
    		enforce(Generator.createFolder(outputDir));
    }

~this() {
    }

    override void generate(){}

    override void generate(string technology){}

    void generate(in Container container){
        info("Generating contents of container ", container.name);
        assert(container.technology is "Java");
        this.currentContainer = container;
        enforce(Generator.createFolder(getOutputDir(container)));
        //generate classes

        foreach(value; container.classes){
            const(Class) clazz = value;
            generateClass(clazz);
        }
        //generate component
        foreach(value; container.components){
            const(Component) component = value;
            generateComponent(component);
        }
    }

    void generateComponent(in Component component){
        info("Generating contents of component", component.name);
        enforce(Generator.createFolder(getOutputDir(component)));
        //generate classes
        foreach(value; component.classes){
            const(Class) clazz = value;
            generateClass(clazz);
        }

        //generate subcomponents
        foreach(value; component.subComponents){
            const(Component) component = value;
            generateComponent(component);
        }
    }





    void generateClass(in Class clazz){
        info("Generating class " , clazz.name);
        //auto file = Generator.createFile([this.outputDir, clazz.name ~ ".java"]);
        //auto lockingTextWriter = file.lockingTextWriter();
        //format(lockingTextWriter, 0, "%s class %s{", clazz.protection["Java"], clazz.name );
        ////Initilaize a struct of class members implementing range.
        //foreach(member ; MemRange!(const MemberVariable)(clazz.members)){
        //    //TODO generateMemeber
        //}
        //format(lockingTextWriter, 0, "}");
    }

    void generateMember(Out, Mem : Member)(ref Out lockingTextWriter, bool first, ref Mem member ){
        if(is(member : MemberVariable)){
            //TODO
        } else if(is(member : MemberFunction)){
            //TODO
        } else{
            //TODO throw some exception
        }
        //TODO
    }

    void generateMemberVariable(Out)(ref Out lockingTextWriter, ref MemberVariable memberVariable){
        //TODO
    }

    void generateProtection(Out, PE : ProtectedEntity)(Out lockingTextWriter, ref PE protectedEntitiy){
        //TODO
    }

    void generateMemberFunction(Out)(ref Out lockingTextWriter, ref MemberFunction memberFunction){
        //TODO
    }

    void generateMemberFunctionParameter(Out)(ref Out lockingTextWriter, ref MemberVariable parameter){
        //TODO
    }

    private string getOutputDir(in Entity entity){
        string[] folderNames = [];
        Rebindable!(const(Entity)) entityCopy = entity;
        while(entityCopy){
            folderNames ~= entityCopy.name;
            if(entityCopy is this.currentContainer){
                break;
            }
            entityCopy = entityCopy.parent;
        }
        folderNames ~= this.outputDir;
        folderNames.reverse();
        info("Path: ",  folderNames.join("/"));
        return folderNames.join("/");
    }
}

