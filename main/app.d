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


    //TODO protection and container type has to be defined
    //Basic setup
    auto world = new TheWorld("World");
    addBasicTypes(world);
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

    auto de = app.newComponent("de");
    auto uol = de.newSubComponent("uol");
    auto smtrain = uol.newSubComponent("smtrain");

    auto userInterface = smtrain.newSubComponent("user_interface");
        auto contract_UserInterface = userInterface.newSubComponent("contract");
            auto planning_Contract_UserInterface = contract_UserInterface.newSubComponent("planning");
        auto view_UserInterface = userInterface.newSubComponent("view");
            auto planning_View_UserInterface = view_UserInterface.newSubComponent("planning");
            auto review_View_UserInterface = view_UserInterface.newSubComponent("review");
            auto running_View_UserInterface = view_UserInterface.newSubComponent("running");
            auto start_View_UserInterface = view_UserInterface.newSubComponent("start");
        auto presenter_UserInteface = userInterface.newSubComponent("presenter");
            auto planning_Presenter_UserInterface = presenter_UserInteface.newSubComponent("planning");

    //fill user interface components
    //planning
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

        Class selectPlaylistBean_SelectPlaylist_Fragment_Planning_View_UserInterface = world.newClass("SelectPlaylistBean", selectPlaylist_Fragment_Planning_View_UserInterface);
        notGeneratedClasses ~= selectPlaylistBean_SelectPlaylist_Fragment_Planning_View_UserInterface;

        Class selectPlaylistFragment_SelectPlaylist_Fragment_Planning_View_UserInterface = world.newClass("SelectPlaylistFragment", selectPlaylist_Fragment_Planning_View_UserInterface);
        notGeneratedClasses ~= selectPlaylistFragment_SelectPlaylist_Fragment_Planning_View_UserInterface;

        Class selectPlaylistViewHolder_SlectPlaylist_Fragment_Planning_View_UserInterface = world.newClass("SelectPlaylistViewHolder", selectPlaylist_Fragment_Planning_View_UserInterface);
        notGeneratedClasses ~= selectPlaylistViewHolder_SlectPlaylist_Fragment_Planning_View_UserInterface;

        auto trainingTypeInterval_Fragment_Planning_View_UserInterface = fragment_Planning_View_UserInterface.newSubComponent("training_type_interval");
        Class intervalPlanningAdapter_TrainingTypeInterval_Fragment_Planning_View_UserInterface = world.newClass("IntervalPlanningAdapter", trainingTypeInterval_Fragment_Planning_View_UserInterface);
        notGeneratedClasses ~= intervalPlanningAdapter_TrainingTypeInterval_Fragment_Planning_View_UserInterface;

        Class intervalPlanningBean_TrainingTypeInterval_Fragment_Planning_View_UserInterface = world.newClass("IntervalPlanningBean", trainingTypeInterval_Fragment_Planning_View_UserInterface);
        notGeneratedClasses ~= intervalPlanningBean_TrainingTypeInterval_Fragment_Planning_View_UserInterface;

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

    Class songBean_MediaPlayer_running_View_UserInterface = world.newClass("SongBean", mediaPlayer_running_View_UserInterface);
    notGeneratedClasses ~= songBean_MediaPlayer_running_View_UserInterface;

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

        Class lapBean_Lap_Stopwatch_Running_View_UserInterface = world.newClass("LapBean", lap_Stopwatch_Running_View_UserInterface);
        notGeneratedClasses ~= lapBean_Lap_Stopwatch_Running_View_UserInterface;

        Class lapFragment_Lap_Stopwatch_Running_View_UserInterface = world.newClass("LapFragment", lap_Stopwatch_Running_View_UserInterface);
        notGeneratedClasses ~= lapFragment_Lap_Stopwatch_Running_View_UserInterface;

        Class lapViewHolder_Lap_Stopwatch_Running_View_UserInterface = world.newClass("LapViewHolder", lap_Stopwatch_Running_View_UserInterface);
        notGeneratedClasses ~= lapViewHolder_Lap_Stopwatch_Running_View_UserInterface;

    //start
    Class startingDisplayActivity_Start_View_UserInterface = world.newClass("StartingDisplayActivity", start_View_UserInterface);
    notGeneratedClasses ~= startingDisplayActivity_Start_View_UserInterface;

    Class startingDisplayOptionsFragment_Start_View_UserInterface = world.newClass("StartingDisplayOptionsFragment", start_View_UserInterface);
    notGeneratedClasses ~= startingDisplayOptionsFragment_Start_View_UserInterface;

    Class startingDisplayPreferencesFragment_Start_View_UserInterface = world.newClass("StartingDisplayPreferencesFragment", start_View_UserInterface);
    notGeneratedClasses ~= startingDisplayPreferencesFragment_Start_View_UserInterface;
    //more inner workings
    //auto useCase = app.newComponent("use_case");
    //auto entities = app.newComponent("entities");

    //Class level
    //Add selectPlaylistPresneter class to planning_presenter_UserInterface
    Class selectPlaylistPresenter = world.newClass("SelectPlaylistPresenter", planning_Presenter_UserInterface);
    selectPlaylistPresenter.containerType["Java"] = "class";
    selectPlaylistPresenter.typeToLanguage["Java"] = selectPlaylistPresenter.name;
    selectPlaylistPresenter.protection["Java"] = "public";

    Class selectPlaylistView = world.newClass("SelectPlaylistView", planning_View_UserInterface);
    selectPlaylistView.containerType["Java"] = "class";
    selectPlaylistView.typeToLanguage["Java"] = selectPlaylistView.name;
    selectPlaylistView.protection["Java"] = "public";
    selectPlaylistView.doNotGenerate = DoNotGenerate.yes;

    Class selectPlaylistContract = world.newClass("SelectPlaylistContract", planning_Contract_UserInterface);
    selectPlaylistContract.containerType["Java"] = "interface";
    selectPlaylistContract.typeToLanguage["Java"] = selectPlaylistContract.name;
    selectPlaylistContract.protection["Java"] = "public";

        //members
        MemberVariable playlistView = selectPlaylistPresenter.newMemberVariable("playlistView");
        playlistView.type = world.getType("SelectPlaylistFragment");
        playlistView.type.typeToLanguage["Java"] = playlistView.type.name;
        playlistView.protection["Java"] = "private";
        playlistView.langSpecificAttributes["Java"] = [];

        //member functions
        MemberFunction fillPlaylistFunction = selectPlaylistPresenter.newMemberFunction("fillPlaylist");
        fillPlaylistFunction.returnType = voidType;

    notGeneratedClasses.modifyElements!(Class, Class function(Class))([&setDoNotGenerateFlagToNo!(Class), &setProtectionToJavaPublic!(Class), &setContainerTypeToJavaClass!(Class), &setModelTypeNameAsJavaClassName!(Class)]);

    Java java = new Java(world, "java_code");
    java.generate(app);

    //Graphvic gv = new Graphvic(world, "GraphvizOutput");
	//gv.generate();
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

T setDoNotGenerateFlagToNo(T : Class)(T clazz){
    clazz.doNotGenerate = DoNotGenerate.no;
    return clazz;
}

T setContainerTypeToJavaClass(T : Class)(T clazz){
    clazz.containerType["Java"] = "class";
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

T setModelTypeNameAsJavaClassName(T : Type)(T type){
    type.typeToLanguage["Java"] = type.name;
    return type;
}





void fun() {
	auto world = new TheWorld("TheWorld");
	addBasicTypes(world);

	Actor users = world.newActor("The Users");
	users.description = "This is a way to long description for something "
		~ "that should be obvious.";

	Actor admin = world.newActor("The Admin");
	admin.description = "An admin does what an admin does.";

	auto system = world.newSoftwareSystem("AwesomeSoftware");
	system.description = "The awesome system to develop.";
	Container frontend = system.newContainer("Frontend");
	frontend.technology = "Angular";
	auto frontendUserCtrl = frontend.newComponent("frontUserCtrl");
	auto frontendStuffCtrl = frontend.newComponent("frontStuffCtrl");
	initAngularBaseClasses(world, frontendUserCtrl, frontendStuffCtrl);

	auto app = genAngularComponent("Main", world, frontendUserCtrl);

	auto hardware = world.newHardwareSystem("SomeHardware");

	auto system2 = world.newSoftwareSystem("LagacySoftwareSystem");
	system2.description = "You don't want to touch this.";

	auto usersFrontend = world.newConnection("userDepFrontend",
		world.getActor("The Users"), frontendUserCtrl
	);
	usersFrontend.description = "Uses the frontend to do stuff.";
	world.newConnection("userDepStuffCtrl",
		users, frontendStuffCtrl
	).description = "Uses the Stuff Logic of the Awesome Software";
	usersFrontend.description = "Uses the frontend to do stuff.";

	{
		const(TheWorld) cw = world;
		const(Actor) ca = world.getActor("The Users");
		assert(ca !is null);
	}

	world.newConnection("adminUser",
		admin, frontendUserCtrl
	).description = "Manager Users";

	Container server = system.newContainer("Server");
	server.technology = "D";
	world.newConnection("frontendServerDep", frontend, server)
		.description = "HTTPS";

	world.newConnection("serverSS2", server, system2).description =
		"To bad we have to use that.";

	auto serverUserCtrl = server.newComponent("serverUserCtrl");
	auto frontendHardwareLink = world.newConnection("frontendUsesHardware",
		serverUserCtrl, hardware
	);

	auto serverUserSub = serverUserCtrl.newSubComponent("utils").
		description = "Best component name ever!";

	auto database = system.newContainer("Database");
	database.technology = "MySQL";
	world.newConnection("serverDatabase",
		server, database
	).description = "CRUD";

	Type str = world.getType("String");
	Type integer = world.getType("Int");

	Class user = userClass(world, frontendUserCtrl, serverUserCtrl, database);
	Class group = groupClass(world, frontendUserCtrl, serverUserCtrl, database);

	Class address = addressClass(world,
		frontendUserCtrl, serverUserCtrl, database
	);

	userCtrl(world, server);

	MemberFunction func = address.newMemberFunction("func");
	func.returnType = integer;

	func.addParameter("a", integer);
	func.addParameter("b", str);

	Aggregation userAddress = world.newAggregation("AddressUser",
		address, user
	);

	Class postalCode = world.newClass("PostalCode", database,
			serverUserCtrl);
	postalCode.containerType["MySQL"] = "Table";
	MemberVariable pcID = postalCode.newMemberVariable("id");
	pcID.type = integer;
	pcID.addLangSpecificAttribute("MySQL", "PRIMARY KEY");
	pcID.addLangSpecificAttribute("MySQL", "AUTO INCREMENT");
	pcID.addLangSpecificAttribute("D", "const");
	MemberVariable pcCode = postalCode.newMemberVariable("code");
	pcCode.type = integer;

	auto addressPC = world.newComposition("addressPostalCode",
		address, postalCode
	);
	addressPC.fromType = world.newType("PostalCode[]");
	addressPC.fromType.typeToLanguage["D"] = "PostalCode[]";

	Class userInfo = genAngularService("UserInfo", world, frontendUserCtrl);

	Graphvic gv = new Graphvic(world, "GraphvizOutput");
	gv.generate();

	//MySQL mysql = new MySQL(world, "MySQL");
	//mysql.generate(database);

	//auto vibed = new VibeD(world, "VibeTestProject");
	//vibed.generate();

	//auto angular = new Angular(world, "Frontend");
	//angular.generate();
}
