module predefined.types.basictypes;

import model.world;
import model.type;

void addBasicTypes(TheWorld world) {
	auto types = [
		&floatType, &doubleType, 
		&longType, &intType, &shortType, &byteType,
		&ulongType, &uintType, &ushortType, &ubyteType,
		&stringType, &floatType, &doubleType, &dateTimeType,
		&dateType, &timeType, 
		&cfloatType, &cdoubleType, 
		&clongType, &cintType, &cshortType, &cbyteType,
		&culongType, &cuintType, &cushortType, &cubyteType,
		&cstringType, &cfloatType, &cdoubleType, &cdateTimeType,
		&cdateType, &ctimeType, 
		&passwordHashType, &boolType];

	foreach(it; types) {
		it(world);
	}
}

Type floatType(TheWorld world) {
	Type lng = world.newType("Float");
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
	Type lng = world.newType("Double");
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
	Type lng = world.newType("Long");
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
	Type lng = world.newType("Int");
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
	Type lng = world.newType("Short");
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
	Type lng = world.newType("Byte");
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
	Type lng = world.newType("ULong");
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
	Type lng = world.newType("UInt");
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
	Type lng = world.newType("UShort");
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
	Type lng = world.newType("UByte");
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
	Type lng = world.newType("Bool");
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
	Type lng = world.newType("String");
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
	Type lng = world.newType("Date");
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
	Type lng = world.newType("Time");
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
	Type lng = world.newType("DateTime");
	lng.typeToLanguage["D"] = "DateTime";
	lng.typeToLanguage["C++"] = "std::time_point";
	lng.typeToLanguage["Vibe.d"] = "TimeOfDay";
	lng.typeToLanguage["Typescript"] = "Date";
	lng.typeToLanguage["Angular"] = "Date";
	lng.typeToLanguage["Angular2"] = "Date";
	lng.typeToLanguage["MySQL"] = "DATETIME";
	return lng;
}

Type cfloatType(TheWorld world) {
	Type lng = world.newType("const Float");
	lng.typeToLanguage["D"] = "const(float)";
	lng.typeToLanguage["C"] = "const float";
	lng.typeToLanguage["C++"] = "float const";
	lng.typeToLanguage["Vibe.d"] = "const(float)";
	lng.typeToLanguage["Typescript"] = "const number";
	lng.typeToLanguage["Angular"] = "const number";
	lng.typeToLanguage["Angular2"] = "const number";
	lng.typeToLanguage["MySQL"] = "FLOAT";
	return lng;
}

Type cdoubleType(TheWorld world) {
	Type lng = world.newType("const Double");
	lng.typeToLanguage["D"] = "const(double)";
	lng.typeToLanguage["C"] = "const double";
	lng.typeToLanguage["C++"] = "double const";
	lng.typeToLanguage["Vibe.d"] = "const(double)";
	lng.typeToLanguage["Typescript"] = "const number";
	lng.typeToLanguage["Angular"] = "const number";
	lng.typeToLanguage["Angular2"] = "const number";
	lng.typeToLanguage["MySQL"] = "DOUBLE";
	return lng;
}

Type clongType(TheWorld world) {
	Type lng = world.newType("const Long");
	lng.typeToLanguage["D"] = "const(long)";
	lng.typeToLanguage["C"] = "const int64_t";
	lng.typeToLanguage["C++"] = "int64_t const";
	lng.typeToLanguage["Vibe.d"] = "const(long)";
	lng.typeToLanguage["Typescript"] = "const number";
	lng.typeToLanguage["Angular"] = "const number";
	lng.typeToLanguage["Angular2"] = "const number";
	lng.typeToLanguage["MySQL"] = "BIGINT";
	return lng;
}

Type cintType(TheWorld world) {
	Type lng = world.newType("const Int");
	lng.typeToLanguage["D"] = "const(int)";
	lng.typeToLanguage["C"] = "const int32_t";
	lng.typeToLanguage["C++"] = "int32_t const";
	lng.typeToLanguage["Vibe.d"] = "const(int)";
	lng.typeToLanguage["Typescript"] = "const number";
	lng.typeToLanguage["Angular"] = "const number";
	lng.typeToLanguage["Angular2"] = "const number";
	lng.typeToLanguage["MySQL"] = "INT";
	return lng;
}

Type cshortType(TheWorld world) {
	Type lng = world.newType("const Short");
	lng.typeToLanguage["D"] = "const(short)";
	lng.typeToLanguage["C"] = "const int16_t";
	lng.typeToLanguage["C++"] = "int16_t const";
	lng.typeToLanguage["Vibe.d"] = "const(short)";
	lng.typeToLanguage["Typescript"] = "const number";
	lng.typeToLanguage["Angular"] = "const number";
	lng.typeToLanguage["Angular2"] = "const number";
	lng.typeToLanguage["MySQL"] = "SMALLINT";
	return lng;
}

Type cbyteType(TheWorld world) {
	Type lng = world.newType("const Byte");
	lng.typeToLanguage["D"] = "const(byte)";
	lng.typeToLanguage["C"] = "const int8_t";
	lng.typeToLanguage["C++"] = "int8_t const";
	lng.typeToLanguage["Vibe.d"] = "const(byte)";
	lng.typeToLanguage["Typescript"] = "const number";
	lng.typeToLanguage["Angular"] = "const number";
	lng.typeToLanguage["Angular2"] = "const number";
	lng.typeToLanguage["MySQL"] = "TINYINT";
	return lng;
}

Type culongType(TheWorld world) {
	Type lng = world.newType("const ULong");
	lng.typeToLanguage["D"] = "const(ulong)";
	lng.typeToLanguage["C"] = "const uint64_t";
	lng.typeToLanguage["C++"] = "uint64_t const";
	lng.typeToLanguage["Vibe.d"] = "const(ulong)";
	lng.typeToLanguage["Typescript"] = "const number";
	lng.typeToLanguage["Angular"] = "const number";
	lng.typeToLanguage["Angular2"] = "const number";
	lng.typeToLanguage["MySQL"] = "BIGINT UNSIGNED";
	return lng;
}

Type cuintType(TheWorld world) {
	Type lng = world.newType("const UInt");
	lng.typeToLanguage["D"] = "const(uint)";
	lng.typeToLanguage["C"] = "const uint32_t";
	lng.typeToLanguage["C++"] = "uint32_t const";
	lng.typeToLanguage["Vibe.d"] = "const(uint)";
	lng.typeToLanguage["Typescript"] = "const number";
	lng.typeToLanguage["Angular"] = "const number";
	lng.typeToLanguage["Angular2"] = "const number";
	lng.typeToLanguage["MySQL"] = "INT UNSIGNED";
	return lng;
}

Type cushortType(TheWorld world) {
	Type lng = world.newType("const UShort");
	lng.typeToLanguage["D"] = "const(ushort)";
	lng.typeToLanguage["C"] = "const uint16_t";
	lng.typeToLanguage["C++"] = "uint16_t const";
	lng.typeToLanguage["Vibe.d"] = "const(ushort)";
	lng.typeToLanguage["Typescript"] = "const number";
	lng.typeToLanguage["Angular"] = "const number";
	lng.typeToLanguage["Angular2"] = "const number";
	lng.typeToLanguage["MySQL"] = "SMALLINT UNSIGNED";
	return lng;
}

Type cubyteType(TheWorld world) {
	Type lng = world.newType("const UByte");
	lng.typeToLanguage["D"] = "const(ubyte)";
	lng.typeToLanguage["C"] = "const uint8_t";
	lng.typeToLanguage["C++"] = "uint8_t const";
	lng.typeToLanguage["Vibe.d"] = "const(ubyte)";
	lng.typeToLanguage["Typescript"] = "const number";
	lng.typeToLanguage["Angular"] = "const number";
	lng.typeToLanguage["Angular2"] = "const number";
	lng.typeToLanguage["MySQL"] = "TINYINT UNSIGNED";
	return lng;
}

Type cboolType(TheWorld world) {
	Type lng = world.newType("const Bool");
	lng.typeToLanguage["D"] = "const(bool)";
	lng.typeToLanguage["C"] = "const bool";
	lng.typeToLanguage["C++"] = "bool const";
	lng.typeToLanguage["Vibe.d"] = "const(bool)";
	lng.typeToLanguage["Typescript"] = "const boolean";
	lng.typeToLanguage["Angular"] = "const boolean";
	lng.typeToLanguage["Angular2"] = "const boolean";
	lng.typeToLanguage["MySQL"] = "BIT(1)";
	return lng;
}

Type cstringType(TheWorld world) {
	Type lng = world.newType("const String");
	lng.typeToLanguage["D"] = "const(string)";
	lng.typeToLanguage["C"] = "const char const*";
	lng.typeToLanguage["C++"] = "std::string const";
	lng.typeToLanguage["Vibe.d"] = "const(string)";
	lng.typeToLanguage["Typescript"] = "const string";
	lng.typeToLanguage["Angular"] = "const string";
	lng.typeToLanguage["Angular2"] = "const string";
	lng.typeToLanguage["MySQL"] = "TEXT";
	return lng;
}

Type cdateType(TheWorld world) {
	Type lng = world.newType("const Date");
	lng.typeToLanguage["D"] = "const(Date)";
	lng.typeToLanguage["C++"] = "std::time_point const";
	lng.typeToLanguage["Vibe.d"] = "const(Date)";
	lng.typeToLanguage["Typescript"] = "const Date";
	lng.typeToLanguage["Angular"] = "const Date";
	lng.typeToLanguage["Angular2"] = "const Date";
	lng.typeToLanguage["MySQL"] = "Date";
	return lng;
}

Type ctimeType(TheWorld world) {
	Type lng = world.newType("const Time");
	lng.typeToLanguage["D"] = "const(TimeOfDay)";
	lng.typeToLanguage["C++"] = "std::time_point const";
	lng.typeToLanguage["Vibe.d"] = "const(TimeOfDay)";
	lng.typeToLanguage["Typescript"] = "const Date";
	lng.typeToLanguage["Angular"] = "const Date";
	lng.typeToLanguage["Angular2"] = "const Date";
	lng.typeToLanguage["MySQL"] = "TIME";
	return lng;
}

Type cdateTimeType(TheWorld world) {
	Type lng = world.newType("const DateTime");
	lng.typeToLanguage["D"] = "const(DateTime)";
	lng.typeToLanguage["C++"] = "std::time_point const";
	lng.typeToLanguage["Vibe.d"] = "const(TimeOfDay)";
	lng.typeToLanguage["Typescript"] = "const Date";
	lng.typeToLanguage["Angular"] = "const Date";
	lng.typeToLanguage["Angular2"] = "const Date";
	lng.typeToLanguage["MySQL"] = "DATETIME";
	return lng;
}

Type passwordHashType(TheWorld world) {
	Type lng = world.newType("PasswordHash");
	lng.typeToLanguage["D"] = "ubyte[64]";
	lng.typeToLanguage["C++"] = "std::vector<uint8_t>";
	lng.typeToLanguage["Vibe.d"] = "ubyte[64]";
	lng.typeToLanguage["MySQL"] = "BINARY(64)";
	return lng;
}
