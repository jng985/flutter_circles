import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercircles/models/user.dart';
import 'package:fluttercircles/pages/activity_feed.dart';
import 'package:fluttercircles/pages/circle_screen.dart';
import 'package:fluttercircles/pages/create_account.dart';
import 'package:fluttercircles/pages/create_circle.dart';
import 'package:fluttercircles/pages/myhome.dart';
import 'package:fluttercircles/pages/profile.dart';
import 'package:fluttercircles/pages/search.dart';
import 'package:fluttercircles/pages/sign_in.dart';
import 'package:fluttercircles/pages/timeline.dart';
import 'package:fluttercircles/pages/upload.dart';
import 'package:fluttercircles/utils.dart';
import 'package:fluttercircles/widgets/progress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:provider/provider.dart';


//final GoogleSignIn googleSignIn = GoogleSignIn();
final firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance.ref();
final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');
final circlesRef = FirebaseFirestore.instance.collection('circles');
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final followersRef = FirebaseFirestore.instance.collection('followers');
final locationsRef = FirebaseFirestore.instance.collection('locations');
final userCirclesRef = FirebaseFirestore.instance.collection('userCircles');
final circlePlacesRef = FirebaseFirestore.instance.collection('circlePlaces');
final circleLocationsRef = FirebaseFirestore.instance.collection('circleLocations');

final timestamp = DateTime.now();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {


  int pageIndex = 0;
  PageController pageController = PageController();


  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Widget buildAuthScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Gram'),
      ),
      body: PageView(
        controller: pageController,
        children: [
          Text('Timeline'),
          Text('Search'),
          Text('Post'),
          Text('Notifications'),
          Text('Profile'),
        ],
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          this.pageIndex = index;
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: this.pageIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: (index) {
          setState(() {
            this.pageIndex = index;
          });
          pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home),label: "hi"),
          BottomNavigationBarItem(icon: Icon(Icons.search),label: "search"),
          BottomNavigationBarItem(
              label: "photo",
              icon: Icon(
                Icons.photo_camera,
                size: 32,
              )),
          BottomNavigationBarItem(icon: Icon(Icons.notifications),label: "notif"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle),label: "circle"),
        ],
      ),
    );
  }
//
  Widget buildAuthScreen2() {
    return Scaffold(
      body: PageView(
        children: <Widget>[

          RaisedButton(
            child: Text("Page 1"),
            onPressed: () {
              print("Page 1 button");
            },
          ),
          RaisedButton(
            child: Text("Page 2"),
            onPressed: () {
              print("Page 2 button");
            },
          ),
          RaisedButton(
            child: Text("Page 3"),
            onPressed: () {
//              logout();
            },
          ),
          RaisedButton(
            child: Text("Page 4"),
            onPressed: () {
//              logout();
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
        activeColor: Colors.purple,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera)),
//          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
//          BottomNavigationBarItem(icon: Icon(Icons.cloud_circle)),
//          BottomNavigationBarItem(icon: Icon(Icons.supervised_user_circle)),
          BottomNavigationBarItem(icon: Icon(Icons.logout)),
        ],
      ),
    );
  }

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor,
            ]
          )
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
              icon: FaIcon(FontAwesomeIcons.google),
              label: Text("LOGOUT"),
              onPressed: () {
                final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
                provider.googleLogout();

              },
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
              icon: FaIcon(FontAwesomeIcons.google),
              label: Text("INFO"),
              onPressed: () {
                print(FirebaseAuth.instance.currentUser);

              },
            ),
            Text('Flutter Circles',
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90.0,
                color: Colors.white
              ),
            ),
            GestureDetector(
              onTap: () {
                final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
                provider.googleLogin();

              },
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover

                ),
              ),
            )
            )
          ],
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
//    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  return Scaffold(
    body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return circularProgress();
        } else if (snapshot.hasData) {
          print('fb usa');
          print(FirebaseAuth.instance.currentUser!.providerData.single.uid);

              usersRef.doc(FirebaseAuth.instance.currentUser!.providerData.single.uid).set(
      {
        "id": FirebaseAuth.instance.currentUser!.providerData.single.uid,
        "bio":"",
        "username":"username",
        "email": FirebaseAuth.instance.currentUser!.email,
        "displayName":FirebaseAuth.instance.currentUser!.displayName,
        "photoUrl": FirebaseAuth.instance.currentUser!.photoURL,
        "timestamp":timestamp
      }
    );


          return MyHome();
//        return buildAuthScreen2();
        } else if (snapshot.hasError) {
          return Center(child: Text("Something Went Wrong!"));
        } else {
          return buildUnAuthScreen();
        }
      },
    ),
    );
  }
}
