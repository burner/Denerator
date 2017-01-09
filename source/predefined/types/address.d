module predefined.types.address;

import predefined.types.basictypes;

import model.world;
import model.type;
import model.classes;

Class addressClass(Con...)(TheWorld world, Con cons) {
	Class address = world.newClass("Address", cons);

	address.containerType["D"] = "struct";
	address.containerType["Angular"] = "struct";
	address.containerType["MySQL"] = "Table";

	MemberVariable addressId = address.newMemberVariable("id");
	addressId.type = world.getType("const ULong");
	assert(addressId.type);
	addressId.addLangSpecificAttribute("MySQL", "PRIMARY KEY");
	addressId.addLangSpecificAttribute("MySQL", "AUTO INCREMENT");
	addressId.addLangSpecificAttribute("D", "const");
	addressId.addLangSpecificAttribute("Typescript", "const");

	MemberVariable streetName = address.newMemberVariable("streetname");
	streetName.type = world.getType("String");
	assert(streetName.type);

	MemberVariable streetNumber = address.newMemberVariable("streetnumber");
	streetNumber.type = world.getType("String");
	assert(streetNumber.type);

	MemberVariable apartment = address.newMemberVariable("apartment");
	apartment.type = world.getType("String");
	assert(apartment.type);

	MemberVariable city = address.newMemberVariable("city");
	city.type = world.getType("String");
	assert(city.type);

	MemberVariable postalcode = address.newMemberVariable("postalcode");
	postalcode.type = world.getType("String");
	assert(postalcode.type);

	MemberVariable country = address.newMemberVariable("country");
	country.type = world.getType("String");
	assert(country.type);

	MemberVariable state = address.newMemberVariable("state");
	state.type = world.getType("String");
	assert(state.type);

	MemberVariable district = address.newMemberVariable("district");
	district.type = world.getType("String");
	assert(district.type);

	MemberVariable organisation = address.newMemberVariable("organisation");
	organisation.type = world.getType("String");
	assert(organisation.type);

	return address;
}
