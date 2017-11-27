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
    //The base path under which all files shall be placed
    immutable(string) outputDirBasePath;
    //Working path modified when generating output
    Rebindable!(const(Container)) currentContainer;

    this(in TheWorld world, in string outputDir) {
    		super(world);
    		this.outputDirBasePath = outputDir;
    		deleteFolder(this.outputDirBasePath);
    		//enforce ensures that a given value is true -> in this case that a folder is created, otherwise throws an exception
    		enforce(Generator.createFolder(outputDir));
    }

    ~this(){}

    override void generate(){}

    override void generate(string technology){}

    void generate(in Container container){
        info("Generating contents of container ", container.name);
        assert(container.technology is "Java");
        this.currentContainer = container;
        immutable(string) outputDir = getOutputDir(container);
        enforce(Generator.createFolder(outputDir));

        //generate classes
        foreach(value; container.classes){
            const(Class) clazz = value;
            generateClass!(Container)(clazz, container, outputDir);
        }

        //generate component
        foreach(value; container.components){
            const(Component) component = value;
            generateComponent(component);
        }
    }

    void generateComponent(in Component component){
        info("Generating contents of component ", component.name);
        immutable(string) outputDir = getOutputDir(component);
        enforce(Generator.createFolder(outputDir));
        //generate classes
        foreach(value; component.classes){
            const(Class) clazz = value;
            generateClass!(Component)(clazz, component, outputDir);
        }

        //generate subcomponents
        foreach(value; component.subComponents){
            const(Component) component = value;
            generateComponent(component);
        }
    }

    void generateClass(Parent)(in Class clazz, in Parent parent, in string outputDir) const{
        info("Generating class " , clazz.name);
        auto file = Generator.createFile([outputDir, clazz.name ~ ".java"]);
        auto lockingTextWriter = file.lockingTextWriter();
        format(lockingTextWriter, 0, "package %s;\n", getClassPackageLine(parent));
        //TODO asssert that "Java" keys exist in protection and containerType attributes
        format(lockingTextWriter, 0, "%s %s %s{", clazz.protection["Java"], clazz.containerType["Java"], clazz.name );

        //foreach(member ; MemRange!(const MemberVariable)(clazz.members)){
        //    //TODO generateMemeber
        //}
        format(lockingTextWriter, 0, "\n}");
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

    private immutable(string) getOutputDir(in Entity entity) const {
        string[] folderNames = [];
        Rebindable!(const(Entity)) entityCopy = entity;
        if(!(entityCopy is this.currentContainer)){
            while(entityCopy){
                folderNames ~= entityCopy.name;
                if(entityCopy.parent is this.currentContainer){
                    break;
                }
                entityCopy = entityCopy.parent;
            }
        }
        folderNames ~= this.outputDirBasePath;
        folderNames.reverse();
        info("Path: ",  folderNames.join("/"));
        return folderNames.join("/");
    }

    private immutable(string) getClassPackageLine(in Container parent) const{
            return "\n";
    }

    private immutable(string) getClassPackageLine(in Component parent) const {
        Rebindable!(const(Component)) parentRebindable = parent;
        string[] packagePath = [];
        while(true){
            packagePath ~= parentRebindable.name;
            if(auto componentCheckInstance = cast(Component)parentRebindable.parent){
                parentRebindable = componentCheckInstance;
            } else{
                break;
            }
        }
        packagePath.reverse;
        string packageLine = packagePath.join(".");
        packageLine ~= ";\n";
        return packageLine;
    }
}

