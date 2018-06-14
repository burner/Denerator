module next_song_calc;

import std.stdio;
import next_song_calc;
import model;
import predefined.types.user;
import predefined.types.group;
import generator.java;
import entity_modification;

void nextSongCalcModel(ref TheWorld world){

    addExternalTypes(world);

    //Classes container for peroforming operations on all classes that need to be generated
    Class[] generatedClasses;

    Class[] notGeneratedClasses;

    Class[] generatedInterfaces;

    Class[] notGeneratedInterfaces;

    Enum[] generatedEnums;

    MemberFunction[] abstractMemberFunctions;

    MemberVariable[] protectedMemberVariables;

    MemberVariable[] beanMemberVariable;

    //Model
    Container binarySearchTreeNextSongCalculationSystem = world.getSoftwareSystem("Next Song Calculation System").newContainer("BinarySearchTreeNextSongCalculationSystem");
    binarySearchTreeNextSongCalculationSystem.technology = "Java";

    Component de = binarySearchTreeNextSongCalculationSystem.newComponent("de");
    Component uol = de.newSubComponent("uol");
    Component smtrain = uol.newSubComponent("smtrain");

    Component next_song_calculation_system = smtrain.newSubComponent("next_song_calculation_system");

        Component next_song_api = next_song_calculation_system.newSubComponent("next_song_api");
            Class nextSong = world.newClass("NextSong", next_song_api);
            notGeneratedClasses ~= nextSong;

            Class nextSongCalculationController = world.newClass("nextSongCalculationController", next_song_api);
            notGeneratedClasses ~= nextSongCalculationController;

        Component repository = next_song_calculation_system.newSubComponent("repository");
            Class repositoryService = world.newClass("RepositoryService", repository);
            generatedClasses ~= repositoryService;

            Component database = repository.newSubComponent("database");
                Class databaseConfig = world.newClass("DatabaseConfig", database);
                notGeneratedClasses ~= databaseConfig;

                Class songSample = world.newClass("SongSample", database);
                notGeneratedClasses ~= songSample;

                Class songSampleRepository = world.newClass("SongSampleRepository", database);
                notGeneratedInterfaces ~= songSampleRepository;

                Class trackMetaDataDatabase = world.newClass("TrackMetaDataDatabase", database);
                notGeneratedClasses ~= trackMetaDataDatabase;

                Class trackMetaDataRepository = world.newClass("TrackMetaDataRepository", database);
                notGeneratedInterfaces ~= trackMetaDataRepository;

            Component song_recommendation = repository.newSubComponent("song_recommendation");
                Class songRecommendationAttributes = world.newClass("SongRecommendationAttributes", song_recommendation);
                notGeneratedClasses ~= songRecommendationAttributes;

                Class songRecommendationConfig = world.newClass("CongRecommendationConfig", song_recommendation);
                notGeneratedClasses ~= songRecommendationConfig;

                Class songRecommendationRestApi_ = world.newClass("SongRecommendationRestApi_", song_recommendation);
                notGeneratedInterfaces ~= songRecommendationRestApi_;

                Class songRecommendationTargets = world.newClass("SongRecommendationTargets", song_recommendation);
                notGeneratedClasses ~= songRecommendationTargets;

            Component spotify = repository.newSubComponent("spotify");

                Component auth = spotify.newSubComponent("auth");
                    Class authenticationHandler = world.newClass("AuthenticationHandler", auth);
                    notGeneratedClasses ~= authenticationHandler;

                    Class authenticationResponse = world.newClass("AuthenticationResponse", auth);
                    notGeneratedClasses ~= authenticationResponse;

                    Class spotifyAuthenticationConfig = world.newClass("spotifyAuthenticationConfig", auth);
                    notGeneratedClasses ~= spotifyAuthenticationConfig;

                    Class spotifyAuthRestApi = world.newClass("SpotifyAuthRestApi");
                    notGeneratedInterfaces ~= spotifyAuthRestApi;

                Component metadata = spotify.newSubComponent("metadata");
                    Class multipleTracksMetadata = world.newClass("MultipleTracksMetadata", metadata);
                    notGeneratedClasses ~= multipleTracksMetadata;

                    Class spotifyMetadataConfig = world.newClass("SpotifyMetadataConfig", metadata);
                    notGeneratedClasses ~= spotifyMetadataConfig;

                    Class spotifyTrackMetaData = world.newClass("SpotifyTrackMetaData", metadata);
                    notGeneratedClasses ~= spotifyTrackMetaData;

                    Class trackMetaDataRestApi = world.newClass("TrackMetadataRestApi", metadata);
                    notGeneratedInterfaces ~= trackMetaDataRestApi;
    //add members
    addMembers(world, protectedMemberVariables, abstractMemberFunctions);

    //modifications of entities
    notGeneratedClasses.modifyElements!(Class, Class function(Class))([&setDoNotGenerateFlagToYes!(Class), &setProtectionToJavaPublic!(Class), &setContainerTypeToJavaClass!(Class), &setModelTypeNameAsJavaClassName!(Class), &addModifierAbstract!(Class)]);

    generatedClasses.modifyElements!(Class, Class function(Class))([&setDoNotGenerateFlagToNo!(Class), &setProtectionToJavaPublic!(Class), &setContainerTypeToJavaClass!(Class), &setModelTypeNameAsJavaClassName!(Class), &addModifierAbstract!(Class)]);

    notGeneratedInterfaces.modifyElements!(Class, Class function(Class))([&setDoNotGenerateFlagToYes!(Class), &setProtectionToJavaPublic!(Class), &setContainerTypeToJavaInterface!(Class), &setModelTypeNameAsJavaClassName!(Class)]);

    generatedInterfaces.modifyElements!(Class, Class function(Class))([&setDoNotGenerateFlagToNo!(Class), &setProtectionToJavaPublic!(Class), &setContainerTypeToJavaInterface!(Class), &setModelTypeNameAsJavaClassName!(Class)]);

    generatedEnums.modifyElements!(Enum, Enum function(Enum))([&setDoNotGenerateFlagToNo!(Enum), &setProtectionToJavaPublic!(Enum), &setModelTypeNameAsJavaClassName!(Enum)]);

    abstractMemberFunctions.modifyElements!(MemberFunction, MemberFunction function(MemberFunction))([&addModifierAbstract!(MemberFunction), &setProtectionToJavaPublic!(MemberFunction)]);

    protectedMemberVariables.modifyElements!(MemberVariable, MemberVariable function(MemberVariable))([&setProtectionToJavaProtected!(MemberVariable)]);
}

void addMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    addRepositoryServiceMembers(world, protectedMemberVariables, abstractMemberFunctions);
}

void addRepositoryServiceMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class repositoryService = world.getClass("RepositoryService");

    MemberFunction saveSongSample = repositoryService.newMemberFunction("saveSongSample");
    saveSongSample.returnType = world.getType("Void");
    saveSongSample.addParameter("age", world.getType("Int"));
    saveSongSample.addParameter("fitnessLevel", world.getType("Int"));
    saveSongSample.addParameter("gender", world.getType("Int"));
    saveSongSample.addParameter("lastSongId", world.getType("String"));
    saveSongSample.addParameter("penultimateSongId", world.getType("String"));
    saveSongSample.addParameter("speedDuringLastSong", world.getType("Double"));
    saveSongSample.addParameter("speedDuringPenultimateSong", world.getType("Double"));
    saveSongSample.addParameter("desiredSpeedDuringLastSong", world.getType("Double"));
    saveSongSample.addParameter("desiredSpeedDuringPenultimateSong", world.getType("Double"));
    saveSongSample.addParameter("desiredSpeedDuringNextInterval", world.getType("Double"));
    saveSongSample.addParameter("songsNotPlayedYet", world.getType("String[]"));
    abstractMemberFunctions ~= saveSongSample;

    MemberFunction saveSongSamples = repositoryService.newMemberFunction("saveSongSamples");
    saveSongSamples.returnType = world.getType("Void");
    saveSongSamples.addParameter("songSamples", world.getType("List<SongSample>"));
    abstractMemberFunctions ~= saveSongSamples;

    MemberFunction getNextSong = repositoryService.newMemberFunction("getNextSong");
    getNextSong.returnType = world.getType("NextSong");
    getNextSong.addParameter("songsNotPlayedYet", world.getType("String[]"));
    getNextSong.addParameter("currentSongId", world.getType("String"));
    getNextSong.addParameter("age", world.getType("Int"));
    getNextSong.addParameter("gender", world.getType("Int"));
    getNextSong.addParameter("fitnessLevel", world.getType("Int"));
    getNextSong.addParameter("desiredSpeedDuringLastSong", world.getType("Double"));
    getNextSong.addParameter("speedDuringLastSong", world.getType("Double"));
    getNextSong.addParameter("speedForecast", world.getType("Double"));
    abstractMemberFunctions ~= getNextSong;

}

void addExternalTypes(ref TheWorld world){
    Type list_SongSample_ = world.newType("List<SongSample>");
    list_SongSample_.typeToLanguage["Java"] = "List<SongSample>";

    Type string_array = world.newType("String[]");
    string_array.typeToLanguage["Java"] = "String[]";
}
