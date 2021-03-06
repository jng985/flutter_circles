
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttercircles/models/user.dart';
import 'package:fluttercircles/pages/home.dart';
import 'package:fluttercircles/widgets/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {


  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  final currentUserId =  FirebaseAuth.instance.currentUser?.providerData.single.uid;

  File? file;
  bool isUploading = false;
  String postId = Uuid().v4();

  handleTakePhoto() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.camera,
        maxHeight: 675,
        maxWidth: 960);
    File f = File(file!.path);
    setState(() {
      this.file = f;
    });

  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    File f = File(file!.path);
    setState(() {
      this.file = f;
    });
  }
  
  Future<String> uploadImage(imageFile) async {
    final uploadTask = storageRef.child("post_$postId.jpg").putFile(imageFile);
//    final storageSnap = await uploadTask.onComplete;
//    String downloadUrl = await storageSnap.ref.getDownloadURL();
    var downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  selectImage(parentContext) {
    return showDialog(context: parentContext,
        builder: (context) {
      return SimpleDialog(
        title: Text('Create Post'),
        children: <Widget>[
          SimpleDialogOption(
            child: Text("Photo with Camera"),
            onPressed: handleTakePhoto,
          ),
          SimpleDialogOption(
            child: Text("Image from Gallery"),
            onPressed: handleChooseFromGallery,
          ),
          SimpleDialogOption(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
        });
  }

  clearImage(){
    setState(() {
      file = null;
    });
  }

  Container buildSpashScreen() {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg', height: 260.0,),
          Padding(padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Text("Upload Image", style: TextStyle(
                color: Colors.white,
                fontSize: 22.0
              ),
              ),
                color: Colors.deepOrange,
              onPressed: () => selectImage(context),

            ),),
          Padding(padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Text("click", style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0
              ),
              ),
              color: Colors.deepOrange,
              onPressed: () => print(file),

            ),)
        ],
      ),
    );
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  createPostInFirestore({required String mediaUrl, required String location, required String description}) async {
//    print(currentUser!.id);
    final user = await usersRef.doc(currentUserId).get();

    print(user);

    postsRef
      .doc(currentUserId)
        .collection("userPosts")
        .doc(postId)
        .set({
        "postId" :  postId,
      "ownerId": currentUserId,
      "username": "BLAH",
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {}

    });
  }
  



  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);

    await
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: clearImage,
        ),
        title: Text("Caption Post", style: TextStyle(color: Colors.black),),
        actions: [
          FlatButton(
              onPressed: isUploading ? null : () => handleSubmit(),
              child: Text("Post", style: TextStyle(color: Colors.blueAccent, fontSize: 20.0, fontWeight: FontWeight.bold),))
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(file!),

                    )
                  ),
                ),
              )
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top:10.0),
          ),
          ListTile(
            leading: CircleAvatar(
//              backgroundImage: CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write something",
                  border: InputBorder.none
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.pin_drop, color: Colors.orange, size: 35.0,),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Location",
                  border: InputBorder.none
                ),
              ),
            ),

          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              label: Text("Use Current Location",
                style: TextStyle(color: Colors.white),),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),


              ),
              color: Colors.blue,
                onPressed: () => print("hello"),
//              onPressed: getUserLocation,
              icon: Icon(Icons.my_location, color: Colors.white,),
            ),
          )

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
    return file == null ? buildSpashScreen() : buildUploadForm();
//    return buildUploadForm();
  }
}
