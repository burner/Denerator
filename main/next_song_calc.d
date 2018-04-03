module next_song_calc;

import std.stdio;
import next_song_calc;
import model;
import predefined.types.user;
import predefined.types.group;
import generator.java;

void nextSongCalcModel(ref TheWorld world){
    auto world = new TheWorld("World");

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
    SoftwareSystem nextSongCalculationSystem = world.newSoftwareSystem("Next Song Calculation System");

    Container binarySearchTreeNextSongCalculationSystem = nextSongCalculationSystem.newContainer("BinarySearchTreeNextSongCalculationSystem");
    binarySearchTreeNextSongCalculationSystem.technology = "Java";

    Component de = binarySearchTreeNextSongCalculationSystem.newComponent("de");
    Component uol = de.newSubComponent("uol");
    Component smtrain = uol.newSubComponent("smtrain");

    Component next_song_calculation_system = smtrain.newSubComponent("next_song_calculation_system");
        Class repositoryService = world.newClass("RepositoryService", repository);
        generatedClasses ~= repositoryService;

        Component next_song_api = next_song_calculation_system.newSubComponent("next_song_api");
            Class nextSong = world.newClass("NextSong");
            notGeneratedClasses ~= nextSong;

            Class nextSongCalculationController = .newClass("nextSongCalculationController", next_song_api);
            notGeneratedClasses ~= nextSongCalculationController;

        Component repository = next_song_calculation_system.newSubComponent("repository");

            Component database = repository.newSubComponent("database");
                Class databaseConfig = world.newClass("DatabaseConfig", database);
                notGeneratedClasses ~= databaseConfig;

                Class songSample = world.newClass("SongSample", database);
                notGeneratedClasses ~= songSample;

                Class songSampleRepository = world.newClass("songSampleRepository", database);
                notGeneratedInterfaces ~= songSampleRepository;

                Class trackMetaData = world.newClass("TrackMetaData", database);
                notGeneratedClasses ~= trackMetaData;

                Class trackMetaDataRepository = world.newClass("trackMetaDataRepository", database);
                notGeneratedInterfaces ~= trackMetaDataRepository;

            Component song_recommendation = repository.newSubComponent("song_recommendation");
                Class songRecommendationAttributes = world.newClass("SongRecommendationAttributes", song_recommendation);
                notGeneratedClasses ~= songRecommendationAttributes;

                Class songRecommendationConfig = world.newClass("CongRecommendationConfig", song_recommendation);
                notGeneratedClasses ~= songRecommendationConfig;

                Class songRecommendationRestApi = world.newClass("SongRecommendationRestApi", song_recommendation);
                notGeneratedInterfaces ~= songRecommendationRestApi;

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

                    Class trackMetaData = world.newClass("TrackMetaData", metadata);
                    notGeneratedClasses ~= trackMetaData;

                    Class trackMetaDataRestApi = world.newClass("TrackMetadataRestApi", metadata);
                    notGeneratedInterfaces ~= trackMetaDataRestApi;





}
