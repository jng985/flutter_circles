import 'dart:async';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercircles/cov/CategorySelector.dart';
import 'package:fluttercircles/cov/account.dart';
import 'package:fluttercircles/cov/carousel.dart';
import 'package:fluttercircles/cov/journal.dart';
import 'package:fluttercircles/models/user.dart';
import 'package:fluttercircles/pages/my_circles.dart';
import 'package:fluttercircles/pages/profile.dart';
import 'package:fluttercircles/pages/search.dart';
import 'package:fluttercircles/pages/sign_in.dart';
import 'package:fluttercircles/pages/home.dart';
import 'package:fluttercircles/pages/timeline.dart';
import 'package:fluttercircles/pages/upload.dart';
import 'package:fluttercircles/utils.dart';
import 'package:fluttercircles/widgets/mymap.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';


import 'package:workmanager/workmanager.dart';
import 'package:fluttercircles/utils.dart';
import 'activity_feed.dart';
import 'activity_feed2.dart';
import 'create_circle.dart';

const simplePeriodic1HourTask = "simplePeriodic1HourTask";


class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final Location location = Location();

  LocationData? _location;
  StreamSubscription<LocationData>? _locationSubscription;
  String? _error;

//  @override
//  void dispose() {
//    _locationSubscription?.cancel();
//    setState(() {
//      _locationSubscription = null;
//    });
//    super.dispose();
//  }


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
        print('HEADLESS');
        print('HEADLESS');
//      String firebase_user = FirebaseAuth.instance.currentUser!.providerData.single.uid!;
//      Utils().update_user_location_fire(firebase_user, LatLng(location.coords.latitude, location.coords.longitude), location.timestamp, 5);

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



  @override
  void initState() {
//    _listenLocation();
//    bg.BackgroundGeolocation.registerHeadlessTask(myHeadlessTask);
    super.initState();


    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      print('[location] - $location');
//      print(location.coords.latitude);
      print('yea');
      print('yea');
      print('yea');
      print('yea');
      print('yea');
      Utils().update_user_location_fire(firebase_user, location);
    });

    // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      print('[motionchange] - $location');
    });

    // Fired whenever the state of location-services changes.  Always fired at boot
    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      print('[providerchange] - $event');
    });

    ////
    // 2.  Configure the plugin
    //
    bg.BackgroundGeolocation.ready(bg.Config(
        enableHeadless: true,
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10.0,
        stopOnTerminate: false,
        startOnBoot: true,
        debug: true,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE
    )).then((bg.State state) {
      if (!state.enabled) {
        ////
        // 3.  Start the plugin.
        //
        bg.BackgroundGeolocation.start();
      }
    });

  }
  late LatLng myloc;

  int pageIndex = 0;
  PageController pageController = PageController();

  final firebase_user = FirebaseAuth.instance.currentUser!.providerData.single.uid!;




//  MyUser currentUser = MyUser(id: firebase_user.uid!, username: username, email: email, photoUrl: photoUrl, displayName: displayName, bio: bio);

  Widget buildAuthScreen2() {
    return Scaffold(
      body: PageView(
        children: <Widget>[

//          Timeline(),
//          ActivityFeed2(),

//          RaisedButton(
//            child: Text("Page 3"),
//            onPressed: () async {
//              print(FirebaseAuth.instance.currentUser?.providerData.single.uid);
////              print(firebase_user);
////              Workmanager().registerPeriodicTask(
////                "1",
////                simplePeriodic1HourTask,
////                frequency: Duration(minutes: 15),
////              );
//              LatLng lastMapPosition = await Utils().get_user_location();
//              print(lastMapPosition);
//              Utils().update_user_location_fire(firebase_user, lastMapPosition);
//              print('WHAAAAT');
//
//            },
//          ),
//          Circle(),
//        Upload(),
//        MyMap(),
          MyCircles(),
          Account(),
//          MyCircles(),
          Search(),

//        CircleCarousel(),
//          Account(),
          Profile(profileId: firebase_user),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              primary: Colors.white70,
              onPrimary: Colors.deepPurple,
              minimumSize: Size(double.infinity, 130),
            ),
            icon: FaIcon(FontAwesomeIcons.google),
            label: Text(" LOGOUT", style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.w400, fontSize: 24),),
            onPressed: () {
//                _stopListen();
                Provider.of<GoogleSignInProvider>(context, listen: false).googleLogout();
//              final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
//              provider.googleLogout();

              print(FirebaseAuth.instance.currentUser);


            },
          ),


        ],
        controller: pageController,
        onPageChanged: (index) {


          print("Page Changed $index");

        },
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: (index) {
          setState(() {
            pageController.jumpToPage(index);
            pageIndex = index;
          });
        },
        activeColor: Theme.of(context).primaryColor.withOpacity(0.8),
        items: [
//          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
//          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),

//          BottomNavigationBarItem(icon: Icon(Icons.photo_camera)),
//          BottomNavigationBarItem(icon: Icon(Icons.map)),
          BottomNavigationBarItem(icon: Icon(Icons.people)),
          BottomNavigationBarItem(icon: Icon(Icons.event)),
//          BottomNavigationBarItem(icon: Icon(Icons.people)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),


          BottomNavigationBarItem(icon: Icon(Icons.logout)),
        ],
      ),
    );
  }

//  get_init_data() async {
//    LatLng data = await Utils().get_user_location();
//    return data;
//  }
  Future<void> _stopListen() async {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  Future<void> _listenLocation() async {
    print(await location.isBackgroundModeEnabled());
    location.enableBackgroundMode();
    location.changeSettings(
      interval: 2000,
      distanceFilter: 20
    );
    _locationSubscription =
        location.onLocationChanged.handleError((dynamic err) {
          if (err is PlatformException) {
            setState(() {
              _error = err.code;
            });
          }
          _locationSubscription?.cancel();
          setState(() {
            _locationSubscription = null;
          });
        }).listen((LocationData currentLocation) {
          setState(() {
            _error = null;

            _location = currentLocation;
//            Utils().update_user_location_fire(
//                firebase_user,
//                LatLng(currentLocation.latitude!,currentLocation.longitude!),
//                currentLocation.time!.,
//                currentLocation.speed!
//            );
//            print("LOCATION WRITE");
//            print("LOCATION CHANGE");
//            print(currentLocation);
//            if (currentLocation.time != null) {
//                print(currentLocation.time);
//              print(DateTime.fromMillisecondsSinceEpoch(currentLocation.time!.toInt()));
//            }
          });
        });
//    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
//    print(get_init_data());
//    return StreamProvider<LatLng>(
//        create: (context) => LocationService().locationStream,
//        builder: (context) {
//          return Text("hi");
//        },
//        child: buildAuthScreen2(),
//    child:
//    child: buildAuthScreen2(),
//      initialData: LatLng(41.7227753, -73.89059728),
//    );
    return buildAuthScreen2();
  }
}