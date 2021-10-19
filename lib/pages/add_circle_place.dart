
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttercircles/cov/CategorySelector.dart';
import 'package:fluttercircles/cov/circle_members.dart';
import 'package:fluttercircles/pages/home.dart';
import 'package:fluttercircles/widgets/header.dart';
import 'package:fluttercircles/widgets/mymap.dart';
import 'package:fluttercircles/widgets/post.dart';
import 'package:fluttercircles/widgets/progress.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../utils.dart';
class CreatePlace extends StatefulWidget {
  final String circleId;

  CreatePlace({required this.circleId});

  @override
  _CreatePlaceState createState() => _CreatePlaceState();
}


class _CreatePlaceState extends State<CreatePlace> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Add Place"),
      body: Container(child: Text("hi"),),
    );
  }
}