module predefined.types.basictypes;

import model.world;
import model.type;

void addBasicTypes(TheWorld world) {
	auto types = [
		&voidType,
		&longType, &intType, &shortType, &byteType,
		&ulongType, &uintType, &ushortType, &ubyteType,
		&stringType, &floatType, &doubleType, &dateTimeType,
		&dateType, &timeType, &passwordHashType
	];

	auto constTypes = [
		&clongType, &cintType, &cshortType, &cbyteType,
		&culongType, &cuintType, &cushortType, &cubyteType,
		&cstringType, &cfloatType, &cdoubleType, &cdateTimeType,
		&cdateType, &ctimeType, 
		&boolType];

    //Make the types available within the world
	foreach(it; types) {
		it(world);
	}

	foreach(it; constTypes) {
		auto t = it(world);
		foreach(l; ["D", "C", "C++", "Vibe.d", "Typescript", "Angular",
				"MySQL", "Java"])
		{
			t.protection[l] = "const";
		}
	}
}

Type voidType(TheWorld world) {
	Type lng = world.newType("Void");
	lng.typeToLanguage["D"] = "void";
	lng.typeToLanguage["C"] = "void";
	lng.typeToLanguage["C++"] = "void";
	lng.typeToLanguage["Vibe.d"] = "void";
	lng.typeToLanguage["Typescript"] = "void";
	lng.typeToLanguage["Angular"] = "void";
	lng.typeToLanguage["SeqTS"] = "void";
	lng.typeToLanguage["MySQL"] = "INTEGER";
	lng.typeToLanguage["Java"] = "void";
	return lng;
}

Type floatType(TheWorld world) {
	Type lng = world.newType("Float");
	lng.typeToLanguage["D"] = "float";
	lng.typeToLanguage["C"] = "float";
	lng.typeToLanguage["C++"] = "float";
	lng.typeToLanguage["Vibe.d"] = "float";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "FLOAT";
    lng.typeToLanguage["Java"] = "float";
	return lng;
}

Type doubleType(TheWorld world) {
	Type lng = world.newType("Double");
	lng.typeToLanguage["D"] = "double";
	lng.typeToLanguage["C"] = "double";
	lng.typeToLanguage["C++"] = "double";
	lng.typeToLanguage["Vibe.d"] = "double";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "DOUBLE";
	lng.typeToLanguage["Java"] = "double";
	return lng;
}

Type longType(TheWorld world) {
	Type lng = world.newType("Long");
	lng.typeToLanguage["D"] = "long";
	lng.typeToLanguage["C"] = "int64_t";
	lng.typeToLanguage["C++"] = "int64_t";
	lng.typeToLanguage["Vibe.d"] = "long";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "BIGINT";
	lng.typeToLanguage["Java"] = "long";
	return lng;
}

Type intType(TheWorld world) {
	Type lng = world.newType("Int");
	lng.typeToLanguage["D"] = "int";
	lng.typeToLanguage["C"] = "int32_t";
	lng.typeToLanguage["C++"] = "int32_t";
	lng.typeToLanguage["Vibe.d"] = "int";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "INT";
	lng.typeToLanguage["Java"] = "int";
	return lng;
}

Type shortType(TheWorld world) {
	Type lng = world.newType("Short");
	lng.typeToLanguage["D"] = "short";
	lng.typeToLanguage["C"] = "int16_t";
	lng.typeToLanguage["C++"] = "int16_t";
	lng.typeToLanguage["Vibe.d"] = "short";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "SMALLINT";
	lng.typeToLanguage["Java"] = "short";
	return lng;
}

Type byteType(TheWorld world) {
	Type lng = world.newType("Byte");
	lng.typeToLanguage["D"] = "byte";
	lng.typeToLanguage["C"] = "int8_t";
	lng.typeToLanguage["C++"] = "int8_t";
	lng.typeToLanguage["Vibe.d"] = "byte";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "TINYINT";
	lng.typeToLanguage["Java"] = "byte";
	return lng;
}

Type ulongType(TheWorld world) {
	Type lng = world.newType("ULong");
	lng.typeToLanguage["D"] = "ulong";
	lng.typeToLanguage["C"] = "uint64_t";
	lng.typeToLanguage["C++"] = "uint64_t";
	lng.typeToLanguage["Vibe.d"] = "ulong";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "BIGINT UNSIGNED";
	//TODO jave has no ulong type
	return lng;
}

Type uintType(TheWorld world) {
	Type lng = world.newType("UInt");
	lng.typeToLanguage["D"] = "uint";
	lng.typeToLanguage["C"] = "uint32_t";
	lng.typeToLanguage["C++"] = "uint32_t";
	lng.typeToLanguage["Vibe.d"] = "uint";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "INT UNSIGNED";
	//TODO jave has no uint type
	return lng;
}

Type ushortType(TheWorld world) {
	Type lng = world.newType("UShort");
	lng.typeToLanguage["D"] = "ushort";
	lng.typeToLanguage["C"] = "uint16_t";
	lng.typeToLanguage["C++"] = "uint16_t";
	lng.typeToLanguage["Vibe.d"] = "ushort";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "SMALLINT UNSIGNED";
	//TODO jave has no ushort type
	return lng;
}

Type ubyteType(TheWorld world) {
	Type lng = world.newType("UByte");
	lng.typeToLanguage["D"] = "ubyte";
	lng.typeToLanguage["C"] = "uint8_t";
	lng.typeToLanguage["C++"] = "uint8_t";
	lng.typeToLanguage["Vibe.d"] = "ubyte";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "TINYINT UNSIGNED";
	//TODO jave has no ubyte type
	return lng;
}

Type boolType(TheWorld world) {
	Type lng = world.newType("Bool");
	lng.typeToLanguage["D"] = "bool";
	lng.typeToLanguage["C"] = "bool";
	lng.typeToLanguage["C++"] = "bool";
	lng.typeToLanguage["Vibe.d"] = "bool";
	lng.typeToLanguage["Typescript"] = "boolean";
	lng.typeToLanguage["Angular"] = "boolean";
	lng.typeToLanguage["SeqTS"] = "boolean";
	lng.typeToLanguage["MySQL"] = "BIT(1)";
    lng.typeToLanguage["Java"] = "boolean";
	return lng;
}

Type stringType(TheWorld world) {
	Type lng = world.newType("String");
	lng.typeToLanguage["D"] = "string";
	lng.typeToLanguage["C"] = "const char*";
	lng.typeToLanguage["C++"] = "std::string";
	lng.typeToLanguage["Vibe.d"] = "string";
	lng.typeToLanguage["Typescript"] = "string";
	lng.typeToLanguage["Angular"] = "string";
	lng.typeToLanguage["SeqTS"] = "string";
	lng.typeToLanguage["MySQL"] = "TEXT";
	lng.typeToLanguage["Java"] = "String";
	return lng;
}

Type dateType(TheWorld world) {
	Type lng = world.newType("Date");
	lng.typeToLanguage["D"] = "Date";
	lng.typeToLanguage["C++"] = "std::time_point";
	lng.typeToLanguage["Vibe.d"] = "Date";
	lng.typeToLanguage["Typescript"] = "Date";
	lng.typeToLanguage["Angular"] = "Date";
	lng.typeToLanguage["MySQL"] = "Date";
	lng.typeToLanguage["Java"] = "Date";
	lng.typeToLanguage["SeqTS"] = "Date";	return lng;
}

Type timeType(TheWorld world) {
	Type lng = world.newType("Time");
	lng.typeToLanguage["D"] = "TimeOfDay";
	lng.typeToLanguage["C++"] = "std::time_point";
	lng.typeToLanguage["Vibe.d"] = "TimeOfDay";
	lng.typeToLanguage["Typescript"] = "Date";
	lng.typeToLanguage["Angular"] = "Date";
	lng.typeToLanguage["SetTS"] = "Date";
	lng.typeToLanguage["MySQL"] = "TIME";
	//TODO java does not have this kind of type ???
	return lng;
}

Type dateTimeType(TheWorld world) {
	Type lng = world.newType("DateTime");
	lng.typeToLanguage["D"] = "DateTime";
	lng.typeToLanguage["C++"] = "std::time_point";
	lng.typeToLanguage["Vibe.d"] = "TimeOfDay";
	lng.typeToLanguage["Typescript"] = "Date";
	lng.typeToLanguage["Angular"] = "Date";
	lng.typeToLanguage["SeqTS"] = "Date";
	lng.typeToLanguage["MySQL"] = "DATETIME";
	lng.typeToLanguage["Java"] = "DateTime";
    //TODO determine if this type is the correct one
	return lng;
}

Type cfloatType(TheWorld world) {
	Type lng = world.newType("const Float");
	lng.typeToLanguage["D"] = "float";
	lng.typeToLanguage["C"] = "float";
	lng.typeToLanguage["C++"] = "float";
	lng.typeToLanguage["Vibe.d"] = "float";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["MySQL"] = "FLOAT";
	//TODO detemine if this type is the correct one for a constant type
	lng.typeToLanguage["Java"] = "float";
	return lng;
}

Type cdoubleType(TheWorld world) {
	Type lng = world.newType("const Double");
	lng.typeToLanguage["D"] = "double";
	lng.typeToLanguage["C"] = "double";
	lng.typeToLanguage["C++"] = "double";
	lng.typeToLanguage["Vibe.d"] = "double";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["MySQL"] = "DOUBLE";
	//TODO detemine if this type is the correct one for a constant type
	lng.typeToLanguage["Java"] = "double";
	return lng;
}

Type clongType(TheWorld world) {
	Type lng = world.newType("const Long");
	lng.typeToLanguage["D"] = "long";
	lng.typeToLanguage["C"] = "int64_t";
	lng.typeToLanguage["C++"] = "int64_t";
	lng.typeToLanguage["Vibe.d"] = "long";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "BIGINT";
	//TODO detemine if this type is the correct one for a constant type
	lng.typeToLanguage["Java"] = "long";
	return lng;
}

Type cintType(TheWorld world) {
	Type lng = world.newType("const Int");
	lng.typeToLanguage["D"] = "int";
	lng.typeToLanguage["C"] = "int32_t";
	lng.typeToLanguage["C++"] = "int32_t";
	lng.typeToLanguage["Vibe.d"] = "int";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "INT";
	//TODO detemine if this type is the correct one for a constant type
	lng.typeToLanguage["Java"] = "int";
	return lng;
}

Type cshortType(TheWorld world) {
	Type lng = world.newType("const Short");
	lng.typeToLanguage["D"] = "short";
	lng.typeToLanguage["C"] = "int16_t";
	lng.typeToLanguage["C++"] = "int16_t";
	lng.typeToLanguage["Vibe.d"] = "short";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "SMALLINT";
	//TODO detemine if this type is the correct one for a constant type
	lng.typeToLanguage["Java"] = "short";
	return lng;

}

Type cbyteType(TheWorld world) {
	Type lng = world.newType("const Byte");
	lng.typeToLanguage["D"] = "byte";
	lng.typeToLanguage["C"] = "int8_t";
	lng.typeToLanguage["C++"] = "int8_t";
	lng.typeToLanguage["Vibe.d"] = "byte";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "TINYINT";
	//TODO detemine if this type is the correct one for a constant type
	lng.typeToLanguage["Java"] = "byte";
	return lng;
}

Type culongType(TheWorld world) {
	Type lng = world.newType("const ULong");
	lng.typeToLanguage["D"] = "ulong";
	lng.typeToLanguage["C"] = "uint64_t";
	lng.typeToLanguage["C++"] = "uint64_t";
	lng.typeToLanguage["Vibe.d"] = "ulong";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "BIGINT UNSIGNED";
	//TODO detemine if this type is the correct one for a constant, unsigned type
	lng.typeToLanguage["Java"] = "long";
	return lng;
}

Type cuintType(TheWorld world) {
	Type lng = world.newType("const UInt");
	lng.typeToLanguage["D"] = "uint";
	lng.typeToLanguage["C"] = "uint32_t";
	lng.typeToLanguage["C++"] = "uint32_t";
	lng.typeToLanguage["Vibe.d"] = "uint";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "INT UNSIGNED";
	//TODO detemine if this type is the correct one for a constant, unsigned type
	lng.typeToLanguage["Java"] = "int";
	return lng;
}

Type cushortType(TheWorld world) {
	Type lng = world.newType("const UShort");
	lng.typeToLanguage["D"] = "ushort";
	lng.typeToLanguage["C"] = "uint16_t";
	lng.typeToLanguage["C++"] = "uint16_t";
	lng.typeToLanguage["Vibe.d"] = "ushort";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "SMALLINT UNSIGNED";
	//TODO detemine if this type is the correct one for a constant, unsigned type
	lng.typeToLanguage["Java"] = "short";
	return lng;
}

Type cubyteType(TheWorld world) {
	Type lng = world.newType("const UByte");
	lng.typeToLanguage["D"] = "ubyte";
	lng.typeToLanguage["C"] = "uint8_t";
	lng.typeToLanguage["C++"] = "uint8_t";
	lng.typeToLanguage["Vibe.d"] = "ubyte";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["SeqTS"] = "number";
	lng.typeToLanguage["MySQL"] = "TINYINT UNSIGNED";
	//TODO detemine if this type is the correct one for a constant, unsigned type
	lng.typeToLanguage["Java"] = "byte";
	return lng;
}

Type cboolType(TheWorld world) {
	Type lng = world.newType("const Bool");
	lng.typeToLanguage["D"] = "bool";
	lng.typeToLanguage["C"] = "bool";
	lng.typeToLanguage["C++"] = "bool";
	lng.typeToLanguage["Vibe.d"] = "bool";
	lng.typeToLanguage["Typescript"] = "boolean";
	lng.typeToLanguage["Angular"] = "boolean";
	lng.typeToLanguage["SeqTS"] = "boolean";
	lng.typeToLanguage["MySQL"] = "BIT(1)";
	//TODO detemine if this type is the correct one for a constant type
	lng.typeToLanguage["Java"] = "boolean";
	return lng;
}

Type cstringType(TheWorld world) {
	Type lng = world.newType("const String");
	lng.typeToLanguage["D"] = "string";
	lng.typeToLanguage["C"] = "const char*";
	lng.typeToLanguage["C++"] = "std::string";
	lng.typeToLanguage["Vibe.d"] = "string";
	lng.typeToLanguage["Typescript"] = "string";
	lng.typeToLanguage["Angular"] = "string";
	lng.typeToLanguage["SeqTS"] = "string";
	lng.typeToLanguage["MySQL"] = "TEXT";
	//TODO detemine if this type is the correct one for a constant type
	lng.typeToLanguage["Java"] = "String";
	return lng;
}

Type cdateType(TheWorld world) {
	Type lng = world.newType("const Date");
	lng.typeToLanguage["D"] = "Date";
	lng.typeToLanguage["C++"] = "std::time_point";
	lng.typeToLanguage["Vibe.d"] = "Date";
	lng.typeToLanguage["Typescript"] = "Date";
	lng.typeToLanguage["Angular"] = "Date";
	lng.typeToLanguage["MySQL"] = "Date";
	//TODO detemine if this type is the correct one for a constant type
	lng.typeToLanguage["Java"] = "Date";
	return lng;
}

Type ctimeType(TheWorld world) {
	Type lng = world.newType("const Time");
	lng.typeToLanguage["D"] = "TimeOfDay";
	lng.typeToLanguage["C++"] = "std::time_point";
	lng.typeToLanguage["Vibe.d"] = "TimeOfDay";
	lng.typeToLanguage["Typescript"] = "Date";
	lng.typeToLanguage["Angular"] = "Date";
	lng.typeToLanguage["MySQL"] = "TIME";
	//TODO for java
	return lng;
}

Type cdateTimeType(TheWorld world) {
	Type lng = world.newType("const DateTime");
	lng.typeToLanguage["D"] = "DateTime";
	lng.typeToLanguage["C++"] = "std::time_point";
	lng.typeToLanguage["Vibe.d"] = "TimeOfDay";
	lng.typeToLanguage["Typescript"] = "Date";
	lng.typeToLanguage["Angular"] = "Date";
	lng.typeToLanguage["MySQL"] = "DATETIME";
	//TODO for java
	return lng;
}

Type passwordHashType(TheWorld world) {
	Type lng = world.newType("PasswordHash");
	lng.typeToLanguage["D"] = "ubyte[64]";
	lng.typeToLanguage["C++"] = "std::vector<uint8_t>";
	lng.typeToLanguage["Vibe.d"] = "ubyte[64]";
	lng.typeToLanguage["MySQL"] = "BINARY(64)";
	lng.typeToLanguage["SeqTS"] = "string";
	lng.typeToLanguage["Angular"] = "string";
	//TODO for java
	return lng;
}
