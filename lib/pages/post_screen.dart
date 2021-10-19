import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttercircles/pages/home.dart';
import 'package:fluttercircles/widgets/header.dart';
import 'package:fluttercircles/widgets/post.dart';
import 'package:fluttercircles/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({required this.userId, required this.postId});



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Object?>>(
      future: postsRef.doc(userId).collection('userPosts').doc(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

        print(data['description']);
        Post post = Post.fromDocument(data);
        return Center(
          child: Scaffold(
            appBar: header(context, titleText: post.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
