import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttercircles/pages/circle_screen.dart';
import 'package:fluttercircles/pages/home.dart';
import 'package:fluttercircles/pages/post_screen.dart';
import 'package:fluttercircles/pages/profile.dart';
import 'package:fluttercircles/widgets/header.dart';
import 'package:fluttercircles/widgets/progress.dart';
import 'package:fluttercircles/models/user.dart';



class ActivityFeed2 extends StatefulWidget {

  @override
  _ActivityFeed2State createState() => _ActivityFeed2State();
}

class _ActivityFeed2State extends State<ActivityFeed2> {
  final currentUserId =  FirebaseAuth.instance.currentUser?.providerData.single.uid;




  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .doc(currentUserId).collection('feedItems')
        .orderBy('timestamp', descending: true).limit(50).get();
    List<Widget> feedItems = [];
    snapshot.docs.forEach((doc) {
//      feedItems.add(ActivityFeedItem.fromDocument(doc));
//      feedItems.add(Text(doc.data['type'].toString()));
      print("Activity Feed Item ${doc.data}");
      final data = doc.data()! as Map<String, dynamic>;
      if (data['type'] == "invite") {
        feedItems.add(
            Padding(padding: EdgeInsets.only(bottom:2.0),
              child: Container(
                  color: Colors.white54,
                  child: ListTile(
                    title: GestureDetector(
                      onTap: () => print('show profile'),
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black
                            ),
                            children: [
                              TextSpan(
                                  text: data['description'], style: TextStyle(fontWeight: FontWeight.bold)
                              ),
//                            TextSpan(
//                                text: doc.data['type'], style: TextStyle(fontWeight: FontWeight.bold)
//                            )
                            ]
                        ),
                      ),
                    ),
//                    leading: CircleAvatar(
//                      backgroundImage: CachedNetworkImageProvider(doc.data['userProfileImg']),
//                    ),
                    trailing: GestureDetector(
                        child: RaisedButton(
                          child: Text("GO"),
                          onPressed: () {
//                            print(doc.data['CircleId']);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CircleScreen(userId: currentUserId!, circleId: data['circleId'])));
                          },
                        )
                    ),
                    subtitle: Text(data['type'], overflow: TextOverflow.ellipsis,),
                  )
              ),
            )
        );
      } else {


        feedItems.add(
            Padding(padding: EdgeInsets.only(bottom:2.0),
              child: Container(
                  color: Colors.white54,
                  child: ListTile(
                    title: GestureDetector(
                      onTap: () => print('show profile'),
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black
                            ),
                            children: [
                              TextSpan(
                                  text: data['username'], style: TextStyle(fontWeight: FontWeight.bold)
                              ),
//                            TextSpan(
//                                text: doc.data['type'], style: TextStyle(fontWeight: FontWeight.bold)
//                            )
                            ]
                        ),
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(data['userProfileImg']),
                    ),
                    trailing: GestureDetector(
                        child: RaisedButton(
                          child: Text("GO"),
                          onPressed: () {
//                            print(data['userId']);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PostScreen(userId: data['userId'], postId: data['postId'])));
                          },
                        )
                    ),
                    subtitle: Text(data['type'], overflow: TextOverflow.ellipsis,),
                  )
              ),
            )
        );}

    });
    return feedItems;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Activity Feed"),
      body: Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }

            List<Widget> data = snapshot.data as List<Widget>;
            return ListView(children: data);
//            return Text("Activity Feed");
//           return ListView(
//             children: [Text('hi'),
//             RaisedButton(child: Text("PRINT STUFF"),
//             onPressed: () {
//             print(snapshot.data);
//             },)],
//           );
          },
        ),
      ),
    );
  }
}

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type;
  final String postId;
  final String userProfileImg;
  final String timestamp;

  ActivityFeedItem({
    required this.username,
    required this.userId,
    required this.type,
    required this.postId,
    required this.userProfileImg,
    required this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc['username'],
      userId: doc['userId'],
      type: doc['type'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      timestamp: doc['timestamp'],
    );
  }
//




  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(bottom:2.0),
      child: Container(
          color: Colors.white54,
          child: ListTile(
            title: GestureDetector(
              onTap: () => print('show profile'),
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black
                    ),
                    children: [
                      TextSpan(
                          text: username, style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                      TextSpan(
                        text: 'hi',
                      )
                    ]
                ),
              ),
            ),
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfileImg),
            ),
            subtitle: Text("hi", overflow: TextOverflow.ellipsis,),
          )
      ),
    );
  }
}

//showProfile(BuildContext context, {required String profileId}) {
//  Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(profileId: profileId,)));
//}