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

            auto song_recommendation = repository_smtrain.newSubComponent("song_recommendation");

                Class nextSongCalculationResponse = world.newClass("NextSongCalculationResponse", song_recommendation);
                generatedClasses ~= nextSongCalculationResponse;

    //service
    auto service_smtrain = smtrain.newSubComponent("service");

        Class clockServiceInterface = world.newClass("ClockServiceInterface", service_smtrain);
        generatedInterfaces ~= clockServiceInterface;

        Class clockService = world.newClass("ClockService", service_smtrain);
        generatedClasses ~= clockService;

        Class intervalServiceInterface = world.newClass("IntervalServiceInterface", service_smtrain);
        generatedInterfaces ~= intervalServiceInterface;

        Class intervalService = world.newClass("IntervalService", service_smtrain);
        generatedClasses ~= intervalService;

            Class intervalServiceBinder = world.newClass("IntervalServiceBinder", intervalService);
            generatedClasses ~= intervalServiceBinder;

            Class intervalServiceClockConsumer = world.newClass("IntervalServiceClockConsumer", intervalService);
            generatedClasses ~= intervalServiceClockConsumer;

        Class intervalServiceBean = world.newClass("IntervalServiceBean", service_smtrain);
        generatedClasses ~= intervalServiceBean;

        Class locationServiceInterface = world.newClass("LocationServiceInterface", service_smtrain);
        generatedInterfaces ~= locationServiceInterface;

        Class locationService = world.newClass("LocationService", service_smtrain);
        generatedClasses ~= locationService;

            Class locationServiceBinder = world.newClass("LocationServiceBinder", locationService);
            generatedClasses ~= locationServiceBinder;

            Class locationServiceLocationConsumer = world.newClass("LocationServiceLocationConsumer", locationService);
            generatedClasses ~= locationServiceLocationConsumer;

        Class locationBean = world.newClass("LocationBean", service_smtrain);
        generatedClasses ~= locationBean;

        Enum locationBeanFlag = world.newEnum("LocationBeanFlag", service_smtrain);
        locationBeanFlag.addEnumConstant("FirstAfterPause");
        locationBeanFlag.addEnumConstant("LastBeforPause");
        locationBeanFlag.addEnumConstant("InBetween");
        generatedEnums ~= locationBeanFlag;

        Class runningService = world.newClass("RunningService", service_smtrain);
        generatedClasses ~= runningService;

            Class speedConsumer = world.newClass("SpeedConsumer", runningService);
            generatedClasses ~= speedConsumer;

            Class distanceConsumer = world.newClass("DistanceConsumer", runningService);
            generatedClasses ~= distanceConsumer;

            Class locationConsumer = world.newClass("LocationConsumer", runningService);
            generatedClasses ~= locationConsumer;

            Class clockConsumer = world.newClass("ClockConsumer", runningService);
            generatedClasses ~= clockConsumer;

            Class intervalServiceConsumer = world.newClass("IntervalServiceConsumer", runningService);
            generatedClasses ~= intervalServiceConsumer;

            Class playerSongEventConsumer = world.newClass("PlayerSongEventConsumer", runningService);
            generatedClasses ~= playerSongEventConsumer;

            Class runningServiceBinder = world.newClass("RunningServiceBinder", runningService);
            generatedClasses ~= runningServiceBinder;

            Class notificationClickReceiver = world.newClass("NotificationClickReceiver", runningService);
            generatedClasses ~= notificationClickReceiver;

        Class runningServiceInterface = world.newClass("RunningServiceInterface", service_smtrain);
        generatedInterfaces ~= runningServiceInterface;

        Class songServiceBean = world.newClass("SongServiceBean", service_smtrain);
        generatedClasses ~= songServiceBean;

        Class trainingIntervalServiceBean = world.newClass("TrainingIntervalBean", service_smtrain);
        generatedClasses ~= trainingIntervalServiceBean;

        Class intervalInfoBean = world.newClass("IntervalInfoBean", service_smtrain);
        generatedClasses ~= intervalInfoBean;

        Class spotifyPlayerService = world.newClass("SpotifyPlayerService", service_smtrain);
        generatedClasses ~= spotifyPlayerService;

        Class playerService = world.newClass("PlayerService", service_smtrain);
        generatedInterfaces ~= playerService;

        Class playerSongEventBean = world.newClass("PlayerSongEventBean", service_smtrain);
        generatedClasses ~= playerSongEventBean;

        Enum songTimingEvent = world.newEnum("SongTimingEvent", service_smtrain);
        songTimingEvent.addEnumConstant("SONG_STARTED");
        songTimingEvent.addEnumConstant("SONG_PAUSED");
        songTimingEvent.addEnumConstant("SONG_RESUMED");
        songTimingEvent.addEnumConstant("SONG_ENDED");
        generatedEnums ~= songTimingEvent;


    //usecase
    auto useCase_smtrain = smtrain.newSubComponent("use_case");

        auto planTraining_useCase_smtrain = useCase_smtrain.newSubComponent("plan_training");

            Class persistTrainingPlanCase = world.newClass("PersistTrainingPlanCase", planTraining_useCase_smtrain);
            generatedClasses ~= persistTrainingPlanCase;

            Class retrieveTrainingPlanCase = world.newClass("RetrieveTrainingPlanCase", planTraining_useCase_smtrain);
            generatedClasses ~= retrieveTrainingPlanCase;

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

                Class nowPlayingContractPresenter = world.newClass("NowPlayingContractPresenter", running_Contract_UserInterface);
                generatedInterfaces  ~= nowPlayingContractPresenter;

                Class nowPlayingContractView = world.newClass("NowPlayingContractView", running_Contract_UserInterface);
                generatedInterfaces  ~= nowPlayingContractView;

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

            Class lapFacade = world.newClass("LapFacade", facade_UserInterface);
            generatedInterfaces ~= lapFacade;

            Class playlistDataFacade = world.newClass("PlaylistDataFacade", facade_UserInterface);
            generatedInterfaces ~= playlistDataFacade;

            Class mediaMetadataFacade = world.newClass("MediaMetadataFacade", facade_UserInterface);
            generatedInterfaces ~= mediaMetadataFacade;

            Class timeFacade = world.newClass("TimeFacade", facade_UserInterface);
            generatedInterfaces ~= timeFacade;

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

            //running presenters
            auto running_Presenter_UserInteface = presenter_UserInteface.newSubComponent("running");

                Class fitnessPresenter = world.newClass("FitnessPresenter", running_Presenter_UserInteface);
                generatedClasses ~= fitnessPresenter;

                Class lapPresenter = world.newClass("LapPresenter", running_Presenter_UserInteface);
                generatedClasses ~= lapPresenter;

                Class nowPlayingPresenter = world.newClass("NowPlayingPresenter", running_Presenter_UserInteface);
                generatedClasses ~= nowPlayingPresenter;

                Class playlistPresenter = world.newClass("PlaylistPresenter", running_Presenter_UserInteface);
                generatedClasses ~= playlistPresenter;

                Class runningPresenter = world.newClass("RunningPresenter", running_Presenter_UserInteface);
                generatedClasses ~= runningPresenter;

                    Class binderConsumer = world.newClass("BinderConsumer", runningPresenter);
                    generatedClasses ~= binderConsumer;

                    Class stopwatchStateConsumer = world.newClass("StopwatchStateConsumer", runningPresenter);
                    generatedClasses ~= stopwatchStateConsumer;

                Class stopWatchPresenter = world.newClass("StopWatchPresenter", running_Presenter_UserInteface);
                generatedClasses ~= stopWatchPresenter;

                    Class stopWatchPresenter_State = world.newClass("State", stopWatchPresenter);
                    generatedInterfaces ~= stopWatchPresenter_State;

                Enum stopwatchState = world.newEnum("StopwatchState", running_Presenter_UserInteface);
                stopwatchState.addEnumConstant("STARTED");
                stopwatchState.addEnumConstant("PAUSED");
                stopwatchState.addEnumConstant("ENDED");
                generatedEnums ~= stopwatchState;

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
    java.newTypeMap["Binder"] = ["android.os.Binder"];
    java.newTypeMap["Bitmap"] = ["android.graphics.Bitmap"];
    java.newTypeMap["BroadcastReceiver"] = ["android.content.BroadcastReceiver"];
    java.newTypeMap["ConnectionStateCallback"] = ["com.spotify.sdk.android.player.ConnectionStateCallback"];
    java.newTypeMap["Consumer"] = ["io.reactivex.functions.Consumer"];
    java.newTypeMap["Context"] = ["android.content.Context"];
    java.newTypeMap["Date"] = ["java.util.Date"];
    java.newTypeMap["Disposable"] = ["io.reactivex.disposables.Disposable"];
    java.newTypeMap["DisposableObserver"] = ["io.reactivex.observers.DisposableObserver"];
    java.newTypeMap["List"] = ["java.util.List"];
    java.newTypeMap["LocationRequest"] = ["com.google.android.gms.location.LocationRequest"];
    java.newTypeMap["Location"] = ["android.location.Location"];
    java.newTypeMap["MenuItem"] = ["android.view.MenuItem"];
    java.newTypeMap["NotificationManager"] = ["android.app.NotificationManager"];
    java.newTypeMap["Notification.Action[]"] = ["android.app.Notification"];
    java.newTypeMap["Notification.Builder"] = ["android.app.Notification"];
    java.newTypeMap["Observable"] = ["io.reactivex.Observable"];
    java.newTypeMap["Observer"] = ["io.reactivex.Observer"];
    java.newTypeMap["Pair"] = ["android.support.v4.util.Pair"];
    java.newTypeMap["Player.NotificationCallback"] = ["com.spotify.sdk.android.player.Player"];
    java.newTypeMap["Queue"] = ["java.util.Queue"];
    java.newTypeMap["RxLocation"] = ["com.patloew.rxlocation.RxLocation"];
    java.newTypeMap["Subject"] = ["io.reactivex.subjects.Subject"];
    java.newTypeMap["Set"] = ["java.util.Set"];
    java.newTypeMap["Service"] = ["android.app.Service"];
    java.newTypeMap["SpotifyPlayer"] = ["com.spotify.sdk.android.player.SpotifyPlayer"];
    java.newTypeMap["URL"] = ["java.net.URL"];
    java.generate(app);

    //Graphvic gv = new Graphvic(world, "GraphvizOutput");
	//gv.generate();
}

void addCompositions(TheWorld world){
    auto stopWatchPresenter = world.getClass("StopWatchPresenter");
    auto state = world.getClass("State");
    Composition state_StopWatchPresenter_Composition = world.newComposition("State_StopWatchPresenter_Composition", state, stopWatchPresenter);

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
    //Spotify
    addAlbumBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addArtistBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addImageBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    //TODO add paging bean members
    addSpotifyPlaylistBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addPlaylistTrackBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addTrackBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addTracksBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    //NextSongCalcualtion
    addNextSongCalculationResponseMembers(world, protectedMemberVariables, abstractMemberFunctions);


    //service
    addClockServiceInterfaceMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addClockServiceMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addIntervalServiceInterfaceMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addIntervalServiceMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addIntervalServiceBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addIntervalServiceBinderMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addLocationBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addLocationServiceInterfaceMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addLocationServiceMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addLocationServiceBinderMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addPlayerServiceMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addPlayerSongEventBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addSpotifyPlayerServiceMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addRunningServiceInterfaceMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addSongServiceBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addTrainingIntervalBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addIntervalInfoBeanMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addRunningServiceMembers(world, protectedMemberVariables, abstractMemberFunctions);


    //use cases
    addPersistTrainingPlanCaseMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addRetrievePrainingPlanCaseMembers(world, protectedMemberVariables, abstractMemberFunctions);
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
    addNowPlayingContractPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addNowPlayingContractViewMembers(world, protectedMemberVariables, abstractMemberFunctions);
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
    addLapFacadeMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addMediaMetadataFacade(world, protectedMemberVariables, abstractMemberFunctions);
    addPlaylistDataFacadeMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addTimeFacadeMembers(world, protectedMemberVariables, abstractMemberFunctions);


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
    addNowPlayingPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addPlaylistPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addRunningPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
    addStopWatchPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
        addStopWatchPresenter_StateMembers(world, protectedMemberVariables, abstractMemberFunctions);

    //start
    addStartingDisplayPresenterMembers(world, protectedMemberVariables, abstractMemberFunctions);
}

void addExternalTypes(TheWorld world){

    Type consumer_Pair_String_IntervalPlanningBean__ = world.newType("Consumer<Pair<String,IntervalPlanningBean>>");
    consumer_Pair_String_IntervalPlanningBean__.typeToLanguage["Java"] = "Consumer<Pair<String,IntervalPlanningBean>>";

    Type observable_Double_ = world.newType("Observable<Double>");
    observable_Double_.typeToLanguage["Java"] = "Observable<Double>";

    Type observable_Long_ = world.newType("Observable<Long>");
    observable_Long_.typeToLanguage["Java"] = "Observable<Long>";

    Type observable_Integer_ = world.newType("Observable<Integer>");
    observable_Integer_.typeToLanguage["Java"] = "Observable<Integer>";

    Type observable_String_ = world.newType("Observable<String>");
    observable_String_.typeToLanguage["Java"] = "Observable<String>";

    Type observable_StopwatchState_ = world.newType("Observable<StopwatchState>");
    observable_StopwatchState_.typeToLanguage["Java"] = "Observable<StopwatchState>";

    Type observable_Location_ = world.newType("Observable<Location>");
    observable_Location_.typeToLanguage["Java"] = "Observable<Location>";

    Type observable_IntervalServiceBean_ = world.newType("Observable<IntervalServiceBean>");
    observable_IntervalServiceBean_.typeToLanguage["Java"] = "Observable<IntervalServiceBean>";

    Type observable_IntervalInfoBean_ = world.newType("Observable<IntervalInfoBean>");
    observable_IntervalInfoBean_.typeToLanguage["Java"] = "Observable<IntervalInfoBean>";

    Type observable_PlayerSongEventBean_ = world.newType("Observable<PlayerSongEventBean>");
    observable_PlayerSongEventBean_.typeToLanguage["Java"] = "Observable<PlayerSongEventBean>";

    Type observable_URL_ = world.newType("Observable<URL>");
    observable_URL_.typeToLanguage["Java"] = "Observable<URL>";

    Type subject_Double_ = world.newType("Subject<Double>");
    subject_Double_.typeToLanguage["Java"] = "Subject<Double>";

    Type subject_Long_ = world.newType("Subject<Long>");
    subject_Long_.typeToLanguage["Java"] = "Subject<Long>";

    Type subject_Integer_ = world.newType("Subject<Integer>");
    subject_Integer_.typeToLanguage["Java"] = "Subject<Integer>";

    Type subject = world.newType("Subject");
    subject.typeToLanguage["Java"] = "Subject";

    Type subject_LapBean_ = world.newType("Subject<LapBean>");
    subject_LapBean_.typeToLanguage["Java"] = "Subject<LapBean>";

    Type notificationBuilder = world.newType("Notification.Builder");
    notificationBuilder.typeToLanguage["Java"] = "Notification.Builder";

    Type notificationManager = world.newType("NotificationManager");
    notificationManager.typeToLanguage["Java"] = "NotificationManager";

    Type notificationAction = world.newType("Notification.Action[]");
    notificationAction.typeToLanguage["Java"] = "Notification.Action[]";

    Type broadcastReceiver = world.newType("BroadcastReceiver");
    broadcastReceiver.typeToLanguage["Java"] = "BroadcastReceiver";

    Type binder = world.newType("Binder");
    binder.typeToLanguage["Java"] = "Binder";

    Type consumer_FragmentCommand_ = world.newType("Consumer<FragmentCommand>");
    consumer_FragmentCommand_.typeToLanguage["Java"] = "Consumer<FragmentCommand>";

    Type consumer_Binder_ = world.newType("Consumer<Binder>");
    consumer_Binder_.typeToLanguage["Java"] = "Consumer<Binder>";

    Type consumer_StopwatchState_ = world.newType("Consumer<StopwatchState>");
    consumer_StopwatchState_.typeToLanguage["Java"] = "Consumer<StopwatchState>";

    Type consumer_Location_ = world.newType("Consumer<Location>");
    consumer_Location_.typeToLanguage["Java"] = "Consumer<Location>";

    Type location = world.newType("Location");
    location.typeToLanguage["Java"] = "Location";

    Type consumer_Double_ = world.newType("Consumer<Double>");
    consumer_Double_.typeToLanguage["Java"] = "Consumer<Double>";

    Type consumer_Long_ = world.newType("Consumer<Long>");
    consumer_Long_.typeToLanguage["Java"] = "Consumer<Long>";

    Type consumer_Integer_ = world.newType("Consumer<Integer>");
    consumer_Integer_.typeToLanguage["Java"] = "Consumer<Integer>";

    Type consumer_IntervalServiceBean_ = world.newType("Consumer<IntervalServiceBean>");
    consumer_IntervalServiceBean_.typeToLanguage["Java"] = "Consumer<IntervalServiceBean>";

    Type consumer_layerSongEventBean_ = world.newType("Consumer<PlayerSongEventBean>");
    consumer_layerSongEventBean_.typeToLanguage["Java"] = "Consumer<PlayerSongEventBean>";

    Type list_ExternalUrlBean_ = world.newType("List<ExternalUrlBean>");
    list_ExternalUrlBean_.typeToLanguage["Java"] = "List<ExternalUrlBean>";

    Type list_ImageBean_ = world.newType("List<ImageBean>");
    list_ImageBean_.typeToLanguage["Java"] = "List<ImageBean>";

    Type list_ArtistBean_ = world.newType("List<ArtistBean>");
    list_ArtistBean_.typeToLanguage["Java"] = "List<ArtistBean>";

    Type list_IntervalPlanningBean_ = world.newType("List<IntervalPlanningBean>");
    list_IntervalPlanningBean_.typeToLanguage["Java"] = "List<IntervalPlanningBean>";

    Type list_LapBean_ = world.newType("List<LapBean>");
    list_LapBean_.typeToLanguage["Java"] = "List<LapBean>";

    Type list_Integer_ = world.newType("List<Integer>");
    list_Integer_.typeToLanguage["Java"] = "List<Integer>";

    Type list_Long_ = world.newType("List<Long>");
    list_Long_.typeToLanguage["Java"] = "List<Long>";

    Type list_Double_ = world.newType("List<Double>");
    list_Double_.typeToLanguage["Java"] = "List<Double>";

    Type list_SongServiceBean_ = world.newType("List<SongServiceBean>");
    list_SongServiceBean_.typeToLanguage["Java"] = "List<SongServiceBean>";

    Type list_Pair_SongTimingEvent_Long__ = world.newType("List<Pair<SongTimingEvent,Long>>");
    list_Pair_SongTimingEvent_Long__.typeToLanguage["Java"] = "List<Pair<SongTimingEvent,Long>>";

    Type list_TrainingIntervalBean_ = world.newType("List<TrainingIntervalBean>");
    list_TrainingIntervalBean_.typeToLanguage["Java"] = "List<TrainingIntervalBean>";

    Type list_LocationBean_ = world.newType("List<LocationBean>");
    list_LocationBean_.typeToLanguage["Java"] = "List<LocationBean>";

    Type observable_SelectPlaylistImageBean_ = world.newType("Observable<SelectPlaylistImageBean>");
    observable_SelectPlaylistImageBean_.typeToLanguage["Java"] = "Observable<SelectPlaylistImageBean>";

    Type set_SelectPlaylistImageBean_ = world.newType("Set<SelectPlaylistImageBean>");
    set_SelectPlaylistImageBean_.typeToLanguage["Java"] = "Set<SelectPlaylistImageBean>";

    Type bitmap = world.newType("Bitmap");
    bitmap.typeToLanguage["Java"] = "Bitmap";

    Type set_PlaylistBean_ = world.newType("Set<PlaylistBean>");
    set_PlaylistBean_.typeToLanguage["Java"] = "Set<PlaylistBean>";

    Type spotifyPlayer = world.newType("SpotifyPlayer");
    spotifyPlayer.typeToLanguage["Java"] = "SpotifyPlayer";

    Type list_WorkoutElementBean_ = world.newType("List<WorkoutElementBean>");
    list_WorkoutElementBean_.typeToLanguage["Java"] = "List<WorkoutElementBean>";

    Type list_Location_ = world.newType("List<Location>");
    list_Location_.typeToLanguage["Java"] = "List<Location>";

    Type menuItem = world.newType("MenuItem");
    menuItem.typeToLanguage["Java"] = "MenuItem";

    Type observale_SongBean_ = world.newType("Observable<SongBean>");
    observale_SongBean_.typeToLanguage["Java"] = "Observable<SongBean>";

    Type observable_LapBean_ = world.newType("Observable<LapBean>");
    observable_LapBean_.typeToLanguage["Java"] = "Observable<LapBean>";

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

    Type observer_stopwatchState_ = world.newType("Observer<StopwatchState>");
    observer_stopwatchState_.typeToLanguage["Java"] = "Observer<StopwatchState>";

    Type context = world.newType("Context");
    context.typeToLanguage["Java"] = "Context";

    Type queue_String_ = world.newType("Queue<String>");
    queue_String_.typeToLanguage["Java"] = "Queue<String>";

}

void generateGeneralizesRelationships(ref TheWorld world){

    //Service
    Class spotifyPlayerService = world.getClass("SpotifyPlayerService");
    Type service = world.getType("Service");
    world.newGeneralization("SpotifyPlayerService_Service_Generalization", spotifyPlayerService, service);

    Class clockService = world.getClass("ClockService");
    world.newGeneralization("ClockService_Service_Generalization", clockService, service);

    Class runningService = world.getClass("RunningService");
    world.newGeneralization("RunningService_Service_Generalization", runningService, service);

    Class intervalService = world.getClass("IntervalService");
    world.newGeneralization("IntervalService_Service_Generalization", intervalService, service);

    Class locationBean = world.getClass("LocationBean");
    Type location = world.getType("Location");
    world.newGeneralization("LocatioBean_Location_Generalization", locationBean, location);

    Class locationService = world.getClass("LocationService");
    world.newGeneralization("LocationService_Service_Generalization", locationService, service);

    //Binders
    Class runningServiceBinder = world.getClass("RunningServiceBinder");
    Type binder = world.getType("Binder");
    world.newGeneralization("RunningServiceBinder_Binder_Generalization", runningServiceBinder, binder);

    Class intervalServiceBinder = world.getClass("IntervalServiceBinder");
    world.newGeneralization("IntervalServiceBinder_Binder_Generalization", intervalServiceBinder, binder);

    Class locationServiceBinder = world.getClass("LocationServiceBinder");
    world.newGeneralization("LocationServiceBinder_Binder_Generalization", locationServiceBinder, binder);
    ////Broadcast receivers
    //Class notificationClickReceiver = world.getClass("NotificationClickReceiver");
    //Type broadcastReceiver = world.getClass("BroadcastReceiver");
    //world.newGeneralization("NotificationClickReceiver_BroadcastReceiver_Generalization", notificationClickReceiver, broadcastReceiver);
}

void generateImplementsRelationships(ref TheWorld world){

    //Services
    //LocationService
    Class locationService = world.getClass("LocationService");
    Class locationServiceInterface = world.getClass("LocationServiceInterface");
    world.newRealization("LocationService_LocationServiceInterface_Realization", locationService, locationServiceInterface);

    Type consumer_Binder_ = world.getType("Consumer<Binder>");
    world.newRealization("LocationService_Consumer_Binder__Realization", locationService, consumer_Binder_);

    Class locationServiceLocationConsumer = world.getClass("LocationServiceLocationConsumer");
    Type consumer_Location_ = world.getType("Consumer<Location>");
    world.newRealization("LocationServiceLocationConsumer_Consumer_Location__Realization", locationServiceLocationConsumer, consumer_Location_);

    //Interval service
    Class intervalService = world.getClass("IntervalService");
    Class intervalServiceInterface = world.getClass("IntervalServiceInterface");
    world.newRealization("IntervalService_IntervalServiceInterface_Realization", intervalService, intervalServiceInterface);

    world.newRealization("IntervalService_Consumer_Binder__Realization", intervalService, consumer_Binder_);

    Class intervalServiceClockConsumer = world.getClass("IntervalServiceClockConsumer");
    Type consumer_Long_ = world.getType("Consumer<Long>");
    world.newRealization("IntervalServiceClockConsumer_Consumer_Long__", intervalServiceClockConsumer, consumer_Long_);

    //running service
    Class runningService = world.getClass("RunningService");
    Class runningServiceInterface = world.getClass("RunningServiceInterface");
    world.newRealization("RunningService_RunningServiceInterface_Realization", runningService, runningServiceInterface);

    world.newRealization("RunningService_Consumer_Binder__Realization", runningService, consumer_Binder_);

    Type consumer_Double_  = world.getType("Consumer<Double>");
    Class distanceConsumer = world.getClass("DistanceConsumer");
    world.newRealization("DistanceConsumer_Consumer_Double__Realization", distanceConsumer, consumer_Double_);

    Class locationConsumer = world.getClass("LocationConsumer");
    world.newRealization("LocationConsumer_Consumer_Location__Realization", locationConsumer, consumer_Location_);

    Type speedConsumer = world.getClass("SpeedConsumer");
    world.newRealization("SpeedConsumer_Consumer_Double__Realization", speedConsumer, consumer_Double_);

    Class clockConsumer = world.getClass("ClockConsumer");
    world.newRealization("ClockConsumer_Consumer_Long__Realization", clockConsumer, consumer_Long_);

    Class intervalServiceConsumer = world.getClass("IntervalServiceConsumer");
    Type consumer_IntervalServiceBean_ = world.getType("Consumer<IntervalServiceBean>");
    world.newRealization("IntervalServiceConsumer_Consumer_IntervalServiceBean__Realization", intervalServiceConsumer, consumer_IntervalServiceBean_);

    Class playerSongEventConsumer = world.getClass("PlayerSongEventConsumer");
    Type consumer_PlayerSongEventBean_ = world.getType("Consumer<PlayerSongEventBean>");
    world.newRealization("PlayerSongEventConsumer_Consumer_PlayerSongEvent__Realization", playerSongEventConsumer, consumer_PlayerSongEventBean_);

    //Spotify service
    Class spotifyPlayerService = world.getClass("SpotifyPlayerService");
    Class playerService = world.getClass("PlayerService");
    world.newRealization("SpotifyPlayerService_PlayerService_Realization", spotifyPlayerService, playerService);

    Type connectionStateCallback = world.getType("ConnectionStateCallback");
    world.newRealization("SpotifyPlayerService_ConnectionStateCallback_Realization", spotifyPlayerService, connectionStateCallback);

    Type player_NotificationCallback = world.getType("Player.NotificationCallback");
    world.newRealization("SpotifyPlayerService_Player.NotificationCallback_Realization", spotifyPlayerService, player_NotificationCallback);

    Class clockService = world.getClass("ClockService");
    Class clockServiceInterface = world.getClass("ClockServiceInterface");
    world.newRealization("ClockService_ClockServiceInterface_Realization", clockService, clockServiceInterface);

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

    Class nowPlayingPresenter = world.getClass("NowPlayingPresenter");
    Class nowPlayingContractPresenter = world.getClass("NowPlayingContractPresenter");
    world.newRealization("NowPlayingPresenter_NowPlayingContractPresenter_Realization", nowPlayingPresenter, nowPlayingContractPresenter);

    Class runningPresenter = world.getClass("RunningPresenter");
    Class runningContractPresenter = world.getClass("RunningContractPresenter");
    world.newRealization("RunningPresenter_RunningContractPresenter_Realization", runningPresenter, runningContractPresenter);

    Class fitnessDataFacade = world.getClass("FitnessDataFacade");
    world.newRealization("RunningPresenter_FitnessDataFacade_Realization", runningPresenter, fitnessDataFacade);

    Class lapFacade = world.getClass("LapFacade");
    world.newRealization("RunningPresenter_LapFacade_Realization", runningPresenter, lapFacade);

    Class mediaMetadataFacade = world.getClass("MediaMetadataFacade");
    world.newRealization("RunningPresenter_MediaMetadataFacade_Realization", runningPresenter, mediaMetadataFacade);

    Class playlistDataFacade = world.getClass("PlaylistDataFacade");
    world.newRealization("RunningPresenter_PlaylistDataFacade_Realization", runningPresenter, playlistDataFacade);

    Class timeFacade = world.getClass("TimeFacade");
    world.newRealization("RunningPresenter_TimeFacade_Realization", runningPresenter, timeFacade);

    Class binderConsumer = world.getClass("BinderConsumer");
    world.newRealization("BinderConsumer_Consumer_Binder__Realization", binderConsumer, consumer_Binder_);

    Class stopwatchStateConsumer = world.getClass("StopwatchStateConsumer");
    Type consumer_StopwatchState_ = world.getType("Consumer<StopwatchState>");
    world.newRealization("StopwatchStateConsumer_Consumer_StopwatchState__Realization", stopwatchStateConsumer, consumer_StopwatchState_);

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

void addNextSongCalculationResponseMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class nextSongCalculationResponse = world.getClass("NextSongCalculationResponse");

    MemberVariable songId = nextSongCalculationResponse.newMemberVariable("songId");
    songId.type = world.getType("String");
    protectedMemberVariables ~= songId;

    addSetter(songId, abstractMemberFunctions, nextSongCalculationResponse, world);
    addGetter(songId, abstractMemberFunctions, nextSongCalculationResponse, world);
}

void addClockServiceInterfaceMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class clockServiceInterface = world.getClass("ClockServiceInterface");

    MemberFunction start = clockServiceInterface.newMemberFunction("startClock");
    start.returnType = world.getType("Void");

    MemberFunction stop = clockServiceInterface.newMemberFunction("stopClock");
    stop.returnType = world.getType("Void");

    MemberFunction isClockRunning = clockServiceInterface.newMemberFunction("isClockRunning");
    isClockRunning.returnType = world.getType("Bool");

    MemberFunction timeObservable = clockServiceInterface.newMemberFunction("timeObservable");
    timeObservable.returnType = world.getType("Observable<Long>");

}

void addClockServiceMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class clockService = world.getClass("ClockService");

    MemberVariable intervalDisposable = clockService.newMemberVariable("intervalDisposable");
    intervalDisposable.type = world.getType("Disposable");
    protectedMemberVariables ~= intervalDisposable;

    MemberVariable intervalObservable = clockService.newMemberVariable("intervalObservable");
    intervalObservable.type = world.getType("Observable");
    protectedMemberVariables ~= intervalObservable;

    MemberVariable timeMillis = clockService.newMemberVariable("timeMillis");
    timeMillis.type = world.getType("Long");
    protectedMemberVariables ~= timeMillis;

    MemberVariable clockRunning = clockService.newMemberVariable("clockRunning");
    clockRunning.type = world.getType("Bool");
    protectedMemberVariables ~= clockRunning;

    MemberVariable timePublisher = clockService.newMemberVariable("timePublisher");
    timePublisher.type = world.getType("Subject<Long>");
    protectedMemberVariables ~= timePublisher;

}

void addIntervalServiceInterfaceMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class intervalServiceInterface = world.getClass("IntervalServiceInterface");

    MemberFunction intervalServiceObservable = intervalServiceInterface.newMemberFunction("intervalServiceObservable");
    intervalServiceObservable.returnType = world.getType("Observable<IntervalServiceBean>");

    MemberFunction setIntervalServiceData = intervalServiceInterface.newMemberFunction("setIntervalServiceData");
    setIntervalServiceData.returnType = world.getType("Void");
    setIntervalServiceData.addParameter("trainingIntervalBeans", world.getType("List<TrainingIntervalBean>"));

    MemberFunction getSpeedDuringNextTime = intervalServiceInterface.newMemberFunction("getSpeedDuringNextTime");
    getSpeedDuringNextTime.returnType = world.getType("Double");
    getSpeedDuringNextTime.addParameter("timeMs", world.getType("Long"));
}

void addIntervalServiceMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class intervalService = world.getClass("IntervalService");

    MemberVariable intervalServiceBinder = intervalService.newMemberVariable("intervalServiceBinder");
    intervalServiceBinder.type = world.getType("IntervalServiceBinder");
    protectedMemberVariables ~= intervalServiceBinder;

    MemberVariable currentIntervalTime = intervalService.newMemberVariable("currentIntervalTime");
    currentIntervalTime.type = world.getType("Long");
    protectedMemberVariables ~= currentIntervalTime;

    MemberVariable timeAtNewIntervalStart = intervalService.newMemberVariable("timeAtNewIntervalStart");
    timeAtNewIntervalStart.type = world.getType("Long");
    protectedMemberVariables ~= timeAtNewIntervalStart;

    MemberVariable utcIntervalStartTime = intervalService.newMemberVariable("utcIntervalStartTime");
    utcIntervalStartTime.type = world.getType("Long");
    protectedMemberVariables ~= utcIntervalStartTime;

    MemberVariable currentIntervalIndex = intervalService.newMemberVariable("currentIntervalIndex");
    currentIntervalIndex.type = world.getType("Int");
    protectedMemberVariables ~= currentIntervalIndex;

    MemberVariable intervalDurations = intervalService.newMemberVariable("intervalDurations");
    intervalDurations.type = world.getType("List<Long>");
    protectedMemberVariables ~= intervalDurations;

    MemberVariable intervalSpeeds = intervalService.newMemberVariable("intervalSpeeds");
    intervalSpeeds.type = world.getType("List<Double>");
    protectedMemberVariables ~= intervalSpeeds;

    MemberVariable currentIntervalIndexSubject = intervalService.newMemberVariable("currentIntervalIndexSubject");
    currentIntervalIndexSubject.type = world.getType("Subject");
    protectedMemberVariables ~= currentIntervalIndexSubject;
}

void addIntervalServiceBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class intervalServiceBean = world.getClass("IntervalServiceBean");

    MemberVariable start = intervalServiceBean.newMemberVariable("start");
    start.type = world.getType("Long");
    protectedMemberVariables ~= start;

    addSetter(start, abstractMemberFunctions, intervalServiceBean, world);
    addGetter(start, abstractMemberFunctions, intervalServiceBean, world);

    MemberVariable end = intervalServiceBean.newMemberVariable("end");
    end.type = world.getType("Long");
    protectedMemberVariables ~= end;

    addSetter(end, abstractMemberFunctions, intervalServiceBean, world);
    addGetter(end, abstractMemberFunctions, intervalServiceBean, world);

    MemberVariable intervalIndex = intervalServiceBean.newMemberVariable("intervalIndex");
    intervalIndex.type = world.getType("Int");
    protectedMemberVariables ~= intervalIndex;

    addSetter(intervalIndex, abstractMemberFunctions, intervalServiceBean, world);
    addGetter(intervalIndex, abstractMemberFunctions, intervalServiceBean, world);
}

void addIntervalServiceBinderMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class intervalServiceBinder = world.getClass("IntervalServiceBinder");

    MemberFunction getService = intervalServiceBinder.newMemberFunction("getService");
    getService.returnType = world.getType("IntervalService");
    abstractMemberFunctions ~= getService;
}

void addLocationBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class locationBean = world.getClass("LocationBean");

    MemberVariable locationBeanFlag = locationBean.newMemberVariable("locationBeanFlag");
    locationBeanFlag.type = world.getType("LocationBeanFlag");
    protectedMemberVariables ~= locationBeanFlag;

    addSetter(locationBeanFlag, abstractMemberFunctions, locationBean, world);
    addGetter(locationBeanFlag, abstractMemberFunctions, locationBean, world);
}

void addLocationServiceInterfaceMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class locationServiceInterface = world.getClass("LocationServiceInterface");

    MemberFunction distanceObservable = locationServiceInterface.newMemberFunction("distanceObservable");
    distanceObservable.returnType = world.getType("Observable<Double>");

    MemberFunction speedObservable = locationServiceInterface.newMemberFunction("speedObservable");
    speedObservable.returnType = world.getType("Observable<Double>");

    MemberFunction locationObservable = locationServiceInterface.newMemberFunction("locationObservable");
    locationObservable.returnType = world.getType("Observable<Location>");
}

void addLocationServiceMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class locationService = world.getClass("LocationService");

    MemberVariable distanceSubject = locationService.newMemberVariable("distanceSubject");
    distanceSubject.type = world.getType("Subject");
    protectedMemberVariables ~= distanceSubject;

    MemberVariable locationSubject = locationService.newMemberVariable("locationSubject");
    locationSubject.type = world.getType("Subject");
    protectedMemberVariables ~= locationSubject;

    MemberVariable speedSubject = locationService.newMemberVariable("speedSubject");
    speedSubject.type = world.getType("Subject");
    protectedMemberVariables ~= speedSubject;

    MemberVariable locationDisposable = locationService.newMemberVariable("locationDisposable");
    locationDisposable.type = world.getType("Disposable");
    protectedMemberVariables ~= locationDisposable;

    MemberVariable locations = locationService.newMemberVariable("locations");
    locations.type = world.getType("List<Location>");
    protectedMemberVariables ~= locations;

    MemberVariable clockServiceInterface = locationService.newMemberVariable("clockServiceInterface");
    clockServiceInterface.type = world.getType("ClockServiceInterface");
    protectedMemberVariables ~= clockServiceInterface;

}

void addLocationServiceBinderMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class locationServiceBinder = world.getClass("LocationServiceBinder");

    MemberFunction getService = locationServiceBinder.newMemberFunction("getService");
    getService.returnType = world.getType("LocationServiceInterface");
    abstractMemberFunctions ~= getService;
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

    MemberFunction trackInfoObservable = playerService.newMemberFunction("playerSongEventObservable");
    trackInfoObservable.returnType = world.getType("Observable<PlayerSongEventBean>");

    MemberFunction currentSongNameObservable = playerService.newMemberFunction("currentSongNameObservable");
    currentSongNameObservable.returnType = world.getType("Observable<String>");

}

void addPlayerSongEventBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class playerSongEventBean = world.getClass("PlayerSongEventBean");

    MemberVariable songEventList = playerSongEventBean.newMemberVariable("songEventList");
    songEventList.type = world.getType("List<Pair<SongTimingEvent,Long>>");
    protectedMemberVariables ~= songEventList;

    addGetter(songEventList, abstractMemberFunctions, playerSongEventBean, world);

    MemberFunction addSongTimingEvent = playerSongEventBean.newMemberFunction("addSongTimingEvent");
    addSongTimingEvent.returnType = world.getType("Void");
    addSongTimingEvent.addParameter("songTimingEvent", world.getType("SongTimingEvent"));
    addSongTimingEvent.addParameter("time", world.getType("Long"));
    abstractMemberFunctions ~= addSongTimingEvent;

    MemberFunction removeSongTimingEvent = playerSongEventBean.newMemberFunction("removeSongTimingEvent");
    removeSongTimingEvent.returnType = world.getType("Void");
    removeSongTimingEvent.addParameter("index", world.getType("Int"));
    abstractMemberFunctions ~= removeSongTimingEvent;

    MemberVariable songId = playerSongEventBean.newMemberVariable("songId");
    songId.type = world.getType("String");
    protectedMemberVariables ~= songId;

    addGetter(songId, abstractMemberFunctions, playerSongEventBean, world);
    addSetter(songId, abstractMemberFunctions, playerSongEventBean, world);

    MemberFunction getSongStartTime = playerSongEventBean.newMemberFunction("getSongStartTime");
    getSongStartTime.returnType = world.getType("Long");
    abstractMemberFunctions ~= getSongStartTime;

    MemberFunction getSongEndTime = playerSongEventBean.newMemberFunction("getSongEndTime");
    getSongEndTime.returnType = world.getType("Long");
    abstractMemberFunctions ~= getSongEndTime;
}

void addSpotifyPlayerServiceMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class spotifyPlayerService = world.getClass("SpotifyPlayerService");

    MemberVariable playerSongEventBean = spotifyPlayerService.newMemberVariable("playerSongEventBean");
    playerSongEventBean.type = world.getType("PlayerSongEventBean");
    protectedMemberVariables ~= playerSongEventBean;

    MemberVariable playerSongInfoSubject = spotifyPlayerService.newMemberVariable("playerSongEventSubject");
    playerSongInfoSubject.type = world.getType("Subject");
    protectedMemberVariables ~= playerSongInfoSubject;

    MemberVariable currentSongNameSubject = spotifyPlayerService.newMemberVariable("currentSongNameSubject");
    currentSongNameSubject.type = world.getType("Subject");
    protectedMemberVariables ~= currentSongNameSubject;

    MemberVariable queue = spotifyPlayerService.newMemberVariable("queue");
    queue.type = world.getType("Queue<String>");
    protectedMemberVariables ~= queue;

    MemberVariable songTimingDisposable = spotifyPlayerService.newMemberVariable("songTimingDisposable");
    songTimingDisposable.type = world.getType("Disposable");
    protectedMemberVariables ~= songTimingDisposable;

    MemberVariable advanceToCalcNextSong = spotifyPlayerService.newMemberVariable("advanceToCalcNextSong");
    advanceToCalcNextSong.type = world.getType("Long");
    protectedMemberVariables ~= advanceToCalcNextSong;

    MemberVariable currentSongStartedAt = spotifyPlayerService.newMemberVariable("currentSongStartedAt");
    currentSongStartedAt.type = world.getType("Long");
    protectedMemberVariables ~= currentSongStartedAt;

    MemberVariable songUri = spotifyPlayerService.newMemberVariable("songUri");
    songUri.type = world.getType("String");
    protectedMemberVariables ~= songUri;

    MemberVariable currentSongUri = spotifyPlayerService.newMemberVariable("currentSongUri");
    currentSongUri.type = world.getType("String");
    protectedMemberVariables ~= currentSongUri;

    MemberVariable spotifyPlayer = spotifyPlayerService.newMemberVariable("spotifyPlayer");
    spotifyPlayer.type = world.getType("SpotifyPlayer");
    protectedMemberVariables ~= spotifyPlayer;
}

void addRunningServiceMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class runningService = world.getClass("RunningService");

    MemberVariable runningServiceBinder = runningService.newMemberVariable("runningServiceBinder");
    runningServiceBinder.type = world.getType("RunningServiceBinder");
    protectedMemberVariables ~= runningServiceBinder;

    MemberVariable notificationShowing = runningService.newMemberVariable("notificationShowing");
    notificationShowing.type = world.getType("Bool");
    protectedMemberVariables ~= notificationShowing;

    MemberVariable clockJustStarted = runningService.newMemberVariable("clockJustStarted");
    clockJustStarted.type = world.getType("Bool");
    protectedMemberVariables ~= clockJustStarted;

    MemberVariable notifiedPlay = runningService.newMemberVariable("notifiedPlay");
    notifiedPlay.type = world.getType("Bool");
    protectedMemberVariables ~= notifiedPlay;

    MemberVariable currentDistance = runningService.newMemberVariable("currentDistance");
    currentDistance.type = world.getType("Double");
    protectedMemberVariables ~= currentDistance;

    MemberVariable currentSpeed = runningService.newMemberVariable("currentSpeed");
    currentSpeed.type = world.getType("Double");
    protectedMemberVariables ~= currentSpeed;

    MemberVariable currentTime = runningService.newMemberVariable("currentTime");
    currentTime.type = world.getType("Long");
    protectedMemberVariables ~= currentTime;

    MemberVariable averageSpeed = runningService.newMemberVariable("averageSpeed");
    averageSpeed.type = world.getType("Double");
    protectedMemberVariables ~= averageSpeed;

    MemberVariable userAge = runningService.newMemberVariable("userAge");
    userAge.type = world.getType("Int");
    protectedMemberVariables ~= userAge;

    MemberVariable userGender = runningService.newMemberVariable("userGender");
    userGender.type = world.getType("Int");
    protectedMemberVariables ~= userGender;

    MemberVariable userFitnessLevel = runningService.newMemberVariable("userFitnessLevel");
    userFitnessLevel.type = world.getType("Int");
    protectedMemberVariables ~= userFitnessLevel;

    MemberVariable distanceSubject = runningService.newMemberVariable("distanceSubject");
    distanceSubject.type = world.getType("Subject");
    protectedMemberVariables ~= distanceSubject;

    MemberVariable speedSubject = runningService.newMemberVariable("speedSubject");
    speedSubject.type = world.getType("Subject");
    protectedMemberVariables ~= speedSubject;

    MemberVariable clockSubject = runningService.newMemberVariable("clockSubject");
    clockSubject.type = world.getType("Subject");
    protectedMemberVariables ~= clockSubject;

    MemberVariable lapSubject = runningService.newMemberVariable("lapSubject");
    lapSubject.type = world.getType("Subject");
    protectedMemberVariables ~= lapSubject;

    MemberVariable intervalInfoSubject = runningService.newMemberVariable("intervalInfoSubject");
    intervalInfoSubject.type = world.getType("Subject");
    protectedMemberVariables ~= intervalInfoSubject;

    MemberVariable averageSpeedSubject = runningService.newMemberVariable("averageSpeedSubject");
    averageSpeedSubject.type = world.getType("Subject");
    protectedMemberVariables ~= averageSpeedSubject;

    MemberVariable notificationBuilder = runningService.newMemberVariable("notificationBuilder");
    notificationBuilder.type = world.getType("Notification.Builder");
    protectedMemberVariables ~= notificationBuilder;

    MemberVariable notificationManager = runningService.newMemberVariable("notificationManager");
    notificationManager.type = world.getType("NotificationManager");
    protectedMemberVariables ~= notificationManager;

    MemberVariable speedDisposable = runningService.newMemberVariable("speedDisposable");
    speedDisposable.type = world.getType("Disposable");
    protectedMemberVariables ~= speedDisposable;

    MemberVariable clockDisposable = runningService.newMemberVariable("clockDisposable");
    clockDisposable.type = world.getType("Disposable");
    protectedMemberVariables ~= clockDisposable;

    MemberVariable locationDisposable = runningService.newMemberVariable("locationDisposable");
    locationDisposable.type = world.getType("Disposable");
    protectedMemberVariables ~= locationDisposable;

    MemberVariable intervalServiceDisposable = runningService.newMemberVariable("intervalServiceDisposable");
    intervalServiceDisposable.type = world.getType("Disposable");
    protectedMemberVariables ~= intervalServiceDisposable;

    MemberVariable playerEventDisposable = runningService.newMemberVariable("playerEventDisposable");
    playerEventDisposable.type = world.getType("Disposable");
    protectedMemberVariables ~= playerEventDisposable;

    MemberVariable clockServiceInterface = runningService.newMemberVariable("clockServiceInterface");
    clockServiceInterface.type = world.getType("ClockServiceInterface");
    protectedMemberVariables ~= clockServiceInterface;

    MemberVariable intervalServiceInterface = runningService.newMemberVariable("intervalServiceInterface");
    intervalServiceInterface.type = world.getType("IntervalServiceInterface");
    protectedMemberVariables ~= intervalServiceInterface;

    MemberVariable playerService = runningService.newMemberVariable("playerService");
    playerService.type = world.getType("PlayerService");
    protectedMemberVariables ~= playerService;

    MemberVariable notificationClickReceiver = runningService.newMemberVariable("notificationClickReceiver");
    notificationClickReceiver.type = world.getType("NotificationClickReceiver");
    protectedMemberVariables ~= notificationClickReceiver;

    MemberVariable actions = runningService.newMemberVariable("actions");
    actions.type = world.getType("Notification.Action[]");
    protectedMemberVariables ~= actions;

    MemberVariable locationList = runningService.newMemberVariable("locationList");
    locationList.type = world.getType("List<LocationBean>");
    protectedMemberVariables ~= locationList;

    MemberVariable songsToPlay = runningService.newMemberVariable("songsToPlay");
    songsToPlay.type = world.getType("List<SongServiceBean>");
    protectedMemberVariables ~= songsToPlay;

    MemberVariable alreadyPlayedSongs = runningService.newMemberVariable("alreadyPlayedSongs");
    alreadyPlayedSongs.type = world.getType("List<SongServiceBean>");
    protectedMemberVariables ~= alreadyPlayedSongs;

    MemberVariable trainingIntervals = runningService.newMemberVariable("trainingIntervals");
    trainingIntervals.type = world.getType("List<TrainingIntervalBean>");
    protectedMemberVariables ~= trainingIntervals;

    MemberVariable desiredSpeeds = runningService.newMemberVariable("desiredSpeeds");
    desiredSpeeds.type = world.getType("List<Double>");
    protectedMemberVariables ~= desiredSpeeds;
}

void addRunningServiceInterfaceMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class runningServiceInterface = world.getClass("RunningServiceInterface");

    MemberFunction showNotification = runningServiceInterface.newMemberFunction("showNotification");
    showNotification.returnType = world.getType("Void");

    MemberFunction cancelNotification = runningServiceInterface.newMemberFunction("cancelNotification");
    cancelNotification.returnType = world.getType("Void");

    MemberFunction speedObservable = runningServiceInterface.newMemberFunction("speedObservable");
    speedObservable.returnType = world.getType("Observable<Double>");

    MemberFunction distanceObservable = runningServiceInterface.newMemberFunction("distanceObservable");
    distanceObservable.returnType = world.getType("Observable<Double>");

    MemberFunction averageSpeedObservable = runningServiceInterface.newMemberFunction("averageSpeedObservable");
    averageSpeedObservable.returnType = world.getType("Observable<Double>");

    MemberFunction intervalObservable = runningServiceInterface.newMemberFunction("intervalObservable");
    intervalObservable.returnType = world.getType("Observable<IntervalInfoBean>");

    MemberFunction startClock = runningServiceInterface.newMemberFunction("startClock");
    startClock.returnType = world.getType("Void");

    MemberFunction stopClock = runningServiceInterface.newMemberFunction("stopClock");
    stopClock.returnType = world.getType("Void");

    MemberFunction clockObservable = runningServiceInterface.newMemberFunction("clockObservable");
    clockObservable.returnType = world.getType("Observable<Long>");

    MemberFunction setSongsSelection = runningServiceInterface.newMemberFunction("setSongsSelection");
    setSongsSelection.returnType = world.getType("Void");
    setSongsSelection.addParameter("songsSelection", world.getType("List<SongServiceBean>"));

    MemberFunction setTrainingIntervals = runningServiceInterface.newMemberFunction("setTrainingIntervals");
    setTrainingIntervals.returnType = world.getType("Void");
    setTrainingIntervals.addParameter("trainingIntervals", world.getType("List<TrainingIntervalBean>"));

    MemberFunction playSong = runningServiceInterface.newMemberFunction("playSong");
    playSong.addParameter("uri", world.getType("String"));
    playSong.returnType = world.getType("Void");

    MemberFunction enqueueSong = runningServiceInterface.newMemberFunction("enqueueSong");
    enqueueSong.addParameter("uri", world.getType("String"));
    enqueueSong.returnType = world.getType("Void");

    MemberFunction pause = runningServiceInterface.newMemberFunction("pause");
    pause.returnType = world.getType("Void");

    MemberFunction resume = runningServiceInterface.newMemberFunction("resume");
    resume.returnType = world.getType("Void");

}

void addSongServiceBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class songServiceBean = world.getClass("SongServiceBean");

    MemberVariable songId = songServiceBean.newMemberVariable("songId");
    songId.type = world.getType("String");
    protectedMemberVariables ~= songId;

    addSetter(songId, abstractMemberFunctions, songServiceBean, world);
    addGetter(songId, abstractMemberFunctions, songServiceBean, world);

    MemberVariable playerSongEventBean = songServiceBean.newMemberVariable("playerSongEventBean");
    playerSongEventBean.type = world.getType("PlayerSongEventBean");
    protectedMemberVariables ~= playerSongEventBean;

    addSetter(playerSongEventBean, abstractMemberFunctions, songServiceBean, world);
    addGetter(playerSongEventBean, abstractMemberFunctions, songServiceBean, world);
}

void addTrainingIntervalBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class trainingIntervalServiceBean = world.getClass("TrainingIntervalBean");

    MemberVariable durationMs = trainingIntervalServiceBean.newMemberVariable("durationMs");
    durationMs.type = world.getType("Long");
    protectedMemberVariables ~= durationMs;

    addSetter(durationMs, abstractMemberFunctions, trainingIntervalServiceBean, world);
    addGetter(durationMs, abstractMemberFunctions, trainingIntervalServiceBean, world);

    MemberVariable speedMinPerKm = trainingIntervalServiceBean.newMemberVariable("speedMinPerKm");
    speedMinPerKm.type = world.getType("Double");
    protectedMemberVariables ~= speedMinPerKm;

    addSetter(speedMinPerKm, abstractMemberFunctions, trainingIntervalServiceBean, world);
    addGetter(speedMinPerKm, abstractMemberFunctions, trainingIntervalServiceBean, world);
}

void addIntervalInfoBeanMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class intervalInfoBean = world.getClass("IntervalInfoBean");

    MemberVariable distanceDuringInterval = intervalInfoBean.newMemberVariable("distanceDuringInterval");
    distanceDuringInterval.type = world.getType("Double");
    protectedMemberVariables ~= distanceDuringInterval;

    addSetter(distanceDuringInterval, abstractMemberFunctions, intervalInfoBean, world);
    addGetter(distanceDuringInterval, abstractMemberFunctions, intervalInfoBean, world);

    MemberVariable timeDuringInterval = intervalInfoBean.newMemberVariable("timeDuringInterval");
    timeDuringInterval.type = world.getType("Double");
    protectedMemberVariables ~= timeDuringInterval;

    addSetter(timeDuringInterval, abstractMemberFunctions, intervalInfoBean, world);
    addGetter(timeDuringInterval, abstractMemberFunctions, intervalInfoBean, world);

    MemberVariable intervalIndex = intervalInfoBean.newMemberVariable("intervalIndex");
    intervalIndex.type = world.getType("Int");
    protectedMemberVariables ~= intervalIndex;

    addSetter(intervalIndex, abstractMemberFunctions, intervalInfoBean, world);
    addGetter(intervalIndex, abstractMemberFunctions, intervalInfoBean, world);

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

void addRetrievePrainingPlanCaseMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class retrieveTrainingPlanCase = world.getClass("RetrieveTrainingPlanCase");

    MemberVariable planningEntity = retrieveTrainingPlanCase.newMemberVariable("planningEntity");
    planningEntity.type = world.getType("PlanningEntity");
    protectedMemberVariables~= planningEntity;

    MemberFunction trainingPlanObservable = retrieveTrainingPlanCase.newMemberFunction("trainingPlanObservable");
    trainingPlanObservable.returnType = world.getType("Observable<LapBean>");
    abstractMemberFunctions ~= trainingPlanObservable;

    MemberFunction trainingPlanIntervalDurationsObservable = retrieveTrainingPlanCase.newMemberFunction("trainingPlanIntervalDurationsObservable");
    trainingPlanIntervalDurationsObservable.returnType = world.getType("Observable<Integer>");
    abstractMemberFunctions ~= trainingPlanIntervalDurationsObservable;
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
    Class lapContractPresenter = world.getClass("LapContractPresenter");

        MemberFunction getLaps = lapContractPresenter.newMemberFunction("getLaps");
        getLaps.returnType = world.getType("List<LapBean>");
}

void addLapContractViewMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class lapContractView = world.getClass("LapContractView");

    MemberFunction setCurrentLap = lapContractView.newMemberFunction("setCurrentLap");
    setCurrentLap.returnType = world.getType("Void");
    setCurrentLap.addParameter("index", world.getType("Int"));
    setCurrentLap.addParameter("lapBean", world.getType("LapBean"));

}

void addNowPlayingContractPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class nowPlayingContractPresenter = world.getClass("NowPlayingContractPresenter");


}

void addNowPlayingContractViewMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class nowPlayingContractView = world.getClass("NowPlayingContractView");

    MemberFunction updateSongMetadata = nowPlayingContractView.newMemberFunction("updateSongMetadata");
    updateSongMetadata.returnType = world.getType("Void");
    updateSongMetadata.addParameter("songName", world.getType("String"));
    updateSongMetadata.addParameter("albumName", world.getType("String"));
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

    MemberFunction askEndTraining = stopWatchContractView.newMemberFunction("askEndTraining");
    askEndTraining.returnType = world.getType("Observable<StopwatchState>");

}

void addRunningContractPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class runningContractPresenter = world.getClass("RunningContractPresenter");

        MemberFunction viewShowing =  runningContractPresenter.newMemberFunction("viewShowing");
        viewShowing.returnType = world.getType("Void");

        MemberFunction viewHiding =  runningContractPresenter.newMemberFunction("viewHiding");
        viewHiding.returnType = world.getType("Void");
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

void addLapFacadeMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class lapFacade = world.getClass("LapFacade");

    MemberFunction getLaps = lapFacade.newMemberFunction("getLaps");
    getLaps.returnType = world.getType("Observable<LapBean>");

    MemberFunction currentLapObservable = lapFacade.newMemberFunction("currentLapObservable");
    currentLapObservable.returnType = world.getType("Observable<LapBean>");

    MemberFunction getCurrentLapIndex = lapFacade.newMemberFunction("getCurrentLapIndex");
    getCurrentLapIndex.returnType = world.getType("Int");

}

void addMediaMetadataFacade(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class mediaMetadataFacade = world.getClass("MediaMetadataFacade");

    MemberFunction currentSongNameObservable = mediaMetadataFacade.newMemberFunction("currentSongNameObservable");
    currentSongNameObservable.returnType = world.getType("Observable<String>");

    MemberFunction currentSongAlbumObservable =  mediaMetadataFacade.newMemberFunction("currentSongAlbumObservable");
    currentSongAlbumObservable.returnType = world.getType("Observable<String>");

    MemberFunction currentSongAlbumCoverHrefObservable = mediaMetadataFacade.newMemberFunction("currentSongAlbumCoverHrefObservable");
    currentSongAlbumCoverHrefObservable.returnType = world.getType("Observable<URL>");

}

void addPlaylistDataFacadeMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class playlistDataFacade = world.getClass("PlaylistDataFacade");

    MemberFunction getSongsOfSelectedPlaylist = playlistDataFacade.newMemberFunction("getSongsOfSelectedPlaylist");
    getSongsOfSelectedPlaylist.returnType = world.getType("Observable<SongBean>");

}

void addTimeFacadeMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class timeFacade = world.getClass("TimeFacade");

    MemberFunction timeObservable = timeFacade.newMemberFunction("timeObservable");
    timeObservable.returnType = world.getType("Observable<Long>");
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

        MemberVariable desiredSpeed = lapBean.newMemberVariable("desiredSpeed");
        desiredSpeed.type = world.getType("Int");
        protectedMemberVariables ~= desiredSpeed;

        addSetter(desiredSpeed, abstractMemberFunctions, lapBean, world);
        addGetter(desiredSpeed, abstractMemberFunctions, lapBean, world);

        MemberVariable accomplishedSpeed = lapBean.newMemberVariable("accomplishedSpeed");
        accomplishedSpeed.type = world.getType("Int");
        protectedMemberVariables ~= accomplishedSpeed;

        addSetter(accomplishedSpeed, abstractMemberFunctions, lapBean, world);
        addGetter(accomplishedSpeed, abstractMemberFunctions, lapBean, world);

        MemberVariable desiredDistance = lapBean.newMemberVariable("desiredDistance");
        desiredDistance.type = world.getType("Double");
        protectedMemberVariables ~= desiredDistance;

        addSetter(desiredDistance, abstractMemberFunctions, lapBean, world);
        addGetter(desiredDistance, abstractMemberFunctions, lapBean, world);

        MemberVariable accomplishedDistance = lapBean.newMemberVariable("accomplishedDistance");
        accomplishedDistance.type = world.getType("Double");
        protectedMemberVariables ~= accomplishedDistance;

        addSetter(accomplishedDistance, abstractMemberFunctions, lapBean, world);
        addGetter(accomplishedDistance, abstractMemberFunctions, lapBean, world);

        MemberVariable duration = lapBean.newMemberVariable("duration");
        duration.type = world.getType("Int");
        protectedMemberVariables ~= duration;

        addSetter(duration, abstractMemberFunctions, lapBean, world);
        addGetter(duration, abstractMemberFunctions, lapBean, world);

        MemberVariable finished = lapBean.newMemberVariable("finished");
        finished.type = world.getType("Bool");
        protectedMemberVariables ~= finished;

        addSetter(finished, abstractMemberFunctions, lapBean, world);
        addGetter(finished, abstractMemberFunctions, lapBean, world);
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

    MemberVariable lapContractView = lapPresenter.newMemberVariable("lapContractView");
    lapContractView.type = world.getType("LapContractView");
    protectedMemberVariables ~= lapContractView;

    MemberVariable retrieveTrainingPlanCase = lapPresenter.newMemberVariable("retrieveTrainingPlanCase");
    retrieveTrainingPlanCase.type = world.getType("RetrieveTrainingPlanCase");
    protectedMemberVariables ~= retrieveTrainingPlanCase;

    MemberVariable lapFacade = lapPresenter.newMemberVariable("lapFacade");
    lapFacade.type = world.getType("LapFacade");
    protectedMemberVariables ~= lapFacade;
}

void addNowPlayingPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class nowPlayingPresenter = world.getClass("NowPlayingPresenter");

    MemberVariable nowPlayingContractView = nowPlayingPresenter.newMemberVariable("nowPlayingContractView");
    nowPlayingContractView.type = world.getType("NowPlayingContractView");
    protectedMemberVariables ~= nowPlayingContractView;

    MemberVariable mediaMetadataFacade = nowPlayingPresenter.newMemberVariable("mediaMetadataFacade");
    mediaMetadataFacade.type = world.getType("MediaMetadataFacade");
    protectedMemberVariables ~= mediaMetadataFacade;

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

    MemberVariable runningServiceInterface = runningPresenter.newMemberVariable("runningServiceInterface");
    runningServiceInterface.type = world.getType("RunningServiceInterface");
    protectedMemberVariables ~= runningServiceInterface;

    MemberVariable distanceSubject = runningPresenter.newMemberVariable("distanceSubject");
    distanceSubject.type = world.getType("Subject<Double>");
    protectedMemberVariables ~= distanceSubject;

    MemberVariable speedSubject = runningPresenter.newMemberVariable("speedSubject");
    speedSubject.type = world.getType("Subject<Double>");
    protectedMemberVariables ~= speedSubject;

    MemberVariable timeSubject = runningPresenter.newMemberVariable("timeSubject");
    timeSubject.type = world.getType("Subject<Long>");
    protectedMemberVariables ~= timeSubject;

    MemberVariable lapSubject = runningPresenter.newMemberVariable("lapSubject");
    lapSubject.type = world.getType("Subject<LapBean>");
    protectedMemberVariables ~= lapSubject;

    MemberVariable distanceDisposable = runningPresenter.newMemberVariable("distanceDisposable");
    distanceDisposable.type = world.getType("Disposable");
    protectedMemberVariables ~= distanceDisposable;

    MemberVariable speedDisposable = runningPresenter.newMemberVariable("speedDisposable");
    speedDisposable.type = world.getType("Disposable");
    protectedMemberVariables ~= speedDisposable;

    MemberVariable timeDisposable = runningPresenter.newMemberVariable("timeDisposable");
    timeDisposable.type = world.getType("Disposable");
    protectedMemberVariables ~= timeDisposable;

    MemberVariable lapDisposable = runningPresenter.newMemberVariable("lapDisposable");
    lapDisposable.type = world.getType("Disposable");
    protectedMemberVariables ~= lapDisposable;

    MemberVariable playlistsCase = runningPresenter.newMemberVariable("playlistsCase");
    playlistsCase.type = world.getType("PlaylistsCase");
    protectedMemberVariables ~= playlistsCase;

    MemberVariable retrieveTrainingPlanCase = runningPresenter.newMemberVariable("retrieveTrainingPlanCase");
    retrieveTrainingPlanCase.type = world.getType("RetrieveTrainingPlanCase");
    protectedMemberVariables ~= retrieveTrainingPlanCase;

    MemberVariable songBeans = runningPresenter.newMemberVariable("songBeans");
    songBeans.type = world.getType("List<SongBean>");
    protectedMemberVariables ~= songBeans;

    MemberVariable lapBeans = runningPresenter.newMemberVariable("lapBeans");
    lapBeans.type = world.getType("List<LapBean>");
    protectedMemberVariables ~= lapBeans;

    MemberVariable currentLapIndex = runningPresenter.newMemberVariable("currentLapIndex");
    currentLapIndex.type = world.getType("Int");
    protectedMemberVariables ~= currentLapIndex;

    MemberVariable serviceStarted = runningPresenter.newMemberVariable("serviceStarted");
    serviceStarted.type = world.getType("Bool");
    protectedMemberVariables ~= serviceStarted;

    MemberVariable context = runningPresenter.newMemberVariable("context");
    context.type = world.getType("Context");
    protectedMemberVariables ~= context;

    MemberVariable binderConsumer = runningPresenter.newMemberVariable("binderConsumer");
    binderConsumer.type = world.getClass("BinderConsumer");
    protectedMemberVariables ~= binderConsumer;

    MemberVariable runningServiceDisposable = runningPresenter.newMemberVariable("runningServiceDisposable");
    runningServiceDisposable.type = world.getType("Disposable");
    protectedMemberVariables ~= runningServiceDisposable;

}

void addStopWatchPresenterMembers(ref TheWorld world, ref MemberVariable[] protectedMemberVariables, ref MemberFunction[] abstractMemberFunctions){
    Class stopWatchPresenter = world.getClass("StopWatchPresenter");

    MemberVariable stopWatchContractView = stopWatchPresenter.newMemberVariable("stopWatchContractView");
    stopWatchContractView.type = world.getType("StopWatchContractView");
    protectedMemberVariables ~= stopWatchContractView;

    MemberVariable timeMillis = stopWatchPresenter.newMemberVariable("timeMillis");
    timeMillis.type = world.getType("Long");
    protectedMemberVariables ~= timeMillis;

    MemberVariable stopwatchStateSubject = stopWatchPresenter.newMemberVariable("stopwatchStateObserver");
    stopwatchStateSubject.type = world.getType("Observer<StopwatchState>");
    protectedMemberVariables ~= stopwatchStateSubject;

    MemberVariable stopwatchStateConsumer = stopWatchPresenter.newMemberVariable("stopwatchStateConsumer");
    stopwatchStateConsumer.type = world.getType("Consumer<StopwatchState>");
    protectedMemberVariables ~= stopwatchStateConsumer;
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
