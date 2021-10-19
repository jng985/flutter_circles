import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttercircles/widgets/header.dart';
import 'package:fluttercircles/widgets/progress.dart';

//final CollectionReference usersRef = Firestore.instance.collection('users');
final usersRef = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {

  List<dynamic> users = [];

  @override
  void initState() {
    getUsers();
    super.initState();
  }



  createUser() {
    usersRef.doc()
        .set({});
  }

  updateUser() async {
    final doc = await usersRef.doc().get();
    if (doc.exists) {
//      doc.reference.updateData({});
    }
  }

  deleteUser() async {
    final doc = await usersRef.doc().get();
    if (doc.exists) {
      doc.reference.delete();
    }

  }

  getUsers() async {
    final QuerySnapshot snapshot = await usersRef.get();

    setState(() {
      users = snapshot.docs;
    });
//    snapshot.documents.forEach((DocumentSnapshot doc) {
//        print(doc.data);
//      });

  }

  getUserById(String id) async {
    await usersRef.doc(id).get();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, titleText: "Hello", isAppTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          final List<Text> children = snapshot.data!.docs.map((doc) => Text(doc['username'])).toList();
          return Container(
            child: ListView(
              children: children,
            ),
          );
        },
      )
    );
  }
}
