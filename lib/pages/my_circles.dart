import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercircles/pages/circle_screen.dart';
import 'package:fluttercircles/pages/home.dart';
import 'package:fluttercircles/widgets/header.dart';
import 'package:fluttercircles/widgets/mycircle_circle.dart';
import 'package:fluttercircles/widgets/progress.dart';

import 'create_circle.dart';

class MyCircles extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyCirclesState();
  }
}
class _MyCirclesState extends State<MyCircles> {

  final user = FirebaseAuth.instance.currentUser?.providerData.single.uid;

  getUserCircles() async {
    return await circlesRef.doc(user).collection('userCircles').get();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<QuerySnapshot<Object?>>(
      future: userCirclesRef.doc(user).collection('circles').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        List<Widget> circles = [
          Container(
            height: 60,
//          color: Theme.of(context).primaryColor.withOpacity(0.5),
          child:RaisedButton(
            color: Colors.white,
            child: Text("Create", style: TextStyle(fontSize:28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor.withOpacity(0.9),),),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Circle()));

              })),
          SizedBox(height: 5,),
//          MyCircle(cid: "6fba2634-7a84-4fed-ae9d-8ac0f7cfaff7")
        ];

        snapshot.data!.docs.forEach((doc) {
          final d = doc.data() as Map<String, dynamic>;
          circles.add(
            SizedBox(height: 15.0,)
          );
          circles.add(
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                  borderRadius: BorderRadius.all(Radius.circular(35.0))
                ),
//                color: Theme.of(context).primaryColor.withOpacity(0.7),
                child: Column(
                  children: <Widget>[

                    GestureDetector(
                      onTap: () {
                        print("show circle");
//                        Navigator.pushNamed(context, "/circle_page",
//                        arguments: {'circleId':d['circleId']});
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => CircleScreen(userId: user!, circleId: d['circleId'],)));

                      },
//            onTap: () => showProfile(context, profileId: user.id),
                      child:  MyCircle(cid: d['circleId']),
//                      ListTile(
//                        leading: CircleAvatar(
//                          radius: 80,
//                          backgroundColor: Colors.grey,
////                          backgroundImage: CachedNetworkImageProvider(user.photoUrl),
//                        ),
//                        title: Text(d['circleName'], style: TextStyle(
//                            color: Colors.white,
//                            fontWeight: FontWeight.bold
//                        ),),
////                        subtitle: Text(d['circleName'], style: TextStyle(color: Colors.white),),
////                        trailing: MyCircle(cid: "6fba2634-7a84-4fed-ae9d-8ac0f7cfaff7"),
//                      ),
                    ),
//                    MyCircle(cid: d['circleId']),
//                    Divider(
//                      height: 5.0,
//                      thickness: 4.0,
//                      color: Colors.white54,
//                    )
                  ],
                )

          ));

//          print(d);
        });


        return
          Navigator(
          onGenerateRoute: (settings) {
            Widget page = Scaffold(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                appBar: header(context, titleText: "My Circles"),
                body: Padding(padding: EdgeInsets.all(20),
                  child: ListView(children: circles),
                )
            );
            print('GGGFFFF');
            print(settings);


            if (settings.name == '/circle_page') {
              final args = settings.arguments as Map;
              String cid = args['circleId'];

              print(args);
              page = CircleScreen(userId: user!, circleId: cid,);
            }
            return MaterialPageRoute(builder: (context) => page);

          },
        );

          Scaffold(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
            appBar: header(context, titleText: "My Circles"),
            body: Container(
              child: ListView(children: circles),
            )
        );
      }
    );
  }
}
