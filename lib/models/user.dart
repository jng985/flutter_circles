import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyUser {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;

  MyUser({
    required this.id,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.displayName,
    required this.bio
  });

  factory MyUser.fromDocument(Map<String, dynamic> doc) {
    return MyUser(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio']
    );
  }



}
