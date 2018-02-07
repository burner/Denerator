import std.stdio;

import std.stdio : writeln;
import std.typecons;
import std.experimental.logger;
import containers.hashmap;

import model;
import duplicator;
import generator.graphviz;
import generator.mysql;
import generator.vibed;
import generator.angular;
import predefined.types.user;
import predefined.types.group;
import predefined.types.address;
import predefined.types.basictypes;
import predefined.ctrl.userctrl;

import predefined.angular.component;

class NoTimeLogger : Logger {
	import std.stdio : writefln;
    this(LogLevel lv) @safe {
        super(lv);
    }

    override void writeLogMsg(ref LogEntry payload) {
		import std.string : lastIndexOf;
		auto i = payload.file.lastIndexOf("/");
		string f = payload.file;
		if(i != -1) {
			f = f[i+1 .. $];
		}
		writefln("%s:%s | %s", f, payload.line, payload.msg);
    }
}

void main() {
	sharedLog = new NoTimeLogger(LogLevel.all);

	bool ret;
	version(unittest) {
		ret = true;
	}
	logf("%s", ret);
	if(!ret) appModel();
}

void appModel(){
    import generator.java;

    //Classes container for peroforming operations on all classes that need to be generated
    Class[] generatedClasses;

    Class[] notGeneratedClasses;

    Class[] generatedInterfaces;

    Enum[] generatedEnums;

    MemberFunction[] abstractMemberFunctions;

    MemberVariable[] protectedMemberVariables;

    MemberVariable[] beanMemberVariable;

    //Basic setup
    auto world = new TheWorld("World");
    addBasicTypes(world);
    addExternalTypes(world);
    Type voidType = world.getType("Void");

    //System context level
    Actor runner = world.newActor("Runner");
    auto runningApplication = world.newSoftwareSystem("Running Application");
    world.newConnection("Uses", runner, runningApplication);

    //Container level
    auto app = runningApplication.newContainer("App");
    app.technology = "Java";

    //Component level
    //user interface
    auto degenerator = app.newComponent("degenerator");
    auto de = degenerator.newSubComponent("de");
    auto uol = de.newSubComponent("uol");
    auto smtrain = uol.newSubComponent("smtrain");

    auto domain_smtrain = smtrain.newSubComponent("domain");

        Class mediaEntity = world.newClass("MediaEntity", domain_smtrain);
        generatedClasses ~= mediaEntity;

        Class planningEntity = world.newClass("PlanningEntity", domain_smtrain);
        generatedClasses ~= planningEntity;

        Class playlistBean = world.newClass("PlaylistBean", domain_smtrain);
        generatedClasses ~= playlistBean;

        Class workoutElementBean = world.newClass("WorkoutElementBean", domain_smtrain);
        generatedClasses ~= workoutElementBean;

    //repository
    auto repository_smtrain = smtrain.newSubComponent("repository");
        auto datasource_repository_smtrain = repository_smtrain.newSubComponent("datasource");

            Class mediaDataSource = world.newClass("MediaDataSource", datasource_repository_smtrain);
            generatedInterfaces ~= mediaDataSource;

            auto spotify_datasource_repository_smtrain = datasource_repository_smtrain.newSubComponent("spotify");

                auto rest_spotify_datasource_repository_smtrain = spotify_datasource_repository_smtrain.newSubComponent("rest");
                auto beans_rest_spotify_datasource_repository_smtrain = rest_spotify_datasource_repository_smtrain.newSubComponent("beans");

                    Class albumBean = world.newClass("AlbumBean", beans_rest_spotify_datasource_repository_smtrain);
                    generatedClasses ~= albumBean;

                    Class artistBean = world.newClass("ArtistBean", beans_rest_spotify_datasource_repository_smtrain);
                    generatedClasses ~= artistBean;

                    Class imageBean = world.newClass("ImageBean", beans_rest_spotify_datasource_repository_smtrain);
                    generatedClasses ~= imageBean;

                    //TODO paging Bean

                    Class spotifyPlaylistBean = world.newClass("SpotifyPlaylistBean", beans_rest_spotify_datasource_repository_smtrain);
                    generatedClasses ~= spotifyPlaylistBean;

                    Class playlistTrackBean = world.newClass("PlaylistTrackBean", beans_rest_spotify_datasource_repository_smtrain);
                    generatedClasses ~= playlistTrackBean;

                    Class trackBean = world.newClass("TrackBean", beans_rest_spotify_datasource_repository_smtrain);
                    generatedClasses ~= trackBean;

                    Class tracksBean = world.newClass("TracksBean", beans_rest_spotify_datasource_repository_smtrain);
                    generatedClasses ~= tracksBean;
    //service
    auto service_smtrain = smtrain.newSubComponent("service");

        Class locationService = world.newClass("LocationService", service_smtrain);
        generatedInterfaces ~= locationService;

        Class runningService = world.newClass("RunningService", service_smtrain);
        generatedInterfaces ~= runningService;

        Class spotifyPlayerService = world.newClass("SpotifyPlayerService", service_smtrain);
        generatedClasses ~= spotifyPlayerService;

        Class playerService = world.newClass("PlayerService", service_smtrain);
        generatedInterfaces ~= playerService;

    //usecase
    auto useCase_smtrain = smtrain.newSubComponent("use_case");

        auto planTraining_useCase_smtrain = useCase_smtrain.newSubComponent("plan_training");

            Class persistTrainingPlanCase = world.newClass("PersistTrainingPlanCase", planTraining_useCase_smtrain);
            generatedClasses ~= persistTrainingPlanCase;

        auto player_useCase_smtrain = useCase_smtrain.newSubComponent("player");

            Class initializeMediaDataSourceCase = world.newClass("InitializeMediaDataSourceCase", player_useCase_smtrain);
            generatedClasses ~= initializeMediaDataSourceCase;

            Class playlistsCase = world.newClass("PlaylistsCase", player_useCase_smtrain);
            generatedClasses ~= playlistsCase;

    auto userInterface = smtrain.newSubComponent("user_interface");

        //contracts
        auto contract_UserInterface = userInterface.newSubComponent("contract");
            auto planning_Contract_UserInterface = contract_UserInterface.newSubComponent("planning");

                Class intervalPlanningContractPresenter = world.newClass("IntervalPlanningContractPresenter", planning_Contract_UserInterface);
                generatedInterfaces ~= intervalPlanningContractPresenter;

                Class intervalPlanningContractView = world.newClass("IntervalPlanningContractView", planning_Contract_UserInterface);
                generatedInterfaces ~= intervalPlanningContractView;

                Class longrunPlanningContractPresenter = world.newClass("LongrunPlanningContractPresenter", planning_Contract_UserInterface);
                generatedInterfaces ~= longrunPlanningContractPresenter;

                Class longrunPlanningContractView = world.newClass("LongrunPlanningContractView", planning_Contract_UserInterface);
                generatedInterfaces ~= longrunPlanningContractView;

                Class planWorkoutContractPresenter = world.newClass("PlanWorkoutContractPresenter", planning_Contract_UserInterface);
                generatedInterfaces ~= planWorkoutContractPresenter;

                Class planWorkoutContractView = world.newClass("PlanWorkoutContractView", planning_Contract_UserInterface);
                generatedInterfaces ~= planWorkoutContractView;

                Class runningContractPresenter = world.newClass("RunningContractPresenter", planning_Contract_UserInterface);
                generatedInterfaces ~= runningContractPresenter;

                Class runningContractView = world.newClass("RunningContractView", planning_Contract_UserInterface);
                generatedInterfaces ~= runningContractView;

                Class selectPlaylistContractPresenter = world.newClass("SelectPlaylistContractPresenter", planning_Contract_UserInterface);
                generatedInterfaces ~= selectPlaylistContractPresenter;

                Class selectPlaylistContractView = world.newClass("SelectPlaylistContractView", planning_Contract_UserInterface);
                generatedInterfaces ~= selectPlaylistContractView;

                Class waitForGpsContractPresenter = world.newClass("WaitForGpsContractPresenter", planning_Contract_UserInterface);
                generatedInterfaces ~= waitForGpsContractPresenter;

                Class waitForGpsContractView = world.newClass("WaitForGpsContractView", planning_Contract_UserInterface);
                generatedInterfaces ~=waitForGpsContractView;

            auto running_Contract_UserInterface = contract_UserInterface.newSubComponent("running");

                Class fitnessContractPresenter = world.newClass("FitnessContractPresenter", running_Contract_UserInterface);
                generatedInterfaces ~= fitnessContractPresenter;

                Class fitnessContractView = world.newClass("FitnessContractView", running_Contract_UserInterface);
                generatedInterfaces ~= fitnessContractView;

                Class lapContractPresenter = world.newClass("LapContractPresenter", running_Contract_UserInterface);
                generatedInterfaces ~= lapContractPresenter;

                Class lapContractView = world.newClass("LapContractView", running_Contract_UserInterface);
                generatedInterfaces ~= lapContractView;

                Class playlistContractPresenter = world.newClass("PlaylistContractPresenter", running_Contract_UserInterface);
                generatedInterfaces ~= playlistContractPresenter;

                Class playlistContractView = world.newClass("PlaylistContractView", running_Contract_UserInterface);
                generatedInterfaces ~= playlistContractView;

                Class stopWatchContractPresenter = world.newClass("StopWatchContractPresenter", running_Contract_UserInterface);
                generatedInterfaces ~= stopWatchContractPresenter;

                Class stopWatchContractView = world.newClass("StopWatchContractView", running_Contract_UserInterface);
                generatedInterfaces ~= stopWatchContractView;

            auto start_Contract_UserInterface = contract_UserInterface.newSubComponent("start");

                Class startingDisplayContractView = world.newClass("StartingDisplayContractView", start_Contract_UserInterface);
                generatedInterfaces ~= startingDisplayContractView;

                Class startingDisplayContractPresenter = world.newClass("StartingDisplayContractPresenter", start_Contract_UserInterface);
                generatedInterfaces ~= startingDisplayContractPresenter;

        //facades
        auto facade_UserInterface = userInterface.newSubComponent("facade");

            Class fitnessDataFacade = world.newClass("FitnessDataFacade", facade_UserInterface);
            generatedInterfaces ~= fitnessDataFacade;

            Class playlistDataFacade = world.newClass("PlaylistDataFacade", facade_UserInterface);
            generatedInterfaces ~= playlistDataFacade;

            Class stopWatchStateFacade = world.newClass("StopwatchStateFacade", facade_UserInterface);
            generatedInterfaces ~= stopWatchStateFacade;

                //Enum stopwatchState = world.newEnum("StopwatchState", stopWatchStateFacade);
                //stopwatchState.addEnumConstant("STARTED");
                //stopwatchState.addEnumConstant("PAUSED");
                //stopwatchState.addEnumConstant("ENDED");

        //models
        auto model_UserInterface = userInterface.newSubComponent("model");

                Class intervalPlanningBean_Model_UserInterface = world.newClass("IntervalPlanningBean", model_UserInterface);
                generatedClasses ~= intervalPlanningBean_Model_UserInterface;

                Class lapBean_Model_UserInterface = world.newClass("LapBean", model_UserInterface);
                generatedClasses ~= lapBean_Model_UserInterface;

                Class longrunPlanningBean_Model_UserInterface = world.newClass("LongrunPlanningBean", model_UserInterface);
                generatedClasses ~= longrunPlanningBean_Model_UserInterface;

                Class selectPlaylistImageBean_Model_UserInterface = world.newClass("SelectPlaylistImageBean", model_UserInterface);
                generatedClasses ~= selectPlaylistImageBean_Model_UserInterface;

                Class songBean_Model_UserInterface = world.newClass("SongBean", model_UserInterface);
                generatedClasses ~= songBean_Model_UserInterface;

        //presenters
        //planning presenters
        auto presenter_UserInteface = userInterface.newSubComponent("presenter");
            auto planning_Presenter_UserInterface = presenter_UserInteface.newSubComponent("planning");
                Class intervalPlanningPresenter = world.newClass("IntervalPlanningPresenter", planning_Presenter_UserInterface);
                generatedClasses ~= intervalPlanningPresenter;

                Class longrunPlanningPresenter = world.newClass("LongrunPlanningPresenter", planning_Presenter_UserInterface);
                generatedClasses ~= longrunPlanningPresenter;

                Class planWorkoutPresenter = world.newClass("PlanWorkoutPresenter", planning_Presenter_UserInterface);
                generatedClasses ~= planWorkoutPresenter;

                Enum homeButtonClickResult = world.newEnum("HomeButtonClickResult", planning_Presenter_UserInterface);
                homeButtonClickResult.addEnumConstant("PROCESSED");
                homeButtonClickResult.addEnumConstant("NOT_PROCESSED");
                homeButtonClickResult.addEnumConstant("PROCESS_BY_SUPER");
                generatedEnums ~= homeButtonClickResult;

                Enum activeFragment = world.newEnum("ActiveFragment", planning_Presenter_UserInterface);
                Constructor activeFragmentConstructor = activeFragment.setConstructor();
                MemberVariable activeFragmentConstructorStationParameter = activeFragmentConstructor.addParameter("station", world.getType("Int"));
                activeFragmentConstructorStationParameter.protection["Java"] = "public";
                EnumConstant selectTrainingModeConstant = activeFragment.addEnumConstant("SELECT_TRAINING_MODE");
                selectTrainingModeConstant.setValues(["0"]);
                EnumConstant configureTrainingModeConstant = activeFragment.addEnumConstant("CONFIGURE_TRAINING");
                configureTrainingModeConstant.setValues(["1"]);
                EnumConstant selectPlaylistModeConstant = activeFragment.addEnumConstant("SELECT_PLAYLIST");
                selectPlaylistModeConstant.setValues(["2"]);
                EnumConstant waitForGpsModeConstant = activeFragment.addEnumConstant("WAIT_FOR_GPS");
                waitForGpsModeConstant.setValues(["3"]);
                generatedEnums ~= activeFragment;

                Enum trainingMode = world.newEnum("TrainingMode", planning_Presenter_UserInterface);
                trainingMode.addEnumConstant("TRAINING_INTERVAL");
                trainingMode.addEnumConstant("TRAINING_LONGRUN");
                generatedEnums ~= trainingMode;

                Class selectPlaylistPresenter = world.newClass("SelectPlaylistPresenter", planning_Presenter_UserInterface);
                generatedClasses ~= selectPlaylistPresenter;

                Class waitForGpsPresenter = world.newClass("WaitForGpsPresenter", planning_Presenter_UserInterface);
                generatedClasses ~= waitForGpsPresenter;

            auto running_Presenter_UserInteface = presenter_UserInteface.newSubComponent("running");

                Class fitnessPresenter = world.newClass("FitnessPresenter", running_Presenter_UserInteface);
                generatedClasses ~= fitnessPresenter;

                Class lapPresenter = world.newClass("LapPresenter", running_Presenter_UserInteface);
                generatedClasses ~= lapPresenter;

                Class playlistPresenter = world.newClass("PlaylistPresenter", running_Presenter_UserInteface);
                generatedClasses ~= playlistPresenter;

                Class runningPresenter = world.newClass("RunningPresenter", running_Presenter_UserInteface);
                generatedClasses ~= runningPresenter;

                Class stopWatchPresenter = world.newClass("StopWatchPresenter", running_Presenter_UserInteface);
                generatedClasses ~= stopWatchPresenter;

                    Class stopWatchPresenter_IntervalCounter = world.newClass("IntervalCounter", stopWatchPresenter);
                    generatedClasses ~= stopWatchPresenter_IntervalCounter;

                    Class stopWatchPresenter_State = world.newClass("State", stopWatchPresenter);
                    generatedInterfaces ~= stopWatchPresenter_State;

            auto start_Presenter_UserInteface = presenter_UserInteface.newSubComponent("start");

                Class startingDisplayPresenter = world.newClass("StartingDisplayPresenter", start_Presenter_UserInteface);
                generatedClasses ~= startingDisplayPresenter;

                Enum fragmentCommand = world.newEnum("FragmentCommand", start_Presenter_UserInteface);
                EnumConstant clickRecord = fragmentCommand.addEnumConstant("CLICK_RECORD");
                EnumConstant clickReview = fragmentCommand.addEnumConstant("CLICK_REVIEW");
                EnumConstant clickSettingsBack = fragmentCommand.addEnumConstant("CLICK_SETTINGS_BACK");
                EnumConstant clickSettings = fragmentCommand.addEnumConstant("CLICK_SETTINGS");
                generatedEnums ~= fragmentCommand;

    auto view_UserInterface = userInterface.newSubComponent("view");

    //components containing not generated classes

    //not generated classes
    //planning
    auto planning_View_UserInterface = view_UserInterface.newSubComponent("planning");
        Class planWorkoutActivity_Planning_View_UserInterface = world.newClass("PlanWorkoutActivity", planning_View_UserInterface);
        notGeneratedClasses ~= planWorkoutActivity_Planning_View_UserInterface;

        auto fragment_Planning_View_UserInterface = planning_View_UserInterface.newSubComponent("fragment");

            Class scheduleFragment_Planning_View_UserInterface = world.newClass("ScheduleFragment", fragment_Planning_View_UserInterface);
            notGeneratedClasses ~= scheduleFragment_Planning_View_UserInterface;

            Class selectTrainingFragment_Planning_View_UserInterface = world.newClass("SelectTrainingFragment", fragment_Planning_View_UserInterface);
            notGeneratedClasses ~= selectTrainingFragment_Planning_View_UserInterface;

            Class waitForGpsFragment_Planning_View_UserInterface = world.newClass("WaitForGpsFragment", fragment_Planning_View_UserInterface);
            notGeneratedClasses ~= waitForGpsFragment_Planning_View_UserInterface;

            auto selectPlaylist_Fragment_Planning_View_UserInterface = fragment_Planning_View_UserInterface.newSubComponent("select_playlist");

                Class selectPlaylistAdapter_SelectPlaylist_Fragment_Planning_View_UserInterface = world.newClass("SelectPlaylistAdapter", selectPlaylist_Fragment_Planning_View_UserInterface);
                notGeneratedClasses ~= selectPlaylistAdapter_SelectPlaylist_Fragment_Planning_View_UserInterface;

                Class selectPlaylistFragment_SelectPlaylist_Fragment_Planning_View_UserInterface = world.newClass("SelectPlaylistFragment", selectPlaylist_Fragment_Planning_View_UserInterface);
                notGeneratedClasses ~= selectPlaylistFragment_SelectPlaylist_Fragment_Planning_View_UserInterface;

                Class selectPlaylistViewHolder_SlectPlaylist_Fragment_Planning_View_UserInterface = world.newClass("SelectPlaylistViewHolder", selectPlaylist_Fragment_Planning_View_UserInterface);
                notGeneratedClasses ~= selectPlaylistViewHolder_SlectPlaylist_Fragment_Planning_View_UserInterface;

            auto trainingTypeInterval_Fragment_Planning_View_UserInterface = fragment_Planning_View_UserInterface.newSubComponent("training_type_interval");

                Class configureIntervalFragment_TrainingTypeInterval_Fragment_Planning_View_UserInterface = world.newClass("ConfigureIntervalFragment", trainingTypeInterval_Fragment_Planning_View_UserInterface);
                notGeneratedClasses ~= configureIntervalFragment_TrainingTypeInterval_Fragment_Planning_View_UserInterface;

                Class intervalPlanningAdapter_TrainingTypeInterval_Fragment_Planning_View_UserInterface = world.newClass("IntervalPlanningAdapter", trainingTypeInterval_Fragment_Planning_View_UserInterface);
                notGeneratedClasses ~= intervalPlanningAdapter_TrainingTypeInterval_Fragment_Planning_View_UserInterface;

                Class intervalPlanningFragment_TrainingTypeInterval_Fragment_Planning_View_UserInterface = world.newClass("IntervalPlanningFragment", trainingTypeInterval_Fragment_Planning_View_UserInterface);
                notGeneratedClasses ~= intervalPlanningFragment_TrainingTypeInterval_Fragment_Planning_View_UserInterface;

                Class intervalPlanningViewHolder_TrainingTypeInterval_Fragment_Planning_View_UserInterface = world.newClass("IntervalPlanningViewHolder", trainingTypeInterval_Fragment_Planning_View_UserInterface);
                notGeneratedClasses ~= intervalPlanningViewHolder_TrainingTypeInterval_Fragment_Planning_View_UserInterface;

                Class scrollAwareFABBehavior_TrainingTypeInterval_Fragment_Planning_View_UserInterface = world.newClass("ScrollAwareFABBehavior", trainingTypeInterval_Fragment_Planning_View_UserInterface);
                notGeneratedClasses ~= scrollAwareFABBehavior_TrainingTypeInterval_Fragment_Planning_View_UserInterface;

            auto trainingTypeLongrun_Fragment_Planning_View_UserInterface = fragment_Planning_View_UserInterface.newSubComponent("training_type_longrun");

                Class longrunPlanningFragment_TrainingTypeLongrun_Fragment_Planning_View_UserInterface = world.newClass("LongrunPlanningFragment", trainingTypeLongrun_Fragment_Planning_View_UserInterface);
                notGeneratedClasses ~= longrunPlanningFragment_TrainingTypeLongrun_Fragment_Planning_View_UserInterface;

    //review
    auto review_View_UserInterface = view_UserInterface.newSubComponent("review");

        auto basic_Review_View_UserInterface = review_View_UserInterface.newSubComponent("basic");

            Class listElementViewHolder_Basic_Review_View_UserInterface = world.newClass("ListElementViewHolder", basic_Review_View_UserInterface);
            notGeneratedClasses ~= listElementViewHolder_Basic_Review_View_UserInterface;

            Class reviewActivity_Basic_Review_View_UserInterface = world.newClass("ReviewActivity", basic_Review_View_UserInterface);
            notGeneratedClasses ~= reviewActivity_Basic_Review_View_UserInterface;

            Class reviewElementAdapter_Basic_Review_View_UserInterface = world.newClass("ReviewElementAdapter", basic_Review_View_UserInterface);
            notGeneratedClasses ~= reviewElementAdapter_Basic_Review_View_UserInterface;

            Class reviewElementBean_Basic_Review_View_UserInterface = world.newClass("ReviewElementBean", basic_Review_View_UserInterface);
            notGeneratedClasses ~= reviewElementBean_Basic_Review_View_UserInterface;

    auto detail_Review_View_UserInterface = review_View_UserInterface.newSubComponent("detail");
        Class detailReview_detail_Review_View_UserInterface = world.newClass("DetailReview");
        notGeneratedClasses ~= detailReview_detail_Review_View_UserInterface;

    //running
    auto running_View_UserInterface = view_UserInterface.newSubComponent("running");

        Class runningActivity_running_View_UserInterface = world.newClass("RunningActivity");
        notGeneratedClasses ~= runningActivity_running_View_UserInterface;

        auto fitnessData_Running_View_UserInterface = running_View_UserInterface.newSubComponent("fitness_data");
            Class fitnessFragment_FitnessData_Running_View_UserInterface = world.newClass("FitnessFragment", fitnessData_Running_View_UserInterface);
            notGeneratedClasses ~= fitnessFragment_FitnessData_Running_View_UserInterface;

            auto mediaPlayer_running_View_UserInterface = running_View_UserInterface.newSubComponent("media_player");
            Class nowPlayingFragment_MediaPlayer_running_View_UserInterface = world.newClass("NowPlayingFragment", mediaPlayer_running_View_UserInterface);
            notGeneratedClasses ~= nowPlayingFragment_MediaPlayer_running_View_UserInterface;

            Class playlistActivity_MediaPlayer_running_View_UserInterface = world.newClass("PlaylistActivity", mediaPlayer_running_View_UserInterface);
            notGeneratedClasses ~= playlistActivity_MediaPlayer_running_View_UserInterface;

            Class playlistFragment_MediaPlayer_running_View_UserInterface = world.newClass("PlaylistFragment", mediaPlayer_running_View_UserInterface);
            notGeneratedClasses ~= playlistFragment_MediaPlayer_running_View_UserInterface;

            Class playlistSongAdapter_MediaPlayer_running_View_UserInterface = world.newClass("PlaylistSongAdapter", mediaPlayer_running_View_UserInterface);
            notGeneratedClasses ~= playlistSongAdapter_MediaPlayer_running_View_UserInterface;

            Class viewHoler_MediaPlayer_running_View_UserInterface = world.newClass("ViewHolder", mediaPlayer_running_View_UserInterface);
            notGeneratedClasses ~= viewHoler_MediaPlayer_running_View_UserInterface;

            viewHoler_MediaPlayer_running_View_UserInterface.typeToLanguage["Java"] = viewHoler_MediaPlayer_running_View_UserInterface.name;
            notGeneratedClasses ~= viewHoler_MediaPlayer_running_View_UserInterface;

    auto navigation_Running_View_UserInterface = running_View_UserInterface.newSubComponent("navigation");
    Class bottomNavigationFragment_Navigation_Running_View_UserInterface = world.newClass("BottomNavigationFragment", navigation_Running_View_UserInterface);
    notGeneratedClasses ~= bottomNavigationFragment_Navigation_Running_View_UserInterface;

    auto stopwatch_Running_View_UserInterface = running_View_UserInterface.newSubComponent("stopwatch");
        Class StopWatchFragment_Stopwatch_Running_View_UserInterface = world.newClass("StopWatchFragment", stopwatch_Running_View_UserInterface);
        notGeneratedClasses ~= StopWatchFragment_Stopwatch_Running_View_UserInterface;

        auto clock_Stopwatch_Running_View_UserInterface = stopwatch_Running_View_UserInterface.newSubComponent("clock");
        Class circle_Clock_Stopwatch_Running_View_UserInterface = world.newClass("Circle", clock_Stopwatch_Running_View_UserInterface);
        notGeneratedClasses ~= circle_Clock_Stopwatch_Running_View_UserInterface;

        auto lap_Stopwatch_Running_View_UserInterface = stopwatch_Running_View_UserInterface.newSubComponent("lap");
        Class lapAdapter_Lap_Stopwatch_Running_View_UserInterface = world.newClass("LapAdapter", lap_Stopwatch_Running_View_UserInterface);
        notGeneratedClasses ~= lapAdapter_Lap_Stopwatch_Running_View_UserInterface;

        Class lapFragment_Lap_Stopwatch_Running_View_UserInterface = world.newClass("LapFragment", lap_Stopwatch_Running_View_UserInterface);
        notGeneratedClasses ~= lapFragment_Lap_Stopwatch_Running_View_UserInterface;

        Class lapViewHolder_Lap_Stopwatch_Running_View_UserInterface = world.newClass("LapViewHolder", lap_Stopwatch_Running_View_UserInterface);
        notGeneratedClasses ~= lapViewHolder_Lap_Stopwatch_Running_View_UserInterface;

    //start
    auto start_View_UserInterface = view_UserInterface.newSubComponent("start");

        Class startingDisplayActivity_Start_View_UserInterface = world.newClass("StartingDisplayActivity", start_View_UserInterface);
        notGeneratedClasses ~= startingDisplayActivity_Start_View_UserInterface;

        Class startingDisplayOptionsFragment_Start_View_UserInterface = world.newClass("StartingDisplayOptionsFragment", start_View_UserInterface);
        notGeneratedClasses ~= startingDisplayOptionsFragment_Start_View_UserInterface;

        Class startingDisplayPreferencesFragment_Start_View_UserInterface = world.newClass("StartingDisplayPreferencesFragment", start_View_UserInterface);
        notGeneratedClasses ~= startingDisplayPreferencesFragment_Start_View_UserInterface;

    //members
    addCompositions(world);
    addAggregations(world);
    generateMembers(world, protectedMemberVariables, abstractMemberFunctions);

    //generalizations
    generateGeneralizesRelationships(world);

    //implementations
    generateImplementsRelationships(world);

    //modifications of entities
    notGeneratedClasses.modifyElements!(Class, Class function(Class))([&setDoNotGenerateFlagToYes!(Class), &setProtectionToJavaPublic!(Class), &setContainerTypeToJavaClass!(Class), &setModelTypeNameAsJavaClassName!(Class), &addModifierAbstract!(Class)]);

    generatedClasses.modifyElements!(Class, Class function(Class))([&setDoNotGenerateFlagToNo!(Class), &setProtectionToJavaPublic!(Class), &setContainerTypeToJavaClass!(Class), &setModelTypeNameAsJavaClassName!(Class), &addModifierAbstract!(Class)]);

    generatedInterfaces.modifyElements!(Class, Class function(Class))([&setDoNotGenerateFlagToNo!(Class), &setProtectionToJavaPublic!(Class), &setContainerTypeToJavaInterface!(Class), &setModelTypeNameAsJavaClassName!(Class)]);

    generatedEnums.modifyElements!(Enum, Enum function(Enum))([&setDoNotGenerateFlagToNo!(Enum), &setProtectionToJavaPublic!(Enum), &setModelTypeNameAsJavaClassName!(Enum)]);

    abstractMemberFunctions.modifyElements!(MemberFunction, MemberFunction function(MemberFunction))([&addModifierAbstract!(MemberFunction), &setProtectionToJavaPublic!(MemberFunction)]);

    protectedMemberVariables.modifyElements!(MemberVariable, MemberVariable function(MemberVariable))([&setProtectionToJavaProtected!(MemberVariable)]);



    Java java = new Java(world, "C:\\Users\\0step\\Documents\\Uni_Oldenburg\\Maste_Semester_IV\\Masterarbeit\\app\\masterarbeit_app\\app\\src\\main\\java");
    //Java java = new Java(world, "C:\\Users\\0step\\Documents\\Uni_Oldenburg\\Maste_Semester_IV\\Masterarbeit\\app\\generated");
    //Types that are not provided by the genereted classes themselves
    java.newTypeMap["List"] = ["java.util.List"];
    java.newTypeMap["Observable"] = ["io.reactivex.Observable"];
    java.newTypeMap["Subject"] = ["io.reactivex.subjects.Subject"];
    java.newTypeMap["Set"] = ["java.util.Set"];
    java.newTypeMap["Binder"] = ["android.os.Binder"];
    java.newTypeMap["Bitmap"] = ["android.graphics.Bitmap"];
    java.newTypeMap["Pair"] = ["android.support.v4.util.Pair"];
    java.newTypeMap["LocationRequest"] = ["com.google.android.gms.location.LocationRequest"];
    java.newTypeMap["RxLocation"] = ["com.patloew.rxlocation.RxLocation"];
    java.newTypeMap["Consumer"] = ["io.reactivex.functions.Consumer"];
    java.newTypeMap["MenuItem"] = ["android.view.MenuItem"];
    java.newTypeMap["DisposableObserver"] = ["io.reactivex.observers.DisposableObserver"];
    java.newTypeMap["Disposable"] = ["io.reactivex.disposables.Disposable"];
    java.newTypeMap["Date"] = ["java.util.Date"];
    java.newTypeMap["Service"] = ["android.app.Service"];
    java.newTypeMap["ConnectionStateCallback"] = ["com.spotify.sdk.android.player.ConnectionStateCallback"];
    java.newTypeMap["Player.NotificationCallback"] = ["com.spotify.sdk.android.player.Player"];
    java.generate(app);

    //Graphvic gv = new Graphvic(world, "GraphvizOutput");
	//gv.generate();
}

void addCompositions(TheWorld world){
    auto stopWatchPresenter = world.getClass("StopWatchPresenter");
    auto state = world.getClass("State");
    Composition state_StopWatchPresenter_Composition = world.newComposition("State_StopWatchPresenter_Composition", state, stopWatchPresenter);

    auto intervalCounter = world.getClass("IntervalCounter");
    Composition intervalCounter_StopWatchPresenter_Composition = world.newComposition("IntervalCounter_StopWatchPresenter_Composition", intervalCounter, stopWatchPresenter);

}

void addAggregations(TheWorld world){
    auto stopWatchPresenter = world.getClass("StopWatchPresenter");
    auto observable = world.getType("Observable");
    Aggregation observable_StopWatchPresneter_Aggregation = world.newAggregation("Observable_StopWatchPresneter_Aggregation", observable, stopWatchPresenter);
}

void generateMembers(TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    //domain
    addMediaEntityMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addPlaylistBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addPlanningEntityMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addWorkourElementBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);

    //repository
    addMediaDataSourceMembers(world, protectedMemberVariables, abstractMemberFunctions);

    addAlbumBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addArtistBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addImageBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    //TODO add paging bean members
    addSpotifyPlaylistBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addPlaylistTrackBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addTrackBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addTracksBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);

    //service
    addLocationServiceMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addPlayerServiceMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addRunningServiceMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addSpotifyPlayerServiceMembers(world, protectedMemberVariables, abstractMemberFunctions);

    //use cases
    addPersistTrainingPlanCaseMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addInitializeMediaDataSourceCaseMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addPlaylistCaseMembers(world, protectedMemberVariables, abstractMemberFunctions);

    //contracts
    //planning
    addIntervalPlanningContractPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addLongrunPlanningContractPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addPlanWorkoutContractPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addSelectPlaylistContractPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addPlanWorkoutContractViewMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addWaitForGpsContractPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addWaitForGpsContractViewMembers(world, protectedMemberVariables, abstractMemberFunctions);

    //running
    addFitnessContractPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addFitnessContractViewMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addLapContractPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addLapContractViewMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addPlaylistContractPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addPlaylistContractViewMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addStopWatchContractPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addStopWatchContractViewMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addRunningContractPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addRunningContractViewMembers(world, protectedMemberVariables, abstractMemberFunctions);

    //start
    addStartingDisplayContractPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addStartingDisplayContractViewMembers(world, protectedMemberVariables, abstractMemberFunctions);

    //facade
    addFitnessDataFacadeMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addPlaylistDataFacadeMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addStopwatchStateFacadeMembers(world, protectedMemberVariables, abstractMemberFunctions);


    //view beans
    addSelectPlaylistImageBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addIntervalPlanningBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addLapBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addLongrunPlanningBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addSongBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);

    //presenters
    //planning
    addLongrunPlanningPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addIntervalPlanningPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addPlanWorkoutPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addSelectPlaylistPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addWaitForGpsPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addFitnessPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);

    //running
    addLapPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addPlaylistPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addRunningPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addStopWatchPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
        addStopWatchPresenter_IntervalCounterMembers(world, protectedMemberVariables, abstractMemberFunctions);
        addStopWatchPresenter_StateMembers(world, protectedMemberVariables, abstractMemberFunctions);

    //start
    addStartingDisplayPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
}

void addExternalTypes(TheWorld world){
    Type consumer_Pair_String_IntervalPlanningBean__ = world.newType("Consumer<Pair<String,IntervalPlanningBean>>");
    consumer_Pair_String_IntervalPlanningBean__.typeToLanguage["Java"] = "Consumer<Pair<String,IntervalPlanningBean>>";

    Type observable_Double_ = world.newType("Observable<Double>");
    observable_Double_.typeToLanguage["Java"] = "Observable<Double>";

    Type subject_Double_ = world.newType("Subject<Double>");
    subject_Double_.typeToLanguage["Java"] = "Subject<Double>";

    Type consumer_FragmentCommand_ = world.newType("Consumer<FragmentCommand>");
    consumer_FragmentCommand_.typeToLanguage["Java"] = "Consumer<FragmentCommand>";

    Type consumer_Binder_ = world.newType("Consumer<Binder>");
    consumer_Binder_.typeToLanguage["Java"] = "Consumer<Binder>";

    Type list_ExternalUrlBean_ = world.newType("List<ExternalUrlBean>");
    list_ExternalUrlBean_.typeToLanguage["Java"] = "List<ExternalUrlBean>";

    Type list_ImageBean_ = world.newType("List<ImageBean>");
    list_ImageBean_.typeToLanguage["Java"] = "List<ImageBean>";

    Type list_ArtistBean_ = world.newType("List<ArtistBean>");
    list_ArtistBean_.typeToLanguage["Java"] = "List<ArtistBean>";

    Type list_IntervalPlanningBean_ = world.newType("List<IntervalPlanningBean>");
    list_IntervalPlanningBean_.typeToLanguage["Java"] = "List<IntervalPlanningBean>";

    Type observable_SelectPlaylistImageBean_ = world.newType("Observable<SelectPlaylistImageBean>");
    observable_SelectPlaylistImageBean_.typeToLanguage["Java"] = "Observable<SelectPlaylistImageBean>";

    Type set_SelectPlaylistImageBean_ = world.newType("Set<SelectPlaylistImageBean>");
    set_SelectPlaylistImageBean_.typeToLanguage["Java"] = "Set<SelectPlaylistImageBean>";

    Type bitmap = world.newType("Bitmap");
    bitmap.typeToLanguage["Java"] = "Bitmap";

    Type set_PlaylistBean_ = world.newType("Set<PlaylistBean>");
    set_PlaylistBean_.typeToLanguage["Java"] = "Set<PlaylistBean>";

    Type list_WorkoutElementBean_ = world.newType("List<WorkoutElementBean>");
    list_WorkoutElementBean_.typeToLanguage["Java"] = "List<WorkoutElementBean>";

    Type menuItem = world.newType("MenuItem");
    menuItem.typeToLanguage["Java"] = "MenuItem";

    Type observale_SongBean_ = world.newType("Observable<SongBean>");
    observale_SongBean_.typeToLanguage["Java"] = "Observable<SongBean>";

    Type observable = world.newType("Observable");
    observable.typeToLanguage["Java"] = "Observable";

    Type disposableObserver_Long_ = world.newType("DisposableObserver<Long>");
    disposableObserver_Long_.typeToLanguage["Java"] = "DisposableObserver<Long>";

    Type disposable = world.newType("Disposable");
    disposable.typeToLanguage["Java"] = "Disposable";

    Type rxLocation = world.newType("RxLocation");
    rxLocation.typeToLanguage["Java"] = "RxLocation";

    Type locationRequest = world.newType("LocationRequest");
    locationRequest.typeToLanguage["Java"] = "LocationRequest";

    Type service = world.newType("Service");
    service.typeToLanguage["Java"] = "Service";

    Type connectionStateCallback = world.newType("ConnectionStateCallback");
    connectionStateCallback.typeToLanguage["Java"] = "ConnectionStateCallback";

    Type player_NotificationCallback = world.newType("Player.NotificationCallback");
    player_NotificationCallback.typeToLanguage["Java"] = "player_NotificationCallback";

    Type observable_PlaylistBean_ = world.newType("Observable<PlaylistBean>");
    observable_PlaylistBean_.typeToLanguage["Java"] = "Observable<PlaylistBean>";

    Type list_SongBean_ = world.newType("List<SongBean>");
    list_SongBean_.typeToLanguage["Java"] = "List<SongBean>";

}

void generateGeneralizesRelationships(ref TheWorld world){

    //Service
    Type consumer_Binder_ = world.getType("Consumer<Binder>");
    Class runningService = world.getClass("RunningService");
    world.newGeneralization("RunningService_Consumer_Binder__Realization", runningService, consumer_Binder_);

    Class spotifyPlayerService = world.getClass("SpotifyPlayerService");
    Type service = world.getType("Service");
    world.newGeneralization("SpotifyPlayerService_Service_Generalization", spotifyPlayerService, service);


    Class intervalCounter = world.getClass("IntervalCounter");
    Type disposableObserver_Long_ = world.getType("DisposableObserver<Long>");
    world.newGeneralization("intervalCounter_disposableObserver_Long_Generalization", intervalCounter, disposableObserver_Long_);

    Class runningContractPresenter = world.getClass("RunningContractPresenter");
    world.newGeneralization("RunningContractPresenter_Consumer_Binder__Generalization", runningContractPresenter, consumer_Binder_);
}

void generateImplementsRelationships(ref TheWorld world){

    //Services
    Class spotifyPlayerService = world.getClass("SpotifyPlayerService");
    Class playerService = world.getClass("PlayerService");
    world.newRealization("SpotifyPlayerService_PlayerService_Realization", spotifyPlayerService, playerService);

    Type connectionStateCallback = world.getType("ConnectionStateCallback");
    world.newRealization("SpotifyPlayerService_ConnectionStateCallback_Realization", spotifyPlayerService, connectionStateCallback);

    Type player_NotificationCallback = world.getType("Player.NotificationCallback");
    world.newRealization("SpotifyPlayerService_Player.NotificationCallback_Realization", spotifyPlayerService, player_NotificationCallback);

    //User interface
    //planning
    Class intervalPlanningPresenter = world.getClass("IntervalPlanningPresenter");
    Class intervalPlanningContractPresenter = world.getClass("IntervalPlanningContractPresenter");
    world.newRealization("IntervalPlanningPresenter_IntervalPlanningContractPresenter_Realization", intervalPlanningPresenter, intervalPlanningContractPresenter);

    Type consumer_Pair_String_IntervalPlanningBean__ = world.getType("Consumer<Pair<String,IntervalPlanningBean>>");
    world.newRealization("IntervalPlanningPresenter_consumer_Pair_String_IntervalPlanningBean___Realization", intervalPlanningPresenter, consumer_Pair_String_IntervalPlanningBean__);

    Class longrunPlanningPresenter = world.getClass("LongrunPlanningPresenter");
    Class longrunPlanningContractPresenter = world.getClass("LongrunPlanningContractPresenter");
    world.newRealization("LongrunPlanningPresenter_LongrunPlanningContractPresenter_Realization", longrunPlanningPresenter, longrunPlanningContractPresenter);

    Class planWorkoutPresenter = world.getClass("PlanWorkoutPresenter");
    Class planWorkoutContractPresenter = world.getClass("PlanWorkoutContractPresenter");
    world.newRealization("PlanWorkoutPresenter_PlanWorkoutContractPresenter_Realization", planWorkoutPresenter, planWorkoutContractPresenter);

    Class selectPlaylistPresenter = world.getClass("SelectPlaylistPresenter");
    Class selectPlaylistContractPresenter = world.getClass("SelectPlaylistContractPresenter");
    world.newRealization("SelectPlaylistPresenter_SelectPlaylistContractPresenter_Realization", selectPlaylistPresenter, selectPlaylistContractPresenter);

    Class waitForGpsPresenter = world.getClass("WaitForGpsPresenter");
    Class waitForGpsContractPresenter = world.getClass("WaitForGpsContractPresenter");
    world.newRealization("WaitForGpsPresenter_WaitForGpsContractPresenter_Realization", waitForGpsPresenter, waitForGpsContractPresenter);

    //running
    Class fitnessPresenter = world.getClass("FitnessPresenter");
    Class fitnessContractPresenter = world.getClass("FitnessContractPresenter");
    world.newRealization("FitnessPresenter_FitnessContractPresenter_Realization", fitnessPresenter, fitnessContractPresenter);

    Class lapPresenter = world.getClass("LapPresenter");
    Class lapContractPresenter = world.getClass("LapContractPresenter");
    world.newRealization("LapPresenter_LapContractPresenter_Realization", lapPresenter, lapContractPresenter);

    Class playlistPresenter = world.getClass("PlaylistPresenter");
    Class playlistContractPresenter = world.getClass("PlaylistContractPresenter");
    world.newRealization("PlaylistPresenter_PlaylistContractPresenter_Realization", playlistPresenter, playlistContractPresenter);

    Class runningPresenter = world.getClass("RunningPresenter");
    Class runningContractPresenter = world.getClass("RunningContractPresenter");
    world.newRealization("RunningPresenter_RunningContractPresenter_Realization", runningPresenter, runningContractPresenter);

    Class fitnessDataFacade = world.getClass("FitnessDataFacade");
    world.newRealization("RunningPresenter_FitnessDataFacade_Realization", runningPresenter, fitnessDataFacade);

    Class playlistDataFacade = world.getClass("PlaylistDataFacade");
    world.newRealization("RunningPresenter_PlaylistDataFacade_Realization", runningPresenter, playlistDataFacade);

    Class stopWatchPresenter = world.getClass("StopWatchPresenter");
    Class stopWatchContractPresenter = world.getClass("StopWatchContractPresenter");
    world.newRealization("StopWatchPresenter_StopWatchContractPresenter_Realization", stopWatchPresenter, stopWatchContractPresenter);

    //start
    Class startingDisplayPresenter = world.getClass("StartingDisplayPresenter");
    Class startingDisplayContractPresenter = world.getClass("StartingDisplayContractPresenter");
    world.newRealization("StartingDisplayPresenter_StartingDisplayContractPresenter_Realization", startingDisplayPresenter, startingDisplayContractPresenter);

    Type consumer_FragmentCommand_ = world.getType("Consumer<FragmentCommand>");
    world.newRealization("StartingDisplayPresenter_Consumer_Realization", startingDisplayPresenter, consumer_FragmentCommand_);

}

void addMediaEntityMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class mediaEntity = world.getClass("MediaEntity");

    MemberVariable accessToken = mediaEntity.newMemberVariable("accessToken");
    accessToken.type = world.getType("String");
    protectedMemberVariables ~= accessToken;

    addGetter(accessToken, abstractMemberFunctions, mediaEntity, world);
    addSetter(accessToken, abstractMemberFunctions, mediaEntity, world);

}

void addPlanningEntityMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class planningEntity = world.getClass("PlanningEntity");

    MemberVariable selectedPlaylists = planningEntity.newMemberVariable("selectedPlaylists");
    selectedPlaylists.type = world.getType("Set<PlaylistBean>");
    protectedMemberVariables ~= selectedPlaylists;

    MemberVariable workoutElementBeanList = planningEntity.newMemberVariable("workoutElementBeanList");
    workoutElementBeanList.type = world.getType("List<WorkoutElementBean>");
    protectedMemberVariables ~= workoutElementBeanList;

    MemberFunction getSelectedPlaylists = planningEntity.newMemberFunction("getSelectedPlaylists");
    getSelectedPlaylists.returnType = world.getType("Set<PlaylistBean>");
    abstractMemberFunctions ~= getSelectedPlaylists;

    MemberFunction setSelectedPlaylists = planningEntity.newMemberFunction("setSelectedPlaylists");
    setSelectedPlaylists.returnType = world.getType("Void");
    setSelectedPlaylists.addParameter("selectedPlaylists", world.getType("Set<PlaylistBean>"));
    abstractMemberFunctions ~= setSelectedPlaylists;

    MemberFunction getWorkoutElementBeanList = planningEntity.newMemberFunction("getWorkoutElementBeanList");
    getWorkoutElementBeanList.returnType = world.getType("List<WorkoutElementBean>");
    abstractMemberFunctions ~= getWorkoutElementBeanList;

    MemberFunction setWorkoutElementBeanList = planningEntity.newMemberFunction("setWorkoutElementBeanList");
    setWorkoutElementBeanList.returnType = world.getType("Void");
    setWorkoutElementBeanList.addParameter("workoutElementBeanList", world.getType("List<WorkoutElementBean>"));
    abstractMemberFunctions ~= setWorkoutElementBeanList;
}

void addPlaylistBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class playlistBean = world.getClass("PlaylistBean");

    MemberVariable id = playlistBean.newMemberVariable("id");
    id.type = world.getType("String");
    protectedMemberVariables ~= id;

    addGetter(id, abstractMemberFunctions, playlistBean, world);
    addSetter(id, abstractMemberFunctions, playlistBean, world);

    MemberVariable tracks  = playlistBean.newMemberVariable("tracksHref");
    tracks.type = world.getType("String");
    protectedMemberVariables ~= tracks;

    addGetter(tracks, abstractMemberFunctions, playlistBean, world);
    addSetter(tracks, abstractMemberFunctions, playlistBean, world);

    MemberVariable user = playlistBean.newMemberVariable("user");
    user.type = world.getType("String");
    protectedMemberVariables ~= user;

    addGetter(user, abstractMemberFunctions, playlistBean, world);
    addSetter(user, abstractMemberFunctions, playlistBean, world);
}

void addWorkourElementBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class workoutElementBean = world.getClass("WorkoutElementBean");

    MemberVariable duration = workoutElementBean.newMemberVariable("duration");
    duration.type = world.getType("Int");
    protectedMemberVariables ~= duration;

    MemberVariable speed = workoutElementBean.newMemberVariable("speed");
    speed.type = world.getType("Int");
    protectedMemberVariables ~= speed;

    MemberFunction getDuration = workoutElementBean.newMemberFunction("getDuration");
    getDuration.returnType = world.getType("Int");
    abstractMemberFunctions ~= getDuration;

    MemberFunction setDuration = workoutElementBean.newMemberFunction("setDuration");
    setDuration.returnType = world.getType("Void");
    setDuration.addParameter("duration", world.getType("Int"));
    abstractMemberFunctions ~= setDuration;

    MemberFunction getSpeed = workoutElementBean.newMemberFunction("getSpeed");
    getSpeed.returnType = world.getType("Int");
    abstractMemberFunctions ~= getSpeed;

    MemberFunction setSpeed = workoutElementBean.newMemberFunction("setSpeed");
    setSpeed.returnType = world.getType("Void");
    setSpeed.addParameter("speed", world.getType("Int"));
    abstractMemberFunctions ~= setSpeed;
}

void addMediaDataSourceMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class mediaDataSource = world.getClass("MediaDataSource");

    MemberFunction getPlaylists = mediaDataSource.newMemberFunction("getPlaylists");
    getPlaylists.returnType = world.getType("Observable<SelectPlaylistImageBean>");

    MemberFunction initialize = mediaDataSource.newMemberFunction("initialize");
    initialize.returnType = world.getType("Void");

    MemberFunction getPlaylistSongs = mediaDataSource.newMemberFunction("getPlaylistSongs");
    getPlaylistSongs.returnType = world.getType("Observable<SongBean>");
    getPlaylistSongs.addParameter("playlist", world.getType("String"));
    getPlaylistSongs.addParameter("user", world.getType("String"));
}

void addAlbumBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class albumBean = world.getClass("AlbumBean");

    MemberVariable name = albumBean.newMemberVariable("name");
    name.type = world.getType("String");
    protectedMemberVariables ~= name;

    addGetter(name, abstractMemberFunctions, albumBean, world);
    addSetter(name, abstractMemberFunctions, albumBean, world);

}

void addArtistBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class artistBean = world.getClass("ArtistBean");

    MemberVariable name = artistBean.newMemberVariable("name");
    name.type = world.getType("String");
    protectedMemberVariables ~= name;

    addGetter(name, abstractMemberFunctions, artistBean, world);
    addSetter(name, abstractMemberFunctions, artistBean, world);
}

void addImageBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class imageBean = world.getClass("ImageBean");

    MemberVariable height = imageBean.newMemberVariable("height");
    height.type = world.getType("Int");
    protectedMemberVariables ~= height;

    MemberVariable url = imageBean.newMemberVariable("url");
    url.type = world.getType("String");
    protectedMemberVariables ~= url;

    MemberVariable width = imageBean.newMemberVariable("width");
    width.type = world.getType("Int");
    protectedMemberVariables ~= width;

    MemberFunction getHeight = imageBean.newMemberFunction("getHeight");
    getHeight.returnType = world.getType("Int");
    abstractMemberFunctions ~= getHeight;

    MemberFunction setHeight = imageBean.newMemberFunction("setHeight");
    setHeight.returnType = world.getType("Void");
    setHeight.addParameter("height", world.getType("Int"));
    abstractMemberFunctions ~= setHeight;

    MemberFunction getUrl = imageBean.newMemberFunction("getUrl");
    getUrl.returnType = world.getType("String");
    abstractMemberFunctions ~= getUrl;

    MemberFunction setUrl = imageBean.newMemberFunction("setUrl");
    setUrl.returnType = world.getType("Void");
    setUrl.addParameter("url", world.getType("String"));
    abstractMemberFunctions ~= setUrl;

    MemberFunction getWidth = imageBean.newMemberFunction("getWidth");
    getWidth.returnType = world.getType("Int");
    abstractMemberFunctions ~= getWidth;

    MemberFunction setWidth = imageBean.newMemberFunction("setWidth");
    setWidth.returnType = world.getType("Void");
    setWidth.addParameter("width", world.getType("Int"));
    abstractMemberFunctions ~= setWidth;
}

void addSpotifyPlaylistBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class spotifyPlaylistBean = world.getClass("SpotifyPlaylistBean");

    MemberVariable collaborative = spotifyPlaylistBean.newMemberVariable("collaborative");
    collaborative.type = world.getType("Bool");
    protectedMemberVariables ~= collaborative;

    addGetter(collaborative, abstractMemberFunctions, spotifyPlaylistBean, world);
    addSetter(collaborative, abstractMemberFunctions, spotifyPlaylistBean, world);

    MemberVariable href = spotifyPlaylistBean.newMemberVariable("href");
    href.type = world.getType("String");
    protectedMemberVariables ~= href;

    addGetter(href, abstractMemberFunctions, spotifyPlaylistBean, world);
    addSetter(href, abstractMemberFunctions, spotifyPlaylistBean, world);

    MemberVariable id = spotifyPlaylistBean.newMemberVariable("id");
    id.type = world.getType("String");
    protectedMemberVariables ~= id;

    addGetter(id, abstractMemberFunctions, spotifyPlaylistBean, world);
    addSetter(id, abstractMemberFunctions, spotifyPlaylistBean, world);

    MemberVariable images = spotifyPlaylistBean.newMemberVariable("images");
    images.type = world.getType("List<ImageBean>");
    protectedMemberVariables ~= images;

    addGetter(images, abstractMemberFunctions, spotifyPlaylistBean, world);
    addSetter(images, abstractMemberFunctions, spotifyPlaylistBean, world);

    MemberVariable name = spotifyPlaylistBean.newMemberVariable("name");
    name.type = world.getType("String");
    protectedMemberVariables ~= name;

    addGetter(name, abstractMemberFunctions, spotifyPlaylistBean, world);
    addSetter(name, abstractMemberFunctions, spotifyPlaylistBean, world);

    MemberVariable snapshot_id = spotifyPlaylistBean.newMemberVariable("snapshot_id");
    snapshot_id.type = world.getType("String");
    protectedMemberVariables ~= snapshot_id;

    addGetter(snapshot_id, abstractMemberFunctions, spotifyPlaylistBean, world);
    addSetter(snapshot_id, abstractMemberFunctions, spotifyPlaylistBean, world);

    MemberVariable tracks = spotifyPlaylistBean.newMemberVariable("tracks");
    tracks.type = world.getType("TracksBean");
    protectedMemberVariables ~= tracks;

    addGetter(tracks, abstractMemberFunctions, spotifyPlaylistBean, world);
    addSetter(tracks, abstractMemberFunctions, spotifyPlaylistBean, world);

    MemberVariable type = spotifyPlaylistBean.newMemberVariable("type");
    type.type = world.getType("String");
    protectedMemberVariables ~= type;

    addGetter(type, abstractMemberFunctions, spotifyPlaylistBean, world);
    addSetter(type, abstractMemberFunctions, spotifyPlaylistBean, world);

    MemberVariable uri = spotifyPlaylistBean.newMemberVariable("uri");
    uri.type = world.getType("String");
    protectedMemberVariables ~= uri;

    addGetter(uri, abstractMemberFunctions, spotifyPlaylistBean, world);
    addSetter(uri, abstractMemberFunctions, spotifyPlaylistBean, world);

}

void addPlaylistTrackBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class playlistTrackBean = world.getClass("PlaylistTrackBean");

    MemberVariable track = playlistTrackBean.newMemberVariable("track");
    track.type = world.getType("TrackBean");
    protectedMemberVariables ~= track;

    addGetter(track, abstractMemberFunctions, playlistTrackBean, world);
    addSetter(track, abstractMemberFunctions, playlistTrackBean, world);

}

void addTrackBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class trackBean = world.getClass("TrackBean");

    MemberVariable album = trackBean.newMemberVariable("album");
    album.type = world.getType("AlbumBean");
    protectedMemberVariables ~= album;

    addSetter(album, abstractMemberFunctions, trackBean, world);
    addGetter(album, abstractMemberFunctions, trackBean, world);

    MemberVariable artists = trackBean.newMemberVariable("artists");
    artists.type = world.getType("List<ArtistBean>");
    protectedMemberVariables ~= artists;

    addSetter(artists, abstractMemberFunctions, trackBean, world);
    addGetter(artists, abstractMemberFunctions, trackBean, world);

    MemberVariable duration_ms = trackBean.newMemberVariable("duration_ms");
    duration_ms.type = world.getType("Int");
    protectedMemberVariables ~= duration_ms;

    addSetter(duration_ms, abstractMemberFunctions, trackBean, world);
    addGetter(duration_ms, abstractMemberFunctions, trackBean, world);

    MemberVariable id = trackBean.newMemberVariable("id");
    id.type = world.getType("String");
    protectedMemberVariables ~= id;

    addSetter(id, abstractMemberFunctions, trackBean, world);
    addGetter(id, abstractMemberFunctions, trackBean, world);

    MemberVariable name = trackBean.newMemberVariable("name");
    name.type = world.getType("String");
    protectedMemberVariables ~= name;

    addSetter(name, abstractMemberFunctions, trackBean, world);
    addGetter(name, abstractMemberFunctions, trackBean, world);
}

void addLocationServiceMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class locationService = world.getClass("LocationService");

    MemberFunction distanceObservable = locationService.newMemberFunction("distanceObservable");
    distanceObservable.returnType = world.getType("Observable<Double>");

    MemberFunction speedObservable = locationService.newMemberFunction("speedObservable");
    speedObservable.returnType = world.getType("Observable<Double>");
}

void addPlayerServiceMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class playerService = world.getClass("PlayerService");

    MemberFunction playSong = playerService.newMemberFunction("playSong");
    playSong.returnType = world.getType("Void");
    playSong.addParameter("uri", world.getType("String"));

    MemberFunction enqueueSong = playerService.newMemberFunction("enqueueSong");
    enqueueSong.returnType = world.getType("Void");
    enqueueSong.addParameter("uri", world.getType("String"));

    MemberFunction pause = playerService.newMemberFunction("pause");
    pause.returnType = world.getType("Void");

    MemberFunction resume = playerService.newMemberFunction("resume");
    resume.returnType = world.getType("Void");

}

void addRunningServiceMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class runningService = world.getClass("RunningService");

    MemberFunction showNotification = runningService.newMemberFunction("showNotification");
    showNotification.returnType = world.getType("Void");

    MemberFunction cancelNotification = runningService.newMemberFunction("cancelNotification");
    cancelNotification.returnType = world.getType("Void");

    MemberFunction speedObservable = runningService.newMemberFunction("speedObservable");
    speedObservable.returnType = world.getType("Observable<Double>");

    MemberFunction distanceObservable = runningService.newMemberFunction("distanceObservable");
    distanceObservable.returnType = world.getType("Observable<Double>");
}

void addSpotifyPlayerServiceMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){

}

void addTracksBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class tracksBean = world.getClass("TracksBean");

    MemberVariable total = tracksBean.newMemberVariable("total");
    total.type = world.getType("Int");
    protectedMemberVariables ~= total;

    addSetter(total, abstractMemberFunctions, tracksBean, world);
    addGetter(total, abstractMemberFunctions, tracksBean, world);

    MemberVariable href = tracksBean.newMemberVariable("href");
    href.type = world.getType("String");
    protectedMemberVariables ~= href;

    addSetter(href, abstractMemberFunctions, tracksBean, world);
    addGetter(href, abstractMemberFunctions, tracksBean, world);

}

void addPersistTrainingPlanCaseMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class persistTrainingPlanCase = world.getClass("PersistTrainingPlanCase");

    MemberVariable planningEntity = persistTrainingPlanCase.newMemberVariable("planningEntity");
    planningEntity.type = world.getType("PlanningEntity");
    protectedMemberVariables ~= planningEntity;

    MemberFunction persistTrainingPlan = persistTrainingPlanCase.newMemberFunction("persistTrainingPlan");
    persistTrainingPlan.returnType = world.getType("Void");
    persistTrainingPlan.addParameter("intervalPlanningBeans", world.getType("List<IntervalPlanningBean>"));
    abstractMemberFunctions ~= persistTrainingPlan;

    MemberFunction persistTrainingPlan1 = persistTrainingPlanCase.newMemberFunction("persistTrainingPlan");
    persistTrainingPlan1.returnType = world.getType("Void");
    persistTrainingPlan1.addParameter("longrunPlanningBean", world.getType("LongrunPlanningBean"));
    abstractMemberFunctions ~= persistTrainingPlan1;

    MemberFunction getPersistedIntervalTrainingPlan = persistTrainingPlanCase.newMemberFunction("getPersistedIntervalTrainingPlan");
    getPersistedIntervalTrainingPlan.returnType = world.getType("List<IntervalPlanningBean>");
    abstractMemberFunctions ~= getPersistedIntervalTrainingPlan;

    MemberFunction getPersistedLongrunTrainingPlan = persistTrainingPlanCase.newMemberFunction("getPersistedLongrunTrainingPlan");
    getPersistedLongrunTrainingPlan.returnType = world.getType("LongrunPlanningBean");
    abstractMemberFunctions ~= getPersistedLongrunTrainingPlan;
}

void addInitializeMediaDataSourceCaseMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class initializeMediaDataSourceCase = world.getClass("InitializeMediaDataSourceCase");

    MemberVariable mediaDataSource = initializeMediaDataSourceCase.newMemberVariable("mediaDataSource");
    mediaDataSource.type = world.getType("MediaDataSource");
    protectedMemberVariables ~= mediaDataSource;

    MemberFunction initializeMediaDataSource = initializeMediaDataSourceCase.newMemberFunction("initializeMediaDataSource");
    initializeMediaDataSource.returnType = world.getType("Void");
    abstractMemberFunctions ~= initializeMediaDataSource;
}

void addPlaylistCaseMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class playlistsCase = world.getClass("PlaylistsCase");

    MemberVariable planningEntity = playlistsCase.newMemberVariable("planningEntity");
    planningEntity.type = world.getType("PlanningEntity");
    protectedMemberVariables ~= planningEntity;

    MemberVariable mediaDataSource = playlistsCase.newMemberVariable("mediaDataSource");
    mediaDataSource.type = world.getType("MediaDataSource");
    protectedMemberVariables ~= mediaDataSource;

    MemberFunction persistChosenPlaylists = playlistsCase.newMemberFunction("persistChosenPlaylists");
    persistChosenPlaylists.addParameter("selectedPlaylistImageBeans", world.getType("Set<PlaylistBean>"));
    persistChosenPlaylists.returnType = world.getType("Void");
    abstractMemberFunctions  ~= persistChosenPlaylists;

    MemberFunction getSelectedPlaylists = playlistsCase.newMemberFunction("getSelectedPlaylists");
    getSelectedPlaylists.returnType = world.getType("Set<PlaylistBean>");
    abstractMemberFunctions ~= getSelectedPlaylists;

    MemberFunction getPlaylists = playlistsCase.newMemberFunction("getPlaylists");
    getPlaylists.returnType = world.getType("Observable<SelectPlaylistImageBean>");
    abstractMemberFunctions ~= getPlaylists;

    MemberFunction getPlaylistSongs = playlistsCase.newMemberFunction("getPlaylistSongs");
    getPlaylistSongs.returnType = world.getType("Observable<SongBean>");
    abstractMemberFunctions ~= getPlaylistSongs;
}

void addIntervalPlanningContractPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class intervalPlanningContractPresenter = world.getClass("IntervalPlanningContractPresenter");

        MemberFunction persistIntervals = intervalPlanningContractPresenter.newMemberFunction("persistIntervals");
        persistIntervals.returnType = world.getType("Void");
        Type list_IntervalPlanningBean_ = world.getType("List<IntervalPlanningBean>");
        persistIntervals.addParameter("intervalPlanningBean", list_IntervalPlanningBean_);

        MemberFunction getPersistedIntervals = intervalPlanningContractPresenter.newMemberFunction("getPersistedIntervals");
        getPersistedIntervals.returnType = world.getType("List<IntervalPlanningBean>");
}


void addLongrunPlanningContractPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class longrunPlanningContractPresenter = world.getClass("LongrunPlanningContractPresenter");

        MemberFunction persistLongrunTraining = longrunPlanningContractPresenter.newMemberFunction("persistLongrunTraining");
        persistLongrunTraining.returnType = world.getType("Void");
        persistLongrunTraining.addParameter("longrunPlanningBean", world.getType("LongrunPlanningBean"));

        MemberFunction getPersistedLongrunTraining = longrunPlanningContractPresenter.newMemberFunction("getPersistedLongrunTraining");
        getPersistedLongrunTraining.returnType = world.getType("LongrunPlanningBean");
}

void addPlanWorkoutContractPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    //TODO rest of classes of planWorkoutContractPresenter -> Therefore implement inner classes
    Class planWorkoutContractPresenter = world.getClass("PlanWorkoutContractPresenter");

        MemberFunction setup = planWorkoutContractPresenter.newMemberFunction("setup");
        setup.returnType = world.getType("Void");

        MemberFunction handleHomeButtonClick = planWorkoutContractPresenter.newMemberFunction("handleHomeButtonClick");
        handleHomeButtonClick.returnType = world.getType("HomeButtonClickResult"); //TODO
        handleHomeButtonClick.addParameter("menuItem", world.getType("MenuItem"));

        MemberFunction setActiveFragment = planWorkoutContractPresenter.newMemberFunction("setActiveFragment");
        setActiveFragment.returnType = world.getType("Void");
        setActiveFragment.addParameter("activeFragment", world.getType("ActiveFragment")); //TODO

        MemberFunction setTrainingMode = planWorkoutContractPresenter.newMemberFunction("setTrainingMode");
        setTrainingMode.returnType = world.getType("Void");
        setTrainingMode.addParameter("trainingMode", world.getType("TrainingMode"));

        MemberFunction getActiveFragment = planWorkoutContractPresenter.newMemberFunction("getActiveFragment");
        getActiveFragment.returnType = world.getType("ActiveFragment");

        MemberFunction getTrainingMode = planWorkoutContractPresenter.newMemberFunction("getTrainingMode");
        getTrainingMode.returnType = world.getType("TrainingMode");
}

void addSelectPlaylistContractPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class selectPlaylistContractPresenter = world.getClass("SelectPlaylistContractPresenter");

        MemberFunction receivePlaylists = selectPlaylistContractPresenter.newMemberFunction("receivePlaylists");
        Type observable_SelectPlaylistImageBean_ = world.getType("Observable<SelectPlaylistImageBean>");
        receivePlaylists.returnType = observable_SelectPlaylistImageBean_;


        MemberFunction persistCheckedPlaylists = selectPlaylistContractPresenter.newMemberFunction("persistCheckedPlaylists");
        persistCheckedPlaylists.returnType = world.getType("Void");
        Type set_PlaylistBean_ = world.getType("Set<PlaylistBean>");
        persistCheckedPlaylists.addParameter("playlistElementBeanSet", set_PlaylistBean_);

        MemberFunction getCheckedPlaylists = selectPlaylistContractPresenter.newMemberFunction("getCheckedPlaylists");
        getCheckedPlaylists.returnType = set_PlaylistBean_;
}

void addPlanWorkoutContractViewMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class planWorkoutContractView = world.getClass("PlanWorkoutContractView");

        MemberFunction showWaitForGps = planWorkoutContractView.newMemberFunction("showWaitForGps");
        showWaitForGps.returnType = world.getType("Void");

        MemberFunction showSelectPlaylist = planWorkoutContractView.newMemberFunction("showSelectPlaylist");
        showSelectPlaylist.returnType = world.getType("Void");

        MemberFunction showLongrunPlanning = planWorkoutContractView.newMemberFunction("showLongrunPlanning");
        showLongrunPlanning.returnType = world.getType("Void");

        MemberFunction showIntervalPlanning = planWorkoutContractView.newMemberFunction("showIntervalPlanning");
        showIntervalPlanning.returnType = world.getType("Void");

        MemberFunction showSelectTraining = planWorkoutContractView.newMemberFunction("showSelectTraining");
        showSelectTraining.returnType = world.getType("Void");

        MemberFunction showScheduleFragment = planWorkoutContractView.newMemberFunction("showScheduleFragment");
        showScheduleFragment.returnType = world.getType("Void");

        MemberFunction showSelectTrainingFragment = planWorkoutContractView.newMemberFunction("showSelectTrainingFragment");
        showSelectTrainingFragment.returnType = world.getType("Void");
}

void addWaitForGpsContractPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class waitForGpsContractPresenter = world.getClass("WaitForGpsContractPresenter");

    MemberFunction checkLocationPermission = waitForGpsContractPresenter.newMemberFunction("checkLocationPermission");
    checkLocationPermission.returnType = world.getType("Void");
}

void addWaitForGpsContractViewMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class waitForGpsContractView = world.getClass("WaitForGpsContractView");

    MemberFunction onPermissionGranted = waitForGpsContractView.newMemberFunction("onPermissionGranted");
    onPermissionGranted.returnType = world.getType("Void");

    MemberFunction onPermissionDenied = waitForGpsContractView.newMemberFunction("onPermissionDenied");
    onPermissionDenied.returnType = world.getType("Void");
}

void addFitnessContractPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){

}

void addFitnessContractViewMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class fitnessContractView = world.getClass("FitnessContractView");

    MemberFunction updateDistance = fitnessContractView.newMemberFunction("updateDistance");
    updateDistance.returnType = world.getType("Void");
    updateDistance.addParameter("distance", world.getType("Double"));

    MemberFunction updateSpeed = fitnessContractView.newMemberFunction("updateSpeed");
    updateSpeed.returnType = world.getType("Void");
    updateSpeed.addParameter("speed", world.getType("Double"));
}

void addLapContractPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){

}

void addLapContractViewMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){

}

void addPlaylistContractPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class playlistContractPresenter = world.getClass("PlaylistContractPresenter");

        MemberFunction getPlaylistSongs = playlistContractPresenter.newMemberFunction("getPlaylistSongs");
        getPlaylistSongs.returnType = world.getType("Observable<SongBean>");

}

void addPlaylistContractViewMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class playlistContractView = world.getClass("PlaylistContractView");
}

void addStopWatchContractPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class stopWatchContractPresenter = world.getClass("StopWatchContractPresenter");

    MemberFunction startClock = stopWatchContractPresenter.newMemberFunction("startClock");
    startClock.returnType = world.getType("Void");

    MemberFunction stopClock = stopWatchContractPresenter.newMemberFunction("stopClock");
    stopClock.returnType = world.getType("Void");

    MemberFunction pauseClock = stopWatchContractPresenter.newMemberFunction("pauseClock");
    pauseClock.returnType = world.getType("Void");

    MemberFunction lap = stopWatchContractPresenter.newMemberFunction("lap");
    lap.returnType = world.getType("Void");

}

void addStopWatchContractViewMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class stopWatchContractView = world.getClass("StopWatchContractView");

    MemberFunction setDigitalClock = stopWatchContractView.newMemberFunction("setDigitalClock");
    setDigitalClock.returnType = world.getType("Void");
    setDigitalClock.addParameter("millisecondsSinceStart", world.getType("Long"));

    MemberFunction showEndTrainingQuestion = stopWatchContractView.newMemberFunction("showEndTrainingQuestion");
    showEndTrainingQuestion.returnType = world.getType("Void");
}

void addRunningContractPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class runningContractPresenter = world.getClass("RunningContractPresenter");

        MemberFunction showNotification =  runningContractPresenter.newMemberFunction("showNotification");
        showNotification.returnType = world.getType("Void");

        MemberFunction cancelNotification =  runningContractPresenter.newMemberFunction("cancelNotification");
        cancelNotification.returnType = world.getType("Void");
}

void addRunningContractViewMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){

}

void addStartingDisplayContractPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class startingDisplayContractPresenter = world.getClass("StartingDisplayContractPresenter");
}

void addStartingDisplayContractViewMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class startingDisplayContractView = world.getClass("StartingDisplayContractView");

    MemberFunction startPlanningActivity = startingDisplayContractView.newMemberFunction("startPlanningActivity");
    startPlanningActivity.returnType = world.getType("Void");

    MemberFunction startReviewActivity = startingDisplayContractView.newMemberFunction("startReviewActivity");
    startReviewActivity.returnType = world.getType("Void");

    MemberFunction showPreferences = startingDisplayContractView.newMemberFunction("showPreferences");
    showPreferences.returnType = world.getType("Void");

    MemberFunction showOptions = startingDisplayContractView.newMemberFunction("showOptions");
    showOptions.returnType = world.getType("Void");
}

void addFitnessDataFacadeMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class fitnessDataFacade = world.getClass("FitnessDataFacade");

    MemberFunction distanceObservable = fitnessDataFacade.newMemberFunction("distanceObservable");
    distanceObservable.returnType = world.getType("Observable<Double>");

    MemberFunction speedObservable = fitnessDataFacade.newMemberFunction("speedObservable");
    speedObservable.returnType = world.getType("Observable<Double>");
}

void addPlaylistDataFacadeMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class playlistDataFacade = world.getClass("PlaylistDataFacade");

    MemberFunction getSongsOfSelectedPlaylist = playlistDataFacade.newMemberFunction("getSongsOfSelectedPlaylist");
    getSongsOfSelectedPlaylist.returnType = world.getType("Observable<PlaylistBean>");

}

void addStopwatchStateFacadeMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class stopWatchStateFacade = world.getClass("StopwatchStateFacade");

    MemberFunction publishState = stopWatchStateFacade.newMemberFunction("publishState");
    publishState.returnType = world.getType("StopwatchState");

}

void addIntervalPlanningBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class intervalPlanningBean = world.getClass("IntervalPlanningBean");

        MemberVariable time = intervalPlanningBean.newMemberVariable("time");
        time.type = world.getType("Int");
        protectedMemberVariables ~= time;

        MemberVariable speed = intervalPlanningBean.newMemberVariable("speed");
        speed.type = world.getType("Int");
        protectedMemberVariables ~= speed;

        MemberVariable position = intervalPlanningBean.newMemberVariable("position");
        position.type = world.getType("Int");
        protectedMemberVariables ~= position;

        MemberFunction getTime = intervalPlanningBean.newMemberFunction("getTime");
        getTime.returnType = world.getType("Int");
        abstractMemberFunctions ~= getTime;

        MemberFunction setTime = intervalPlanningBean.newMemberFunction("setTime");
        setTime.addParameter("time", world.getType("Int"));
        setTime.returnType = world.getType("Void");
        abstractMemberFunctions ~= setTime;

        MemberFunction getSpeed = intervalPlanningBean.newMemberFunction("getSpeed");
        getSpeed.returnType = world.getType("Int");
        abstractMemberFunctions ~= getSpeed;

        MemberFunction setSpeed = intervalPlanningBean.newMemberFunction("setSpeed");
        setSpeed.addParameter("speed", world.getType("Int"));
        setSpeed.returnType = world.getType("Void");
        abstractMemberFunctions ~= setSpeed;

        MemberFunction getPosition = intervalPlanningBean.newMemberFunction("getPosition");
        getPosition.returnType = world.getType("Int");
        abstractMemberFunctions ~= getPosition;

        MemberFunction setPosition = intervalPlanningBean.newMemberFunction("setPosition");
        setPosition.addParameter("position", world.getType("Int"));
        setPosition.returnType = world.getType("Void");
        abstractMemberFunctions ~= setPosition;

        MemberFunction getDurationMinutes = intervalPlanningBean.newMemberFunction("getDurationMinutes");
        getDurationMinutes.returnType = world.getType("Int");
        abstractMemberFunctions ~= getDurationMinutes;

        MemberFunction getDurationSeconds = intervalPlanningBean.newMemberFunction("getDurationSeconds");
        getDurationSeconds.returnType = world.getType("Int");
        abstractMemberFunctions ~= getDurationSeconds;

        MemberFunction getSpeedMinutes = intervalPlanningBean.newMemberFunction("getSpeedMinutes");
        getSpeedMinutes.returnType = world.getType("Int");
        abstractMemberFunctions ~= getSpeedMinutes;

        MemberFunction getSpeedSeconds = intervalPlanningBean.newMemberFunction("getSpeedSeconds");
        getSpeedSeconds.returnType = world.getType("Int");
        abstractMemberFunctions ~= getSpeedSeconds;
}


void addLapBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class lapBean = world.getClass("LapBean");

    MemberVariable start = lapBean.newMemberVariable("start");
    start.type = world.getType("Date");
    protectedMemberVariables ~= start;

    addSetter(start, abstractMemberFunctions, lapBean, world);
    addGetter(start, abstractMemberFunctions, lapBean, world);

    MemberVariable end = lapBean.newMemberVariable("end");
    end.type = world.getType("Date");
    protectedMemberVariables ~= end;

    addSetter(end, abstractMemberFunctions, lapBean, world);
    addGetter(end, abstractMemberFunctions, lapBean, world);

    MemberVariable distance = lapBean.newMemberVariable("distance");
    distance.type = world.getType("Double");
    protectedMemberVariables ~= distance;

    addSetter(distance, abstractMemberFunctions, lapBean, world);
    addGetter(distance, abstractMemberFunctions, lapBean, world);

    MemberVariable lapNumber = lapBean.newMemberVariable("lapNumber");
    lapNumber.type = world.getType("Int");
    protectedMemberVariables ~= lapNumber;

    addSetter(lapNumber, abstractMemberFunctions, lapBean, world);
    addGetter(lapNumber, abstractMemberFunctions, lapBean, world);
}

void addLongrunPlanningBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class longrunPlanningBean = world.getClass("LongrunPlanningBean");

        MemberVariable duration = longrunPlanningBean.newMemberVariable("duration");
        duration.type = world.getType("Int");
        protectedMemberVariables ~= duration;

        MemberVariable speed = longrunPlanningBean.newMemberVariable("speed");
        speed.type = world.getType("Int");
        protectedMemberVariables ~= speed;

        MemberFunction getDuration = longrunPlanningBean.newMemberFunction("getDuration");
        getDuration.returnType = world.getType("Int");
        abstractMemberFunctions ~= getDuration;

        MemberFunction setDuration = longrunPlanningBean.newMemberFunction("setDuration");
        abstractMemberFunctions ~= setDuration;
        setDuration.returnType = world.getType("Void");
        setDuration.addParameter("duration", world.getType("Int"));

        MemberFunction getSpeed = longrunPlanningBean.newMemberFunction("getSpeed");
        getSpeed.returnType = world.getType("Int");
        abstractMemberFunctions ~= getSpeed;

        MemberFunction setSpeed = longrunPlanningBean.newMemberFunction("setSpeed");
        abstractMemberFunctions ~= setSpeed;
        setSpeed.returnType = world.getType("Void");
        setSpeed.addParameter("speed", world.getType("Int"));

        MemberFunction setSpeed_ = longrunPlanningBean.newMemberFunction("setSpeed");
        abstractMemberFunctions ~= setSpeed_;
        setSpeed_.returnType = world.getType("Void");
        setSpeed_.addParameter("minutes", world.getType("Int"));
        setSpeed_.addParameter("seconds", world.getType("Int"));

        MemberFunction setDuration_ = longrunPlanningBean.newMemberFunction("setDuration");
        abstractMemberFunctions ~= setDuration_;
        setDuration_.returnType = world.getType("Void");
        setDuration_.addParameter("hours", world.getType("Int"));
        setDuration_.addParameter("minutes", world.getType("Int"));
        setDuration_.addParameter("seconds", world.getType("Int"));

        MemberFunction getSpeedSeconds = longrunPlanningBean.newMemberFunction("getSpeedSeconds");
        getSpeedSeconds.returnType = world.getType("Int");
        abstractMemberFunctions ~= getSpeedSeconds;

        MemberFunction getSpeedMinutes = longrunPlanningBean.newMemberFunction("getSpeedMinutes");
        getSpeedMinutes.returnType = world.getType("Int");
        abstractMemberFunctions ~= getSpeedMinutes;

        MemberFunction getDurationHours = longrunPlanningBean.newMemberFunction("getDurationHours");
        getDurationHours.returnType = world.getType("Int");
        abstractMemberFunctions ~= getDurationHours;

        MemberFunction getDurationMinutes = longrunPlanningBean.newMemberFunction("getDurationMinutes");
        getDurationMinutes.returnType = world.getType("Int");
        abstractMemberFunctions ~= getDurationMinutes;

        MemberFunction getDurationSeconds = longrunPlanningBean.newMemberFunction("getDurationSeconds");
        getDurationSeconds.returnType = world.getType("Int");
        abstractMemberFunctions ~= getDurationSeconds;
}

void addSelectPlaylistImageBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class selectPlaylistImageBean = world.getClass("SelectPlaylistImageBean");

        MemberVariable playlistImage = selectPlaylistImageBean.newMemberVariable("playlistImage");
        Type bitmap = world.getType("Bitmap");
        playlistImage.type = bitmap;
        protectedMemberVariables ~= playlistImage;

        MemberVariable playlistTitle = selectPlaylistImageBean.newMemberVariable("playlistTitle");
        playlistTitle.type = world.getType("String");
        protectedMemberVariables ~= playlistTitle;

        MemberVariable playlistCreator = selectPlaylistImageBean.newMemberVariable("playlistCreator");
        playlistCreator.type = world.getType("String");
        protectedMemberVariables ~= playlistCreator;

        MemberVariable playlistNumberOfSongs = selectPlaylistImageBean.newMemberVariable("playlistNumberOfSongs");
        playlistNumberOfSongs.type = world.getType("String");
        protectedMemberVariables ~= playlistNumberOfSongs;

        MemberVariable id = selectPlaylistImageBean.newMemberVariable("id");
        id.type = world.getType("String");
        protectedMemberVariables ~= id;

        MemberVariable playlistsHref = selectPlaylistImageBean.newMemberVariable("songsHref");
        playlistsHref.type = world.getType("String");
        protectedMemberVariables ~= playlistsHref;

        MemberFunction getPlaylistImage = selectPlaylistImageBean.newMemberFunction("getPlaylistImage");
        getPlaylistImage.returnType = bitmap;
        abstractMemberFunctions ~= getPlaylistImage;

        MemberFunction setPlaylistImage = selectPlaylistImageBean.newMemberFunction("setPlaylistImage");
        setPlaylistImage.returnType = world.getType("Void");
        setPlaylistImage.addParameter("playlistImage", bitmap);
        abstractMemberFunctions ~= setPlaylistImage;

        MemberFunction getPlaylistTitle = selectPlaylistImageBean.newMemberFunction("getPlaylistTitle");
        getPlaylistTitle.returnType = world.getType("String");
        abstractMemberFunctions ~= getPlaylistTitle;

        MemberFunction setPlaylistTitle = selectPlaylistImageBean.newMemberFunction("setPlaylistTitle");
        setPlaylistTitle.returnType = world.getType("Void");
        setPlaylistTitle.addParameter("playlistTitle", world.getType("String"));
        abstractMemberFunctions ~= setPlaylistTitle;

        MemberFunction getPlaylistCreator = selectPlaylistImageBean.newMemberFunction("getPlaylistCreator");
        getPlaylistCreator.returnType = world.getType("String");
        abstractMemberFunctions ~= getPlaylistCreator;

        MemberFunction setPlaylistCreator = selectPlaylistImageBean.newMemberFunction("setPlaylistCreator");
        setPlaylistCreator.returnType = world.getType("Void");
        setPlaylistCreator.addParameter("playlistCreator", world.getType("String"));
        abstractMemberFunctions ~= setPlaylistCreator;

        MemberFunction getPlaylistNumberOfSongs = selectPlaylistImageBean.newMemberFunction("getPlaylistNumberOfSongs");
        getPlaylistNumberOfSongs.returnType = world.getType("String");
        abstractMemberFunctions ~= getPlaylistNumberOfSongs;

        MemberFunction setPlaylistNumberOfSongs = selectPlaylistImageBean.newMemberFunction("setPlaylistNumberOfSongs");
        setPlaylistNumberOfSongs.returnType = world.getType("Void");
        setPlaylistNumberOfSongs.addParameter("playlistNumberOfSongs", world.getType("String"));
        abstractMemberFunctions ~= setPlaylistNumberOfSongs;

        MemberFunction getId = selectPlaylistImageBean.newMemberFunction("getId");
        getId.returnType = world.getType("String");
        abstractMemberFunctions ~= getId;

        MemberFunction setId = selectPlaylistImageBean.newMemberFunction("setId");
        setId.returnType = world.getType("Void");
        setId.addParameter("id", world.getType("String"));
        abstractMemberFunctions ~= setId;

        MemberFunction getSongsHref = selectPlaylistImageBean.newMemberFunction("getSongsHref");
        getSongsHref.returnType = world.getType("String");
        abstractMemberFunctions ~= getSongsHref;

        MemberFunction setSongsHref = selectPlaylistImageBean.newMemberFunction("setSongsHref");
        setSongsHref.returnType = world.getType("Void");
        setSongsHref.addParameter("songsHref", world.getType("String"));
        abstractMemberFunctions ~= setSongsHref;
}


void addSongBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class songBean = world.getClass("SongBean");

    MemberVariable album = songBean.newMemberVariable("album");
    album.type = world.getType("String");
    protectedMemberVariables ~= album;

    addSetter(album, abstractMemberFunctions, songBean, world);
    addGetter(album, abstractMemberFunctions, songBean, world);

    MemberVariable artist = songBean.newMemberVariable("artist");
    artist.type = world.getType("String");
    protectedMemberVariables ~= artist;

    addSetter(artist, abstractMemberFunctions, songBean, world);
    addGetter(artist, abstractMemberFunctions, songBean, world);

    MemberVariable duration_ms = songBean.newMemberVariable("duration_ms");
    duration_ms.type = world.getType("Int");
    protectedMemberVariables ~= duration_ms;

    addSetter(duration_ms, abstractMemberFunctions, songBean, world);
    addGetter(duration_ms, abstractMemberFunctions, songBean, world);

    MemberVariable id = songBean.newMemberVariable("id");
    id.type = world.getType("String");
    protectedMemberVariables ~= id;

    addSetter(id, abstractMemberFunctions, songBean, world);
    addGetter(id, abstractMemberFunctions, songBean, world);

    MemberVariable name = songBean.newMemberVariable("name");
    name.type = world.getType("String");
    protectedMemberVariables ~= name;

    addSetter(name, abstractMemberFunctions, songBean, world);
    addGetter(name, abstractMemberFunctions, songBean, world);
}

void addLongrunPlanningPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class longrunPlanningPresenter = world.getClass("LongrunPlanningPresenter");

    MemberVariable persistTrainingPlanCase = longrunPlanningPresenter.newMemberVariable("persistTrainingPlanCase");
    persistTrainingPlanCase.type = world.getType("PersistTrainingPlanCase");
    protectedMemberVariables ~= persistTrainingPlanCase;
}

void addIntervalPlanningPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class intervalPlanningPresenter = world.getClass("IntervalPlanningPresenter");

    MemberVariable persistTrainingPlanCase = intervalPlanningPresenter.newMemberVariable("persistTrainingPlanCase");
    persistTrainingPlanCase.type = world.getType("PersistTrainingPlanCase");
    protectedMemberVariables ~= persistTrainingPlanCase;
}

void addPlanWorkoutPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class planWorkoutPresenter = world.getClass("PlanWorkoutPresenter");

    MemberVariable planWorkoutContractView = planWorkoutPresenter.newMemberVariable("planWorkoutContractView");
    planWorkoutContractView.type = world.getType("PlanWorkoutContractView");
    protectedMemberVariables ~= planWorkoutContractView;

    MemberVariable trainingMode = planWorkoutPresenter.newMemberVariable("trainingMode");
    trainingMode.type = world.getType("TrainingMode");
    protectedMemberVariables ~= trainingMode;

    MemberVariable activeFragment = planWorkoutPresenter.newMemberVariable("activeFragment");
    activeFragment.type = world.getType("ActiveFragment");
    protectedMemberVariables ~= activeFragment;

    MemberVariable initializeMediaDataSourceCase = planWorkoutPresenter.newMemberVariable("initializeMediaDataSourceCase");
    initializeMediaDataSourceCase.type = world.getType("InitializeMediaDataSourceCase");
    protectedMemberVariables ~= initializeMediaDataSourceCase;
}

void addSelectPlaylistPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class selectPlaylistPresenter = world.getClass("SelectPlaylistPresenter");

    MemberVariable playlistsCase = selectPlaylistPresenter.newMemberVariable("playlistsCase");
    playlistsCase.type = world.getType("PlaylistsCase");
    protectedMemberVariables ~= playlistsCase;
}

void addWaitForGpsPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class waitForGpsPresenter = world.getClass("WaitForGpsPresenter");

    MemberVariable rxLocation = waitForGpsPresenter.newMemberVariable("rxLocation");
    rxLocation.type = world.getType("RxLocation");
    protectedMemberVariables ~= rxLocation;

    MemberVariable locationRequest = waitForGpsPresenter.newMemberVariable("locationRequest");
    locationRequest.type = world.getType("LocationRequest");
    protectedMemberVariables ~= locationRequest;

    MemberVariable waitForGpsContractView = waitForGpsPresenter.newMemberVariable("waitForGpsContractView");
    waitForGpsContractView.type = world.getType("WaitForGpsContractView");
    protectedMemberVariables ~= waitForGpsContractView;

}

void addFitnessPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class fitnessPresenter = world.getClass("FitnessPresenter");

    MemberVariable fitnessContractView = fitnessPresenter.newMemberVariable("fitnessContractView");
    fitnessContractView.type = world.getType("FitnessContractView");
    protectedMemberVariables ~= fitnessContractView;

    MemberVariable fitnessDataFacade = fitnessPresenter.newMemberVariable("fitnessDataFacade");
    fitnessDataFacade.type = world.getType("FitnessDataFacade");
    protectedMemberVariables ~= fitnessDataFacade;
}

void addLapPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class lapPresenter = world.getClass("LapPresenter");
}

void addPlaylistPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class playlistPresenter = world.getClass("PlaylistPresenter");

    MemberVariable playlistContractView = playlistPresenter.newMemberVariable("playlistContractView");
    playlistContractView.type = world.getType("PlaylistContractView");
    protectedMemberVariables ~= playlistContractView;

    MemberVariable playlistDataFacade = playlistPresenter.newMemberVariable("playlistDataFacade");
    playlistDataFacade.type = world.getType("PlaylistDataFacade");
    protectedMemberVariables ~= playlistDataFacade;
}

void addRunningPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class runningPresenter = world.getClass("RunningPresenter");

    MemberVariable runningContractView = runningPresenter.newMemberVariable("runningContractView");
    runningContractView.type = world.getType("RunningContractView");
    protectedMemberVariables ~= runningContractView;

    MemberVariable runningService = runningPresenter.newMemberVariable("runningService");
    runningService.type = world.getType("RunningService");
    protectedMemberVariables ~= runningService;

    MemberVariable distanceSubject = runningPresenter.newMemberVariable("distanceSubject");
    distanceSubject.type = world.getType("Subject<Double>");
    protectedMemberVariables ~= distanceSubject;

    MemberVariable speedSubject = runningPresenter.newMemberVariable("speedSubject");
    speedSubject.type = world.getType("Subject<Double>");
    protectedMemberVariables ~= speedSubject;

    MemberVariable distanceDisposable = runningPresenter.newMemberVariable("distanceDisposable");
    distanceDisposable.type = world.getType("Disposable");
    protectedMemberVariables ~= distanceDisposable;

    MemberVariable speedDisposable = runningPresenter.newMemberVariable("speedDisposable");
    speedDisposable.type = world.getType("Disposable");
    protectedMemberVariables ~= speedDisposable;

    MemberVariable playlistsCase = runningPresenter.newMemberVariable("playlistsCase");
    playlistsCase.type = world.getType("PlaylistsCase");
    protectedMemberVariables ~= playlistsCase;

    MemberVariable songBeans = runningPresenter.newMemberVariable("songBeans");
    songBeans.type = world.getType("List<SongBean>");
    protectedMemberVariables ~= songBeans;
}

void addStopWatchPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class stopWatchPresenter = world.getClass("StopWatchPresenter");

    MemberVariable stopWatchContractView = stopWatchPresenter.newMemberVariable("stopWatchContractView");
    stopWatchContractView.type = world.getType("StopWatchContractView");
    protectedMemberVariables ~= stopWatchContractView;

    MemberVariable timeMillis = stopWatchPresenter.newMemberVariable("timeMillis");
    timeMillis.type = world.getType("Long");
    protectedMemberVariables ~= timeMillis;

    MemberVariable started = stopWatchPresenter.newMemberVariable("started");
    started.type = world.getType("Bool");
    protectedMemberVariables ~= started;
}

void addStopWatchPresenter_IntervalCounterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){

}

void addStopWatchPresenter_StateMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class state = world.getClass("State");

    MemberFunction start = state.newMemberFunction("start");
    start.returnType = world.getType("Void");

    MemberFunction stop = state.newMemberFunction("stop");
    stop.returnType = world.getType("Void");

    MemberFunction pause = state.newMemberFunction("pause");
    pause.returnType = world.getType("Void");

    MemberFunction lap = state.newMemberFunction("lap");
    lap.returnType = world.getType("Void");

}
void addStartingDisplayPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class startingDisplayPresenter = world.getClass("StartingDisplayPresenter");

    MemberVariable startingDisplayContractView = startingDisplayPresenter.newMemberVariable("startingDisplayContractView");
    startingDisplayContractView.type = world.getType("StartingDisplayContractView");
    protectedMemberVariables ~= startingDisplayContractView;
}



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
