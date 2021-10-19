import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttercircles/pages/home.dart';
import 'package:fluttercircles/pages/sign_in.dart';
import 'package:fluttercircles/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

const simpleTaskKey = "simpleTask";
const simpleDelayedTask = "simpleDelayedTask";
const simplePeriodicTask = "simplePeriodicTask";
const simplePeriodic1HourTask = "simplePeriodic1HourTask";


void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case simpleTaskKey:
        print("$simpleTaskKey was executed. inputData = $inputData");
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("test", true);
        print("Bool from prefs: ${prefs.getBool("test")}");
        break;
      case simpleDelayedTask:
        print("$simpleDelayedTask was executed");
        break;
      case simplePeriodicTask:
        print("$simplePeriodicTask was executed");
        break;
      case simplePeriodic1HourTask:
        print("$simplePeriodic1HourTask was executed");


        break;
      case Workmanager.iOSBackgroundTask:
        print("The iOS background fetch was triggered");
        Directory? tempDir = await getTemporaryDirectory();
        String? tempPath = tempDir?.path;
        print(
            "You can access other plugins in the background, for example Directory.getTemporaryDirectory(): $tempPath");
        break;
    }

    return Future.value(true);
  });

}

void myHeadlessTask(bg.HeadlessEvent headlessEvent) async {
  print('[HeadlessTask]: ${headlessEvent}');

  // Implement a `case` for only those events you're interested in.
  switch(headlessEvent.name) {
    case bg.Event.TERMINATE:
      bg.State state = headlessEvent.event;
      print('- State: ${state}');
      break;
    case bg.Event.HEARTBEAT:
      bg.HeartbeatEvent event = headlessEvent.event;
      print('- HeartbeatEvent: ${event}');
      break;
    case bg.Event.LOCATION:
      bg.Location location = headlessEvent.event;
      print('- Location: ${location}');
      print('HEADLESS');
      print('POTATO');
      print('HEADLESS');
      await Firebase.initializeApp();
      String firebase_user = FirebaseAuth.instance.currentUser!.providerData.single.uid!;
      print(firebase_user);
      Utils().update_user_location_fire(firebase_user, location);

      break;
    case bg.Event.MOTIONCHANGE:
      bg.Location location = headlessEvent.event;
      print('- Location: ${location}');
      break;
    case bg.Event.GEOFENCE:
      bg.GeofenceEvent geofenceEvent = headlessEvent.event;
      print('- GeofenceEvent: ${geofenceEvent}');
      break;
    case bg.Event.GEOFENCESCHANGE:
      bg.GeofencesChangeEvent event = headlessEvent.event;
      print('- GeofencesChangeEvent: ${event}');
      break;
    case bg.Event.SCHEDULE:
      bg.State state = headlessEvent.event;
      print('- State: ${state}');
      break;
    case bg.Event.ACTIVITYCHANGE:
      bg.ActivityChangeEvent event = headlessEvent.event;
      print('ActivityChangeEvent: ${event}');
      break;
    case bg.Event.HTTP:
      bg.HttpEvent response = headlessEvent.event;
      print('HttpEvent: ${response}');
      break;
    case bg.Event.POWERSAVECHANGE:
      bool enabled = headlessEvent.event;
      print('ProviderChangeEvent: ${enabled}');
      break;
    case bg.Event.CONNECTIVITYCHANGE:
      bg.ConnectivityChangeEvent event = headlessEvent.event;
      print('ConnectivityChangeEvent: ${event}');
      break;
    case bg.Event.ENABLEDCHANGE:
      bool enabled = headlessEvent.event;
      print('EnabledChangeEvent: ${enabled}');
      break;
    case bg.Event.NOTIFICATIONACTION:
      String buttonId = headlessEvent.event;
      print('NotificationAction: ${buttonId}');
      break;
  }
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );



//  Workmanager().registerPeriodicTask(
//    "1",
//    simplePeriodic1HourTask,
//    frequency: Duration(seconds: 1),
//  );
  bg.BackgroundGeolocation.registerHeadlessTask(myHeadlessTask);


  runApp(MyApp());

}

class MyApp extends StatelessWidget {





  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        title: 'FlutterShare',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.deepPurpleAccent,
          accentColor: Colors.deepPurpleAccent,
        ),
        home: Home(),
      )
    );
  }
}
