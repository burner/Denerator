module predefined.types.address;

import predefined.types.basictypes;

import model.world;
import model.type;
import model.classes;

Class addressClass(Con...)(TheWorld world, Con cons) {
	Class address = world.getOrNewClass("Address", cons);

	address.containerType["D"] = "struct";
	address.containerType["Angular"] = "struct";
	address.containerType["MySQL"] = "Table";

	MemberVariable addressId = address.getOrNew!MemberVariable("id");
	addressId.type = world.getOrNewType("const ULong");
	assert(addressId.type);
	addressId.addLangSpecificAttribute("MySQL", "PRIMARY KEY");
	addressId.addLangSpecificAttribute("MySQL", "AUTO INCREMENT");
	addressId.addLangSpecificAttribute("D", "const");
	addressId.addLangSpecificAttribute("Typescript", "const");

	MemberVariable streetName = address.getOrNew!MemberVariable("streetname");
	streetName.type = world.getOrNewType("String");
	assert(streetName.type);

	MemberVariable streetNumber = address.getOrNew!MemberVariable("streetnumber");
	streetNumber.type = world.getOrNewType("String");
	assert(streetNumber.type);

	MemberVariable apartment = address.getOrNew!MemberVariable("apartment");
	apartment.type = world.getOrNewType("String");
	assert(apartment.type);

	MemberVariable city = address.getOrNew!MemberVariable("city");
	city.type = world.getOrNewType("String");
	assert(city.type);

	MemberVariable postalcode = address.getOrNew!MemberVariable("postalcode");
	postalcode.type = world.getOrNewType("String");
	assert(postalcode.type);

	MemberVariable country = address.getOrNew!MemberVariable("country");
	country.type = world.getOrNewType("String");
	assert(country.type);

	MemberVariable state = address.getOrNew!MemberVariable("state");
	state.type = world.getOrNewType("String");
	assert(state.type);

	MemberVariable district = address.getOrNew!MemberVariable("district");
	district.type = world.getOrNewType("String");
	assert(district.type);

	MemberVariable organisation = address.getOrNew!MemberVariable("organisation");
	organisation.type = world.getOrNewType("String");
	assert(organisation.type);

	return address;
}
