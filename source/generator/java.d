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
import std.regex;
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
        enforce(container.technology is TECHNOLOGY_JAVA);
        this.currentContainer = container;
        immutable(string) outputDir = getOutputDir(container);
        enforce(Generator.createFolder(outputDir));

        //generate classes in top level folder
        foreach(value; container.classes){
            const(Class) clazz = value;
            generateClass!(Container)(clazz, container, outputDir);
        }

        logf("Generating enums soon");
        foreach(value; container.enums){
            const(Enum) en = value;
            generateEnum!(Container)(en, container, outputDir);
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
                string[] expandedTypes = expandGenericTypes(requestedTypes);
                File writeFile = File(path, "w");
                writeFile.write(packageLine);
                writeFile.write(getImportLines(expandedTypes));
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

        //generate enums
        foreach(value; component.enums){
            const(Enum) en = value;
            generateEnum!(Component)(en, component, outputDir);
        }

        //generate subcomponents
        foreach(value; component.subComponents){
            const(Component) component = value;
            generateComponent(component);
        }
    }

    void generateEnum(Parent)(in Enum en, in Parent parent, in string outputDir){
        //TODO some validation.
        string packagePath = getPackagePath(parent);
        addNewType(packagePath, en.name);
        if(!en.doNotGenerate){
            //generate the files to write to
            immutable(string) path = [outputDir, en.name ~".java"].join("/");
            auto file = Generator.createFile(path);
            auto lockingTextWriter = file.lockingTextWriter();

            //generate package line
            const(string) enumPackageLine = getClassPackageLine(parent);
            generator.format(lockingTextWriter, 0, enumPackageLine);

            immutable(string) declaration = getEnumDeclaration(en);

            generator.format(lockingTextWriter, 0, "%s{ \n", declaration);

            generateEnumValues(lockingTextWriter, en);

            generateConstructor(lockingTextWriter, en.constructor);

            generateMembers(lockingTextWriter, en.members);
            generator.format(lockingTextWriter, 0, "}");
        }
    }

    void generateEnumValues(Out)(Out lockingTextWriter, in Enum en){
        //TODO cross check with constructor number of parameters
        foreach(constant; en.enumConstants){
            string valueLine = constant.name;
                int ctr = 0;
                if(valueLine.length){
                    valueLine ~= "(";
                    foreach(value; constant.values){
                        valueLine ~= value;
                    }
                    if(ctr == valueLine.length){
                        valueLine ~= ");";
                    } else{
                        valueLine ~= "),";
                    }
                }
            generator.format(lockingTextWriter, 1, valueLine);
        }
    }

    void generateConstructor(Out)(Out lockingTextWriter, in Constructor constructor){
        if(constructor !is null){
            string protection = "";
            if(TECHNOLOGY_JAVA in constructor.protection){
                protection = constructor.protection[TECHNOLOGY_JAVA];
            }
            string constr = [protection, constructor.name].join(" ");
            string[] params;
            foreach(parameter; constructor.parameters){
                params ~= [parameter.type.typeToLanguage[TECHNOLOGY_JAVA], parameter.name].join(" ");
            }
            constr ~= "(" ~ params.join(", ") ~ "){\n";
            generator.format(lockingTextWriter, 1, constr);
            string[] vars;
            foreach(parameter; constructor.parameters){
                vars ~= "this." ~ parameter.name ~ " = " ~ parameter.name ~ ";\n";
            }
            generator.format(lockingTextWriter, 2, vars.join(""));
            generator.format(lockingTextWriter, 1, "}\n");
        }
    }

    immutable(string) getEnumDeclaration(in Enum en){
        string protection = "";
        if(TECHNOLOGY_JAVA in en.protection){
            protection = en.protection[TECHNOLOGY_JAVA];
        }
        immutable string declaration = [protection, "enum", en.name].join(" ");
        return declaration;
    }

    void generateClass(Parent)(in Class clazz, in Parent parent, in string outputDir) {
        validateClass(clazz);
        //for imports
        string packagePath = getPackagePath(parent);
        addNewType(packagePath, clazz.name);
        if(!clazz.doNotGenerate){
        //generating file to write to
            immutable(string) path = [outputDir, clazz.name ~ ".java"].join("/");
            auto file = Generator.createFile(path);
            auto lockingTextWriter = file.lockingTextWriter();

            //generating package line
            const(string) classPackageLine = getClassPackageLine(parent);
            generator.format(lockingTextWriter, 0, classPackageLine);

            immutable string line = getClassDeclaration(clazz);

            generator.format(lockingTextWriter, 0, "%s{ \n", line);

            generateMembers(lockingTextWriter, clazz.members);

            foreach(innerClass; clazz.classes){
                generateInnerClass(lockingTextWriter, innerClass, clazz, parent);
            }

            generator.format(lockingTextWriter, 0, "\n}");

            //mark types needed for imports
            this.requestedTypeMap[path] = this.requestedTypes[0..$];
            this.requestedTypes.reset();
        }
    }

    /**
     * Adds a new entry to this.newTypeMap. The key will be the name of the new type.
     * The value will be an array of all the package paths that a type with this name is contained in.
     * @param The path to the new type e.g. com.package.name
     * @param The name of the newly created type.
     */
    void addNewType(in string packagePath, in string typeName){
        if(typeName in this.newTypeMap){
            this.newTypeMap[typeName] ~= [packagePath ~ "." ~ typeName];
        } else{
            this.newTypeMap[typeName] = [packagePath ~ "." ~ typeName];
        }
    }

    void generateInnerClass(Out, C)(Out lockingTextWriter, in Class innerClass, in Class parent, C container) {
        string packagePath = getPackagePath(container);
        string innerClassName = parent.name ~ "." ~ innerClass.name;
        if(innerClassName in this.newTypeMap){
            this.newTypeMap[innerClassName] ~= [packagePath ~ "." ~ innerClassName];
        } else{
            this.newTypeMap[innerClassName] = [packagePath ~ "." ~ innerClassName];
        }
        immutable string declaration = getClassDeclaration(innerClass);
        generator.format(lockingTextWriter, 0, "%s{ \n", declaration);

        generateMembers(lockingTextWriter, innerClass.members);

        generator.format(lockingTextWriter, 0, "\n}");
    }

    immutable(string) getClassDeclaration(in Class clazz){
        string protection = "";
        if(TECHNOLOGY_JAVA in clazz.protection){
            protection = clazz.protection[TECHNOLOGY_JAVA];
        }
        immutable string declaration = [protection,
                                    getLanguageSpecificAttributes(clazz),
                                     clazz.containerType[TECHNOLOGY_JAVA],
                                      clazz.name,
                                       getExtendsExpression(clazz),
                                        getImplementsExpression(clazz)]
                                    .filter!(str => str.length > 0)
                                    .join(" ");
        return declaration;
    }

    string getImportLines(in string[] requestedTypes){
        import std.algorithm;
        string[] importLines;
        foreach(requestedType; requestedTypes){
            if(requestedType in this.newTypeMap){
                string[] packages = this.newTypeMap[requestedType];
                if(packages.length > 1){
                    error(std.format.format("More than one declaration of class %s can be found. The import has to be executed manually.", requestedType));
                    break;
                }
                string importLine = "import " ~ packages[0] ~ ";\n";
                if(!canFind(importLines, importLine)){
                    importLines ~= importLine;
                }
            }
            else{
                error(std.format.format("Requested type %s could not be found.", requestedType));
            }
        }
        return importLines.join("");
    }

    /**
     * If a type within notExpandedTypes is of java generic type, it will get expanded.
     * E.g. expandGenericTypes(["List<String>"]) will return ["List", "String"]
     * If the provided types are not of java generic type, they will just be returned.
     * @param notExpandedTypes The types to expand.
     * @return Expanded types.
     */
    string[] expandGenericTypes(in string[] notExpandedTypes){
        import std.algorithm;
        string[] types = notExpandedTypes.dup;
        auto pattern = regex("<|>|, *");
        while(containsGeneric(types)){
            foreach(type; types){
                if(isGeneric(type)){
                    auto genericTypes = type.split(pattern);
                    types ~= genericTypes[0..$];
                    types = types.remove!( t => t == type);
                    types = types.remove!( t => t == "");
                }
            }
        }

        return types;
    }

    bool containsGeneric(in string[] types){
        foreach(type ; types){
            if(isGeneric(type)){
                return true;
            }
        }
        return false;
    }

    bool isGeneric(in string type) const{
        auto pattern = regex("([A-Z]|[a-z])*<.*>");
        if(type.matchAll(pattern).empty){
            return false;
        } else{
            return true;
        }
    }

    string getImplementsExpression(in Class clazz){
        import model.connections : Realization;
        string[] implementedEntities;
        foreach(entity; this.world.connections){
            if(auto realization = cast(Realization) entity){
                if(realization.from == clazz){
                    implementedEntities ~= realization.to.name;
                    this.requestedTypes.put(realization.to.name);
                }
            }
        }
        return implementedEntities.join(", ") != "" ? "implements " ~ implementedEntities.join(", ") : "";
    }

    string getExtendsExpression(in Class clazz){
        import model.connections : Generalization;
        string extendsExpression = "";
        foreach(entity; this.world.connections){
            if(auto generalization = cast(Generalization) entity){
                extendsExpression = "extends " ~ generalization.to.name;
                this.requestedTypes.put(generalization.to.name);
            }
        }
        return extendsExpression;
    }

    string getLanguageSpecificAttributes(in Class clazz){
        if(clazz.languageSpecificAttributes){
            return clazz.languageSpecificAttributes[TECHNOLOGY_JAVA].join(" ");
        } else{
            return "";
        }
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
        generator.format(lockingTextWriter, 1, "%s(%s);\n", functionString, parameterString);
    }

    string getMemberFunctionParameter(in MemberVariable parameter){
        validateMemberFunctionParameter(parameter);
        const(string) name = parameter.name;
        const(string) languageSpecificAttributes = getLanguageSpecificAttributes(parameter);
        const(string) type = getTypeString(parameter.type);
        return [languageSpecificAttributes, type, name].filter!(str => str.length > 0).join(" ");
    }

    string getTypeString(in Type type) {
        assert(TECHNOLOGY_JAVA in type.typeToLanguage);
        string typeJavaName = type.typeToLanguage[TECHNOLOGY_JAVA];
        if(!isPrimitive(type)){
            this.requestedTypes.put(type.name);
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
        assert(typeof(parent).stringof == "const(Component)" || typeof(parent).stringof == "const(Container)");
        Rebindable!(const(C)) parentRebindable = cast(C)parent;
        string[] packagePathReverse = [];
        while(true){
            packagePathReverse ~= parentRebindable.name;
            if(auto componentCheckInstance = cast(C)parentRebindable.parent){
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
