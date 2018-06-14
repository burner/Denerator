module entity_modification;

import std.stdio;
import model;


T[] modifyElements(T : Entity, F : T function(T))(T[] entitiesToModify, F[] functions){
    T[] result;
    bool first = true;
    foreach(function_ ; functions){
        if(first){
            foreach(entity ; entitiesToModify){
                result ~= function_(entity);
            }
        }
        else{
            for( int i = 0; i < result.length; ++i ){
                function_(result[i]);
            }
        }
        first = false;
    }
    return result;
}

T setDoNotGenerateFlagToYes(T : Class)(T clazz){
    clazz.doNotGenerate = DoNotGenerate.yes;
    return clazz;
}

T setDoNotGenerateFlagToNo(T)(T entity){
    entity.doNotGenerate = DoNotGenerate.no;
    return entity;
}

T setContainerTypeToJavaClass(T)(T entity){
    entity.containerType["Java"] = "class";
    return entity;
}

T setContainerTypeToJavaEnum(T : Class)(T clazz){
    clazz.containerType["Java"] = "enum";
    return clazz;
}

T setContainerTypeToJavaInterface(T : Class)(T clazz){
   clazz.containerType["Java"] = "interface";
   return clazz;
}

T setProtectionToJavaPublic(T : ProtectedEntity)(T entity){
    entity.protection["Java"] = "public";
    return entity;
}

T setProtectionToJavaProtected(T : ProtectedEntity)(T entity){
    entity.protection["Java"] = "protected";
    return entity;
}

T setModelTypeNameAsJavaClassName(T : Type)(T type){
    type.typeToLanguage["Java"] = type.name;
    return type;
}

T addModifierAbstract(T: Class)(T clazz){
    clazz.languageSpecificAttributes["Java"] ~= "abstract";
    return clazz;
}

T addModifierAbstract(T : Member)(T member){
    member.langSpecificAttributes["Java"] ~= "abstract";
    return member;
}

MemberFunction addSetter(ref MemberVariable memberVariable, ref MemberFunction[] memberFunctionsContainer, Class clazz, TheWorld world){
    MemberFunction setter = clazz.newMemberFunction(getSetOrGetFunctionName(memberVariable, "set"));
    setter.returnType = world.getType("Void");
    setter.addParameter(memberVariable.name, memberVariable.type);
    memberFunctionsContainer ~= setter;
    return setter;
}

MemberFunction addGetter(ref MemberVariable memberVariable, ref MemberFunction[] memberFunctionsContainer, Class clazz, TheWorld world){
    MemberFunction getter = clazz.newMemberFunction(getSetOrGetFunctionName(memberVariable, "get"));
    getter.returnType = memberVariable.type;
    memberFunctionsContainer ~= getter;
    return getter;
}

string getSetOrGetFunctionName(ref MemberVariable memberVariable, string setOrGet){
    import std.ascii : toUpper;
    char[] functionNamePart = memberVariable.name.dup;
    assert(functionNamePart.length > 0, "The name of a function must consist of at least 1 character.");
    functionNamePart[0] = toUpper(functionNamePart[0]);
    return (setOrGet ~ functionNamePart).idup;
}