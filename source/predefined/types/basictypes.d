module predefined.types.basictypes;

import model.world;
import model.type;

void addBasicTypes(TheWorld world) {
	auto types = [&floatType, &doubleType, 
		 &longType, &intType, &shortType, &byteType,
		 &ulongType, &uintType, &ushortType, &ubyteType,
		 &stringType, &floatType, &doubleType, &dateTimeType,
		 &dateType, &timeType, &passwordHashType, &boolType];

	foreach(it; types) {
		it(world);
	}
}

Type floatType(TheWorld world) {
	Type lng = world.getOrNewType("Float");
	lng.typeToLanguage["D"] = "float";
	lng.typeToLanguage["C"] = "float";
	lng.typeToLanguage["C++"] = "float";
	lng.typeToLanguage["Vibe.d"] = "float";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["Angular2"] = "number";
	lng.typeToLanguage["MySQL"] = "FLOAT";
	return lng;
}

Type doubleType(TheWorld world) {
	Type lng = world.getOrNewType("Double");
	lng.typeToLanguage["D"] = "double";
	lng.typeToLanguage["C"] = "double";
	lng.typeToLanguage["C++"] = "double";
	lng.typeToLanguage["Vibe.d"] = "double";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["Angular2"] = "number";
	lng.typeToLanguage["MySQL"] = "DOUBLE";
	return lng;
}

Type longType(TheWorld world) {
	Type lng = world.getOrNewType("Long");
	lng.typeToLanguage["D"] = "long";
	lng.typeToLanguage["C"] = "int64_t";
	lng.typeToLanguage["C++"] = "int64_t";
	lng.typeToLanguage["Vibe.d"] = "long";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["Angular2"] = "number";
	lng.typeToLanguage["MySQL"] = "BIGINT";
	return lng;
}

Type intType(TheWorld world) {
	Type lng = world.getOrNewType("Int");
	lng.typeToLanguage["D"] = "int";
	lng.typeToLanguage["C"] = "int32_t";
	lng.typeToLanguage["C++"] = "int32_t";
	lng.typeToLanguage["Vibe.d"] = "int";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["Angular2"] = "number";
	lng.typeToLanguage["MySQL"] = "INT";
	return lng;
}

Type shortType(TheWorld world) {
	Type lng = world.getOrNewType("Short");
	lng.typeToLanguage["D"] = "short";
	lng.typeToLanguage["C"] = "int16_t";
	lng.typeToLanguage["C++"] = "int16_t";
	lng.typeToLanguage["Vibe.d"] = "short";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["Angular2"] = "number";
	lng.typeToLanguage["MySQL"] = "SMALLINT";
	return lng;
}

Type byteType(TheWorld world) {
	Type lng = world.getOrNewType("Byte");
	lng.typeToLanguage["D"] = "byte";
	lng.typeToLanguage["C"] = "int8_t";
	lng.typeToLanguage["C++"] = "int8_t";
	lng.typeToLanguage["Vibe.d"] = "byte";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["Angular2"] = "number";
	lng.typeToLanguage["MySQL"] = "TINYINT";
	return lng;
}

Type ulongType(TheWorld world) {
	Type lng = world.getOrNewType("ULong");
	lng.typeToLanguage["D"] = "ulong";
	lng.typeToLanguage["C"] = "uint64_t";
	lng.typeToLanguage["C++"] = "uint64_t";
	lng.typeToLanguage["Vibe.d"] = "ulong";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["Angular2"] = "number";
	lng.typeToLanguage["MySQL"] = "BIGINT UNSIGNED";
	return lng;
}

Type uintType(TheWorld world) {
	Type lng = world.getOrNewType("UInt");
	lng.typeToLanguage["D"] = "uint";
	lng.typeToLanguage["C"] = "uint32_t";
	lng.typeToLanguage["C++"] = "uint32_t";
	lng.typeToLanguage["Vibe.d"] = "uint";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["Angular2"] = "number";
	lng.typeToLanguage["MySQL"] = "INT UNSIGNED";
	return lng;
}

Type ushortType(TheWorld world) {
	Type lng = world.getOrNewType("UShort");
	lng.typeToLanguage["D"] = "ushort";
	lng.typeToLanguage["C"] = "uint16_t";
	lng.typeToLanguage["C++"] = "uint16_t";
	lng.typeToLanguage["Vibe.d"] = "ushort";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["Angular2"] = "number";
	lng.typeToLanguage["MySQL"] = "SMALLINT UNSIGNED";
	return lng;
}

Type ubyteType(TheWorld world) {
	Type lng = world.getOrNewType("UByte");
	lng.typeToLanguage["D"] = "ubyte";
	lng.typeToLanguage["C"] = "uint8_t";
	lng.typeToLanguage["C++"] = "uint8_t";
	lng.typeToLanguage["Vibe.d"] = "ubyte";
	lng.typeToLanguage["Typescript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["Angular2"] = "number";
	lng.typeToLanguage["MySQL"] = "TINYINT UNSIGNED";
	return lng;
}

Type boolType(TheWorld world) {
	Type lng = world.getOrNewType("Bool");
	lng.typeToLanguage["D"] = "bool";
	lng.typeToLanguage["C"] = "bool";
	lng.typeToLanguage["C++"] = "bool";
	lng.typeToLanguage["Vibe.d"] = "bool";
	lng.typeToLanguage["Typescript"] = "boolean";
	lng.typeToLanguage["Angular"] = "boolean";
	lng.typeToLanguage["Angular2"] = "boolean";
	lng.typeToLanguage["MySQL"] = "BIT(1)";
	return lng;
}

Type stringType(TheWorld world) {
	Type lng = world.getOrNewType("String");
	lng.typeToLanguage["D"] = "string";
	lng.typeToLanguage["C"] = "const char*";
	lng.typeToLanguage["C++"] = "std::string";
	lng.typeToLanguage["Vibe.d"] = "string";
	lng.typeToLanguage["Typescript"] = "string";
	lng.typeToLanguage["Angular"] = "string";
	lng.typeToLanguage["Angular2"] = "string";
	lng.typeToLanguage["MySQL"] = "TEXT";
	return lng;
}

Type dateType(TheWorld world) {
	Type lng = world.getOrNewType("Date");
	lng.typeToLanguage["D"] = "Date";
	lng.typeToLanguage["C++"] = "std::time_point";
	lng.typeToLanguage["Vibe.d"] = "Date";
	lng.typeToLanguage["Typescript"] = "Date";
	lng.typeToLanguage["Angular"] = "Date";
	lng.typeToLanguage["Angular2"] = "Date";
	lng.typeToLanguage["MySQL"] = "Date";
	return lng;
}

Type timeType(TheWorld world) {
	Type lng = world.getOrNewType("Time");
	lng.typeToLanguage["D"] = "TimeOfDay";
	lng.typeToLanguage["C++"] = "std::time_point";
	lng.typeToLanguage["Vibe.d"] = "TimeOfDay";
	lng.typeToLanguage["Typescript"] = "Date";
	lng.typeToLanguage["Angular"] = "Date";
	lng.typeToLanguage["Angular2"] = "Date";
	lng.typeToLanguage["MySQL"] = "TIME";
	return lng;
}

Type dateTimeType(TheWorld world) {
	Type lng = world.getOrNewType("DateTime");
	lng.typeToLanguage["D"] = "DateTime";
	lng.typeToLanguage["C++"] = "std::time_point";
	lng.typeToLanguage["Vibe.d"] = "TimeOfDay";
	lng.typeToLanguage["Typescript"] = "Date";
	lng.typeToLanguage["Angular"] = "Date";
	lng.typeToLanguage["Angular2"] = "Date";
	lng.typeToLanguage["MySQL"] = "DATETIME";
	return lng;
}

Type passwordHashType(TheWorld world) {
	Type lng = world.getOrNewType("PasswordHash");
	lng.typeToLanguage["D"] = "ubyte[64]";
	lng.typeToLanguage["C++"] = "std::vector<uint8_t>";
	lng.typeToLanguage["Vibe.d"] = "ubyte[64]";
	lng.typeToLanguage["MySQL"] = "BINARY(64)";
	return lng;
}
