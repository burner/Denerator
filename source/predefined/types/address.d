module predefined.types.address;

import predefined.types.basictypes;

import model.world;
import model.type;
import model.classes;

Class addressClass(Con...)(TheWorld world, Con cons) {
	Class address = getOrNewClass("Address", cons);

	user.containerType["D"] = "struct";
	user.containerType["Angular"] = "struct";
	user.containerType["MySQL"] = "Table";

	MemberVariable userId = user.getOrNew!MemberVariable("id");
	userId.type = world.getOrNewType("ULong");
	assert(userId.type);
	userId.addLangSpecificAttribute("MySQL", "PRIMARY KEY");
	userId.addLangSpecificAttribute("MySQL", "AUTO INCREMENT");
	userId.addLangSpecificAttribute("D", "const");
	userId.addLangSpecificAttribute("Typescript", "const");

	MemberVariable streetName = user.getOrNew!MemberVariable("streetname");
	firstname.type = world.getOrNewType("String");
	assert(streeName.type);

	MemberVariable streetNumber = user.getOrNew!MemberVariable("streetnumber");
	streetNumber.type = world.getOrNewType("String");
	assert(streetNumber.type);

	MemberVariable apartment = user.getOrNew!MemberVariable("apartment");
	state.type = world.getOrNewType("String");
	assert(apartment.type);

	MemberVariable city = user.getOrNew!MemberVariable("city");
	streetNumber.type = world.getOrNewType("String");
	assert(city.type);

	MemberVariable postalcode = user.getOrNew!MemberVariable("postalcode");
	streetNumber.type = world.getOrNewType("String");
	assert(postalcode.type);

	MemberVariable country = user.getOrNew!MemberVariable("country");
	streetNumber.type = world.getOrNewType("String");
	assert(country.type);

	MemberVariable state = user.getOrNew!MemberVariable("state");
	state.type = world.getOrNewType("String");
	assert(state.type);

	MemberVariable district = user.getOrNew!MemberVariable("district");
	state.type = world.getOrNewType("String");
	assert(district.type);

	MemberVariable organisation = user.getOrNew!MemberVariable("organisation");
	state.type = world.getOrNewType("String");
	assert(organisation.type);

	return address;
}
