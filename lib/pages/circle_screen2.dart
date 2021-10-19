
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttercircles/pages/home.dart';
import 'package:fluttercircles/widgets/header.dart';
import 'package:fluttercircles/widgets/mymap.dart';
import 'package:fluttercircles/widgets/post.dart';
import 'package:fluttercircles/widgets/progress.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_permissions/location_permissions.dart';

class CircleScreen extends StatelessWidget {
  final String userId;
  final String circleId;

  CircleScreen({required this.userId, required this.circleId});



  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: circlesRef.doc(userId).collection('userCircles').doc(circleId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
//        DocumentSnapshot doc = snapshot.doc;
        print(userId);
        print(circleId);
//        print(snapshot);
//        Post post = Post.fromDocument(snapshot.data);

        List<Widget> members = [];
        final data = snapshot.data! as Map<String, dynamic>;
        data['members'].forEach((key, value) {
          members.add(
              Container(
                color: Theme.of(context).primaryColor.withOpacity(0.7),
                child: Column(
                  children: <Widget>[

                    GestureDetector(
                      onTap: () => print("hi"),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: CachedNetworkImageProvider(value['userProfileImg']),
                        ),
                        title: Text(value['circleDisplayName'], style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),),
                        subtitle: Text(value['username'], style: TextStyle(color: Colors.white),),
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



        return Center(
          child: Scaffold(
              appBar: header(context, titleText: data['description']),
              body: Padding(
                  padding: EdgeInsets.only(top:10.0, left:20.0),

                  child: Column(
                    children: [
                      Container(
                        height: 300,
                        child: MyMap(),
                      ),
                      ListView(
                      children: <Widget>[
                        Container(
                          child: Text("Members", style: TextStyle(color: Colors.purple, fontSize: 24.0, fontWeight: FontWeight.bold),),
                        ),
                        Container(
                          height: 220.0,
                          child: ListView(children: members, ),
                        ),
//                        Container(
//                          child: Text("Map", style: TextStyle(color: Colors.purple, fontSize: 24.0, fontWeight: FontWeight.bold),),
//                        ),
//                        MyMap(),
                        Container(
                          child: Text("Events", style: TextStyle(color: Colors.purple, fontSize: 24.0, fontWeight: FontWeight.bold),),
                        ),
                        Container(
                          child: Text("Places", style: TextStyle(color: Colors.purple, fontSize: 24.0, fontWeight: FontWeight.bold),),
                        ),
                      ]
                  )])
              )
          ),
        );
      },
    );
  }
}