module generator.java;

import std.stdio;
import generator;
import model.world;
import model.classes;
import model.entity;
import model.component;
import model.container;
import std.exception : enforce;
import std.typecons;
import std.array : join, replace, array;
import std.experimental.logger;
import std.algorithm: map, filter;
import std.algorithm.mutation : reverse;
import std.format;
import containers.dynamicarray;
import containers.hashmap;
import containers.hashset;

class Java : Generator {

    struct SimpleSet(T){
        T[] container;

        void put(T element){
            if(!this.contains(element)){
                container ~= element;
            }
        }

        void reset(){
            this.container = null;
        }

        bool contains(T toCheck){
            foreach(element; container){
                if(element == toCheck){
                    return true;
                }
            }
            return false;
        }

        T[] opSlice(int start, int end){
            return container[start..end];
        }

        @property int opDollar(){
            return container.length;
        }
    }

    //For these types no further imports are required
    string[] primitiveTypes = ["void", "Void", "byte", "Byte", "short", "Short", "int", "Integer", "long", "Long",
                "float", "Float", "double", "Double", "String", "boolean", "Boolean", "char", "Character"];
    //e.g. [class_name] = [package1.class_name, packag2.class_name]
    string[][string] newTypeMap;
    //e.g. [path_to_class_file] = [requested_class_name1, ...]
    string[][string] requestedTypeMap;
    //for containing the requested dependencies of one class
    SimpleSet!(string) requestedTypes;
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

        foreach(path, requestedTypes; this.requestedTypeMap){
            if(!(requestedTypes.length == 0)){
                //copy file content because the package declaration needs to be prepended
                File readFile = File(path, "r");
                string packageLine = readFile.readln();
                string fileContent;
                while (!readFile.eof()) {
                    fileContent ~= readFile.readln();
                }
                readFile.close();
                File writeFile = File(path, "w");
                writeFile.write(packageLine);
                writeFile.write(getImportLines(requestedTypes));
                writeFile.write(fileContent);
                writeFile.close();

            }
        }
    }

    void generateComponent(in Component component){
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

    void generateClass(Parent)(in Class clazz, in Parent parent, in string outputDir) {
        validateClass(clazz);

        //for imports
        if(clazz.name in this.newTypeMap){
            this.newTypeMap[clazz.name] ~= [getPackagePath(parent) ~ "." ~ clazz.name];
        } else{
            this.newTypeMap[clazz.name] = [getPackagePath(parent) ~ "." ~ clazz.name];
        }
        if(!clazz.doNotGenerate){
        //generating file to write to
            immutable(string) path = [outputDir, clazz.name ~ ".java"].join("/");
            auto file = Generator.createFile(path);
            auto lockingTextWriter = file.lockingTextWriter();

            //generating package line
            const(string) classPackageLine = getClassPackageLine(parent);
            generator.format(lockingTextWriter, 0, getClassPackageLine(parent));

            string protection = "";
            if(TECHNOLOGY_JAVA in clazz.protection){
                protection = clazz.protection[TECHNOLOGY_JAVA];
            }
            immutable string line = [protection, clazz.containerType[TECHNOLOGY_JAVA], clazz.name, getExtendsExpression(clazz), getImplementsExpression(clazz)]
                    .filter!(str => str.length > 0)
                    .join(" ");
            generator.format(lockingTextWriter, 0, "%s{ \n", line);

            generateMembers(lockingTextWriter, clazz.members);

            generator.format(lockingTextWriter, 0, "\n}");

            //mark types needed for imports
            this.requestedTypeMap[path] = this.requestedTypes[0..$];
            this.requestedTypes.reset();
        }
    }

    string getImportLines(in string[] requestedTypes){
        string importLines;
        foreach(requestedType; requestedTypes){
            if(requestedType in this.newTypeMap){
                string[] packages = this.newTypeMap[requestedType];
                if(packages.length > 1){
                    error(std.format.format("More than one declaration of class %s can be found. The import has to be executed manually.", requestedType));
                    break;
                }
                importLines ~= "import " ~ packages[0] ~ ";\n";
            }
            else{
                error(std.format.format("Requested type %s could not be found.", requestedType));
            }
        }
        return importLines;
     }

    string getImplementsExpression(in Class clazz){
        import model.connections : Realization;
        string implementsExpression = "";
        foreach(entity; this.world.connections){
            if(auto realization = cast(Realization) entity){
                if(realization.from == clazz){
                    implementsExpression = "implements " ~ realization.to.name;
                    requestedTypes.put(realization.to.name);
                }
            }
        }
        return implementsExpression;
    }

    string getExtendsExpression(in Class clazz){
        import model.connections : Generalization;
        string extendsExpression = "";
        foreach(entity; this.world.connections){
            if(auto generalization = cast(Generalization) entity){
                extendsExpression = "extends " ~ generalization.to.name;
                requestedTypes.put(generalization.to.name);
            }
        }
        return extendsExpression;
    }

    void generateMembers(Out)(Out lockingTextWriter, in Member[] members) {
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
        foreach(memberVariable; memberVariables){
            generateMemberVariable(lockingTextWriter, memberVariable);
        }
        foreach(memberFunction; memberFunctions){
            generateMemberFunction(lockingTextWriter, memberFunction);
        }
    }

    void generateMemberVariable(Out)(Out lockingTextWriter, in MemberVariable memberVariable) {
        const(string) protection = getProtection(memberVariable);
        const(string) languageSpecificAttributes = getLanguageSpecificAttributes(memberVariable);
        const(string) type = getTypeString(memberVariable.type);
        const(string) name = memberVariable.name;
        string[] container = [protection, languageSpecificAttributes, type, name];
        generator.format(lockingTextWriter, 1, "%s;\n", container.join(" "));
    }


    void generateMemberFunction(Out)(Out lockingTextWriter, in MemberFunction memberFunction){
        validateMemberFunction(memberFunction);
        const(string) protection = getProtection(memberFunction);
        const(string) languageSpecificAttributes = getLanguageSpecificAttributes(memberFunction);
        const(string) type = getTypeString(memberFunction.returnType);
        const(string) name = memberFunction.name;
        const(string) functionString = [protection, languageSpecificAttributes, type, name].filter!(str => str.length > 0).join(" ");
        const(string) parameterString = memberFunction.parameter[].map!(parameter => getMemberFunctionParameter(parameter)).join(", ");
        generator.format(lockingTextWriter, 1, "%s(%s);", functionString, parameterString);
    }

    string getMemberFunctionParameter(in MemberVariable parameter){
        validateMemberFunctionParameter(parameter);
        const(string) name = parameter.name;
        const(string) languageSpecificAttributes = getLanguageSpecificAttributes(parameter);
        const(string) type = getTypeString(parameter.type);
        return [languageSpecificAttributes, type, name].filter!(str => str.length > 0).join(" ");
    }

    string getTypeString(in Type type) {
        string typeJavaName = type.typeToLanguage[TECHNOLOGY_JAVA];
        if(!isPrimitive(type)){
            requestedTypes.put(type.name);
        }
        return typeJavaName;
    }

    bool isPrimitive(in Type type) const{
        bool isPrimitiveType = false;
            foreach(primitiveType ; primitiveTypes){
                if(type.typeToLanguage[TECHNOLOGY_JAVA] == primitiveType){
                    isPrimitiveType = true;
                }
            }
        return isPrimitiveType;
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
        return folderNames.join("/");
    }

    private immutable(string) getClassPackageLine(in Container parent) const{
            return "\n";
    }

    private immutable(string) getClassPackageLine(in Component parent) const {
        string packagePath = getPackagePath(parent);
        packagePath ~= ";\n";
        string packageLine = "package " ~ packagePath;
        return packageLine;
    }

    private immutable(string) getPackagePath(C)(in C parent) const{
        Rebindable!(const(Component)) parentRebindable = cast(Component)parent;
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
        return packagePathReverse.join(".");
    }

    private immutable(string) getLanguageSpecificAttributes(in Member member) const{
        string languageSpecificAttributes;
        if(TECHNOLOGY_JAVA in member.langSpecificAttributes){
            languageSpecificAttributes = member.langSpecificAttributes[TECHNOLOGY_JAVA].join(" ");
        }
        return languageSpecificAttributes;
    }

    private immutable(string) getProtection(in Member member) const{
        string protection;
        if(TECHNOLOGY_JAVA in member.protection){
            protection = member.protection[TECHNOLOGY_JAVA];
        }
        return protection;
    }

/* validation *********************************************************************************************************/

    void validateClass(in Class clazz) const{
        import containers.hashset;
        assert(!(clazz.containerType is null), std.format.format("The container type for class %s was not defined", clazz.name));
        auto validJavaContainers =  HashSet!(string)(2);
        validJavaContainers.put("interface");
        validJavaContainers.put("class");
        assert(clazz.containerType[TECHNOLOGY_JAVA] in validJavaContainers, );
    }
    void validateMemberFunction(in MemberFunction memberFunction) const{
        if(memberFunction.name is null){
            throw new Exception("The name of a member function must be defined.");
        }
        if(memberFunction.returnType is null){
            throw new Exception(std.format.format("A type must be defined for %s but type was null"), memberFunction.name);
        }
        if(!(TECHNOLOGY_JAVA in memberFunction.returnType.typeToLanguage)){
            throw new Exception(std.format.format("The type %s cannot be translated to java because typeToLanguage has not been provided.", memberFunction.returnType.name));
        }
    }

    void validateMemberVariable(in MemberVariable memberVariable) const{
        if(!(TECHNOLOGY_JAVA in memberVariable.type.typeToLanguage)){
            throw new Exception(std.format.format("The type %s cannot be translated to java because typeToLanguage has not been provided.", memberVariable.type.name));
        }
        if(memberVariable.type is null){
            throw new Exception(std.format.format("A type must be defined for %s but type was null"), memberVariable.name);
        }
        if(!(TECHNOLOGY_JAVA in memberVariable.type.typeToLanguage)){
            throw new Exception(std.format.format("The type %s cannot be translated to java because typeToLanguage has not been provided.", memberVariable.type.name));
        }
    }

    void validateMemberFunctionParameter(in MemberVariable memberVariable) const{
            if(!(TECHNOLOGY_JAVA in memberVariable.type.typeToLanguage)){
                throw new Exception(std.format.format("The type for parameter %s was not provided", memberVariable.name));
            }
        }
}
