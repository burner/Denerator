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

    private static immutable(string) TECHNOLOGY_JAVA = "Java";

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
        assert(container.technology is TECHNOLOGY_JAVA);
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

        //generating file to write to
        auto file = Generator.createFile([outputDir, clazz.name ~ ".java"]);
        auto lockingTextWriter = file.lockingTextWriter();

        //generating package line
        format(lockingTextWriter, 0, getClassPackageLine(parent));
        //TODO asssert that "Java" keys exist in protection and containerType attributes

        //generating class deklaration
        format(lockingTextWriter, 0, "%s %s %s{ \n", clazz.protection[TECHNOLOGY_JAVA], clazz.containerType[TECHNOLOGY_JAVA], clazz.name );

        //generating members
        //MemRange is an InputRange
        generateMembers(lockingTextWriter, clazz.members);

        format(lockingTextWriter, 0, "\n}");
    }

    void generateMembers(Out)(ref Out lockingTextWriter, in Member[] members) const{
        const(MemberVariable)[] memberVariables;
        const(MemberFunction)[] memberFunctions;
        //sort members
        foreach(member; members){
            if(auto memberVariable = cast(MemberVariable)member){
                memberVariables ~= memberVariable;
            } else if(auto memberFunction = cast(MemberFunction)member){
                memberFunctions ~= memberFunction;
            }
        }
        //generate member variables
        foreach(memberVariable; memberVariables){
            generateMemberVariable(lockingTextWriter, memberVariable);
        }
        foreach(memberFunction; memberFunctions){
            generateMemberFunction(lockingTextWriter, memberFunction);
        }
    }

    void generateMemberVariable(Out)(ref Out lockingTextWriter, in MemberVariable memberVariable) const{
        //TODO assert that modifiers exist
        string protection = memberVariable.protection[TECHNOLOGY_JAVA];
        const(string) languageSpecificAttributes = memberVariable.langSpecificAttributes[TECHNOLOGY_JAVA].join(" ");
        const(string) type = memberVariable.type.typeToLanguage[TECHNOLOGY_JAVA];
        const(string) name = memberVariable.name;

        format(lockingTextWriter, 1, "%s %s %s %s;\n", protection, languageSpecificAttributes, type, name);
    }

    void generateMemberFunction(Out)(ref Out lockingTextWriter, in MemberFunction memberFunction) const{
        //TODO
    }

    void generateMemberFunctionParameter(Out)(ref Out lockingTextWriter, ref MemberVariable parameter){
        //TODO
    }

    string determineProtectionString(Out, PE : ProtectedEntity)(ref Out lockingTextWriter, ref PE protectedEntitiy){
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
            return "\n;";
    }

    private immutable(string) getClassPackageLine(in Component parent) const {
        Rebindable!(const(Component)) parentRebindable = parent;
        string[] packagePathReverse = [];
        while(true){
            packagePathReverse ~= parentRebindable.name;
            if(auto componentCheckInstance = cast(Component)parentRebindable.parent){
                parentRebindable = componentCheckInstance;
            } else{
                break;
            }
        }
        packagePathReverse.reverse;
        string packagePath = packagePathReverse.join(".");
        packagePath ~= ";\n";
        string packageLine = "package " ~ packagePath;
        return packageLine;
    }
}

