module overall;

import std.stdio : writeln;
import std.typecons;
import std.experimental.logger;

import predefined.types.basictypes;
import model;

import app : appModel;
import next_song_calc : nextSongCalcModel;
import predefined.types.basictypes;


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
    string appPath = "C:\\Users\\0step\\Documents\\Uni_Oldenburg\\Maste_Semester_IV\\Masterarbeit\\app\\masterarbeit_app\\app\\src\\main\\java";
    string nextSongCalcPath = "C:\\Users\\0step\\Documents\\Uni_Oldenburg\\Maste_Semester_IV\\Masterarbeit\\nextsongcalc_degenerated";

	sharedLog = new NoTimeLogger(LogLevel.all);

	bool ret;
	version(unittest) {
		ret = true;
	}
	logf("%s", ret);
	if(!ret){
	    //Basic setup
        auto world = new TheWorld("World");
        addBasicTypes(world);

        //appModel(world);
        //generateJavaApp(world, world.getContainer("App"), appPath);
        nextSongCalcModel(world);
        auto new_song_calculation_system = world.getSoftwareSystem("Next Song Calculation System");
        generateJavaNextSongCalc(world, new_song_calculation_system.getContainer("BinarySearchTreeNextSongCalculationSystem"), nextSongCalcPath);

	}
}

void generateJavaApp(ref TheWorld world, Container containerToGenerate, in string path){
    import generator.java;
    Java java = new Java(world, "C:\\Users\\0step\\Documents\\Uni_Oldenburg\\Maste_Semester_IV\\Masterarbeit\\app\\masterarbeit_app\\app\\src\\main\\java");
    //Java java = new Java(world, "C:\\Users\\0step\\Documents\\Uni_Oldenburg\\Maste_Semester_IV\\Masterarbeit\\app\\generated");
    //Types that are not provided by the genereted classes themselves
    java.newTypeMap["Binder"] = ["android.os.Binder"];
    java.newTypeMap["Bitmap"] = ["android.graphics.Bitmap"];
    java.newTypeMap["BroadcastReceiver"] = ["android.content.BroadcastReceiver"];
    java.newTypeMap["ConnectionStateCallback"] = ["com.spotify.sdk.android.player.ConnectionStateCallback"];
    java.newTypeMap["Consumer"] = ["io.reactivex.functions.Consumer"];
    java.newTypeMap["Context"] = ["android.content.Context"];
    java.newTypeMap["DataPoint"] = ["com.jjoe64.graphview.series.DataPoint"];
    java.newTypeMap["Date"] = ["java.util.Date"];
    java.newTypeMap["Deque"] = ["java.util.Deque"];
    java.newTypeMap["Disposable"] = ["io.reactivex.disposables.Disposable"];
    java.newTypeMap["DisposableObserver"] = ["io.reactivex.observers.DisposableObserver"];
    java.newTypeMap["FragmentManager"] = ["android.support.v4.app.FragmentManager;"];
    java.newTypeMap["Fragment"] = ["android.support.v4.app.Fragment"];
    java.newTypeMap["Interval"] = ["de.uol.smtrain.repository.running_database.entity.Interval"];
    java.newTypeMap["LatLng"] = ["com.google.android.gms.maps.model.LatLng"];
    java.newTypeMap["List"] = ["java.util.List"];
    java.newTypeMap["LocationRequest"] = ["com.google.android.gms.location.LocationRequest"];
    java.newTypeMap["Location"] = ["android.location.Location"];
    java.newTypeMap["Location_"] = ["de.uol.smtrain.repository.running_database.entity.Location_"];
    java.newTypeMap["Map"] = ["java.util.Map"];
    java.newTypeMap["MenuItem"] = ["android.view.MenuItem"];
    java.newTypeMap["NotificationManager"] = ["android.app.NotificationManager"];
    java.newTypeMap["Notification.Action[]"] = ["android.app.Notification"];
    java.newTypeMap["Notification.Builder"] = ["android.app.Notification"];
    java.newTypeMap["Observable"] = ["io.reactivex.Observable"];
    java.newTypeMap["Observer"] = ["io.reactivex.Observer"];
    java.newTypeMap["PagingBean"] = ["de.uol.smtrain.repository.datasource.spotify.rest.beans.PagingBean"];
    java.newTypeMap["Pair"] = ["android.support.v4.util.Pair"];
    java.newTypeMap["Pause"] = ["de.uol.smtrain.repository.running_database.entity.Pause"];
    java.newTypeMap["Player.NotificationCallback"] = ["com.spotify.sdk.android.player.Player"];
    java.newTypeMap["Properties"] = ["java.util.Properties"];
    java.newTypeMap["Queue"] = ["java.util.Queue"];
    java.newTypeMap["ResultReceiver"] = ["android.os.ResultReceiver"];
    java.newTypeMap["RxLocation"] = ["com.patloew.rxlocation.RxLocation"];
    java.newTypeMap["Subject"] = ["io.reactivex.subjects.Subject"];
    java.newTypeMap["Set"] = ["java.util.Set"];
    java.newTypeMap["Service"] = ["android.app.Service"];
    java.newTypeMap["Single"] = ["io.reactivex.Single"];
    java.newTypeMap["SongRecommendationRestApi"] = ["de.uol.smtrain.repository.song_recommendation.SongRecommendationRestApi"];
    java.newTypeMap["SpotifyRestApi"] = ["de.uol.smtrain.repository.datasource.spotify.rest.SpotifyRestApi"];
    java.newTypeMap["SpotifyPlayer"] = ["com.spotify.sdk.android.player.SpotifyPlayer"];
    java.newTypeMap["TrainingSession"] = ["de.uol.smtrain.repository.running_database.entity.TrainingSession"];
    java.newTypeMap["URL"] = ["java.net.URL"];
    java.generate(containerToGenerate);
}

void generateJavaNextSongCalc(ref TheWorld world, Container containerToGenerate, in string path){
    import generator.java;
    Java java = new Java(world, path);
    //java.newTypeMap["SongSample"] = ["de.uol.smtrain.next_song_calculation_system.repository.database.SongSample"];
    java.newTypeMap["List"] = ["java.util.List"];
    java.generate(containerToGenerate);
}
