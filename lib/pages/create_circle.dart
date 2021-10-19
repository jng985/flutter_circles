
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttercircles/models/user.dart';
import 'package:fluttercircles/pages/home.dart';
import 'package:fluttercircles/pages/search.dart';
import 'package:fluttercircles/widgets/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Circle extends StatefulWidget {

  @override
  _CircleState createState() => _CircleState();
}

class _CircleState extends State<Circle> {


  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  Future<QuerySnapshot> ?searchResultsFuture;





  final firebase_user = FirebaseAuth.instance.currentUser!.providerData.single.uid!;
  final hi = FirebaseAuth.instance.currentUser!.providerData.single.displayName!;

  bool isUploading = false;
  String circleId = Uuid().v4();
  Map<String, MyUser> members = {};

  get_user_from_id() async {
    final user_doc = await usersRef.doc(firebase_user).get();
    print('YEELOW');
    final d = user_doc.data() as Map<String, dynamic>;
    print(d);
    MyUser myuser = MyUser.fromDocument(d);
    setState(() {
      members[firebase_user] = myuser;
    });

  }

  void initState() {
    get_user_from_id();
    super.initState();
  }

  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        .where("displayName", isGreaterThanOrEqualTo: query)
        .get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
            hintText: "Search for a user",
            filled: true,
            prefixIcon: Icon(
              Icons.account_box,
              size: 28.0,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => clearSearch(),
            )
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder<QuerySnapshot<Object?>>(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
//          return circularProgress();
        }
        List<Container> searchResults = [];
        snapshot.data!.docs.forEach((doc) {
          final d = doc.data() as Map<String, dynamic>;
          MyUser user = MyUser.fromDocument(d);



//          UserResult searchResult = UserResult(user);
          searchResults.add(
              Container(
                color: Theme.of(context).primaryColor.withOpacity(0.7),
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
//                          members.add(user.displayName);
//                          Map<String, MyUser> members = {currentUser.id : currentUser};

                          members[user.id] = user;
                        });
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                        ),
                        title: Text(user.displayName, style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),),
                        subtitle: Text(user.username, style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    Divider(
                      height: 2.0,
                      color: Colors.white54,
                    )
                  ],
                ),
              )
          );
        });
        return ListView(
            children: searchResults
        );
      },
    );
  }







  createCircleInFirestore({required String description, required Map<String, MyUser> members}) {


    Map<String, Map> m = {};
    members.forEach((key, value) {
      m[key] = {
        'isJoined': true,
        'username': value.username,
        'circleDisplayName': value.displayName,
        'userProfileImg': value.photoUrl
      };
      userCirclesRef
          .doc(key)
          .collection('circles')
          .doc(circleId)
          .set({
        "circleId" :  circleId,
        "circleName": description,
      });
    });
//
//      activityFeedRef
//          .doc(key)
//          .collection("feedItems")
//          .doc(circleId)
//          .set({
//        "type" : "invite",
////        "username": currentUser.username,
////        "userId": currentUser.id,
//        "circleId": circleId,
////        "userProfileImg": currentUser.photoUrl,
//
////        "mediaUrl": mediaUrl,
//        "description": description,
//        "timestamp": timestamp
//      });
//    });
    circlesRef
        .doc(circleId)
        .set({
          "circleId":circleId,
          "members": m,
          "ownerId": firebase_user,
          "circleName": description
    });


  }

//  addInviteToActivityFeed() {
//    Map<String, MyUser> members = {currentUser.id : currentUser};

//    members.keys.map((id) {
//
//
//      activityFeedRef
//          .doc(id)
//          .collection("feedItems")
//          .doc(circleId)
//          .set({
//        "type" : "invite",
//        "username": currentUser.username,
//        "userId": currentUser.id,
//        "postId": postId,
//        "userProfileImg": currentUser.photoUrl,

//        "mediaUrl": mediaUrl,
//        "timestamp": timestamp
//      });
//    });
//  }




  handleSubmit() async {
    setState(() {
      isUploading = true;
    });

//    Map<String, MyUser> members = {currentUser.id : currentUser};

//
    createCircleInFirestore(
        description: captionController.text,
        members: members
    );
//    addInviteToActivityFeed();
    captionController.clear();
    locationController.clear();
    setState(() {
      isUploading = false;
    });
    Navigator.of(context).pop();
  }


  Scaffold buildCircleForm() {
//    Map<String, MyUser> members = {currentUser.id : currentUser};

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () => print("clear"),
        ),
        title: Text("Create Circle", style: TextStyle(color: Colors.black),),
        actions: [
          FlatButton(
              onPressed: isUploading ? null : () => handleSubmit(),
              child: Text("Create", style: TextStyle(color: Colors.blueAccent, fontSize: 20.0, fontWeight: FontWeight.bold),))
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          ListTile(
            leading: CircleAvatar(
//              backgroundImage: CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                    hintText: "Circle Name",
                    border: InputBorder.none
                ),
              ),
            ),
          ),
          Container(height: 220,
            child: ListView(
//              children: members.map((text) => Text(text)).toList(),
//              children: []
            children: members.values.map((m) => Text(m.displayName)).toList(),
            )),



//            width: MediaQuery.of(context).size.width * 0.8,

          Padding(
            padding: EdgeInsets.only(top:10.0),
          ),
//          RaisedButton(
//            onPressed: () {
//              setState(() {
//                members.add(locationController.text);
//              });
//          },),

          Divider(),

          Container(
            child: buildSearchField(),
          ),
          Container(
            height: 400,
            child: buildSearchResults(),
          ),



        ],
      ),
    );
  }
//
//  getUserLocation() async {
//    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//    List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
//    Placemark placemark = placemarks[0];
//    String completeAddress = '${placemark.subThoroughfare} ${placemark.locality} ${placemark.administrativeArea} ${placemark.country}';
//    print(completeAddress);
//    String formattedAddress = "${placemark.locality}, ${placemark.country}";
//  }

  @override
  Widget build(BuildContext context) {
    return buildCircleForm();
//    return buildUploadForm();
  }
}

class UserResult extends StatelessWidget {

  final MyUser user;

  UserResult(this.user);



  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              print('tapped');
              },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(user.displayName, style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),),
              subtitle: Text(user.username, style: TextStyle(color: Colors.white),),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          )
        ],
      ),
    );
  }
}