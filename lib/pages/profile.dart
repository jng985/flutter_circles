import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttercircles/models/user.dart';
import 'package:fluttercircles/pages/edit_profile.dart';
import 'package:fluttercircles/pages/home.dart';
import 'package:fluttercircles/widgets/header.dart';
import 'package:fluttercircles/widgets/progress.dart';
import 'package:fluttercircles/widgets/post.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({required this.profileId});


  @override
  _ProfileState createState() => _ProfileState(
    profileId: this.profileId
  );
}

class _ProfileState extends State<Profile> {

  final String profileId;

  _ProfileState({required this.profileId});

  final firebase_user = FirebaseAuth.instance.currentUser!.providerData.single.uid!;

  bool isFollowing = false;
//  final String currentUserId = currentUser.id;
  bool isLoading = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followersRef.doc(widget.profileId).collection('userFollowing').get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }


  getFollowers() async {
    QuerySnapshot snapshot = await followersRef.doc(widget.profileId).collection('userFollowers').get();
    setState(() {
      followerCount = snapshot.docs.length;
    });
  }


  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef.doc(widget.profileId).collection('userFollowers').doc(firebase_user).get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot<Object?> snapshot = await postsRef
        .doc(widget.profileId)
    .collection('userPosts')
    .orderBy('timestamp', descending: true)
    .get();
//    print(snapshot.docs);
    snapshot.docs.forEach((doc) {
      Map<String, dynamic> d = doc.data() as Map<String, dynamic>;
//      print(d);

    });
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    }
//    getProfilePosts();
    return Column(
      children: posts,
    );
  }

  buildProfileButton() {
    bool isProfileOwner = firebase_user == widget.profileId;
    if (isProfileOwner) {
      return buildButton(text: "Edit Profile", function: editProfile);
    } else if (isFollowing) {
      return buildButton(text: "Unfollow", function: handleUnfollowUser);
    } else if (!isFollowing) {
      return buildButton(text: "Follow", function: handleFollowUser);
    }
  }

  void editProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()));
  }

  void handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    followersRef.doc(widget.profileId).collection('userFollowers').doc(firebase_user).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followersRef.doc(firebase_user).collection('userFollowing').doc(widget.profileId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });


    activityFeedRef.doc(widget.profileId).collection('feedItems').doc(firebase_user).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  void handleFollowUser() {}
//  void handleFollowUser() {
//    setState(() {
//      isFollowing = true;
//    });
//    followersRef.doc(widget.profileId).collection('userFollowers').doc(firebase_user).set({});
//    followersRef.doc(firebase_user).collection('userFollowing').doc(widget.profileId).set({});
//    activityFeedRef.doc(widget.profileId).collection('feedItems').doc(firebase_user).set({
//      "type":"follow",
//      "ownerId":widget.profileId,
//      "username": firebase_user!.username,
//      "userId": f.id,
//      "userProfileImg":currentUser!.photoUrl,
//      "timestamp":timestamp
//    });
//
//  }

  Container buildButton({required String text, required Function function}) {
    return Container(
      padding: EdgeInsets.only(top:2.0),
      child: FlatButton(
//        onPressed: function,
        onPressed: () {function();},
        child: Container(
//          color: Colors.purple,
          width: 250.0,
          height: 35.0,
          child: Text(
            text,
            style: TextStyle(color: isFollowing ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Theme.of(context).primaryColor.withOpacity(0.8),
            border: Border.all(
              color: isFollowing ? Colors.grey : Theme.of(context).primaryColor.withOpacity(0.8),
            ),
            borderRadius: BorderRadius.circular(5.0)
          ),
        )
      ),
    );
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top:4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 15.0,
              fontWeight: FontWeight.w400
            ),
          ),
        )
      ],
    );
  }

  buildProfileHeader() {
    return FutureBuilder<DocumentSnapshot<Object?>>(
      future: usersRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
//        final data = snapshot.data as Map<String, dynamic>;

        final data = snapshot.data!.data() as Map<String, dynamic>;
        MyUser user = MyUser.fromDocument(data);
        return Padding(
            padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 40.0,
                backgroundColor: Colors.grey,
//                ba
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),

              ),

          Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top:12.0),
                        child: Text(
                          user.username,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top:4.0),
                        child: Text(
                          user.displayName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  buildCountColumn("posts",postCount),
                  buildCountColumn("followers",followerCount),
                  buildCountColumn("following",followingCount),

                ],
              ),
              buildProfileButton(),
//              Expanded(
//                flex: 1,
//                  child: Column(
//                    children: <Widget>[
//                      Row(
//                        mainAxisSize: MainAxisSize.max,
//                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                        children: <Widget>[
//                          buildCountColumn("posts",0),
//                          buildCountColumn("followers",0),
//                          buildCountColumn("following",0)
//                        ],
//                      ),
//                      Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                        children: <Widget>[
//                          buildProfileButton()
//                        ],
//                      ),
//                      Container(
//                        alignment: Alignment.centerLeft,
//                        padding: EdgeInsets.only(top:12.0),
//                        child: Text(
//                          user.username,
//                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
//                        ),
//                      ),
//                      Container(
//                        alignment: Alignment.centerLeft,
//                        padding: EdgeInsets.only(top:4.0),
//                        child: Text(
//                          user.displayName,
//                          style: TextStyle(fontWeight: FontWeight.bold),
//                        ),
//                      ),
//                      Container(
//                        alignment: Alignment.centerLeft,
//                        padding: EdgeInsets.only(top:2.0),
//                        child: Text(
//                          user.bio,
//                        ),
//                      )
//                    ],
//                  )
//              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Profile"),
      body: Container(
        color: Theme.of(context).primaryColor.withOpacity(0.2),
          child:ListView(
            children: <Widget>[
              buildProfileHeader(),
              Divider(height: 0.0,),
//              buildProfilePosts()
            ],
      )
      )
    );
  }
}
