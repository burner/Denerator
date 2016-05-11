module predefined.types.basictypes;

import model;

Type longType(World world) {
	Type lng = world.getOrNewType("Long");
	lng.typeToLanguage["D"] = "long";
	lng.typeToLanguage["Vibe.d"] = "long";
	lng.typeToLanguage["Javascript"] = "number";
	lng.typeToLanguage["Angular"] = "number";
	lng.typeToLanguage["Angular2"] = "number";
	lng.typeToLanguage["MySQL"] = "LONG";
	return lng;
}
