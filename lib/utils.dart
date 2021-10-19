import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttercircles/pages/home.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_permissions/location_permissions.dart' as lp;
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;


class Utils {

  bitmap_from_icon(IconData iconData, Color color, double size) async {
//    double size = 70.0;

    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final iconStr = String.fromCharCode(iconData.codePoint);

    textPainter.text = TextSpan(
        text: iconStr,
        style: TextStyle(
          letterSpacing: 0.0,
          fontSize: size,
          fontFamily: iconData.fontFamily,
          color: color,
        )
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(0.0, 0.0));

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ImageByteFormat.png);

    final bitmapDescriptor = BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
    return bitmapDescriptor;

  }

  void _req_location() async {
    await lp.LocationPermissions().requestPermissions();
  }

  add_user_fire(fireuser) {
//    usersRef.doc(fireuser.uid).set(
//      {
//        "id": fireuser.uid,
//        "bio":"",
//        "username":"username",
//        "email": fireuser.email,
//        "displayName":fireuser.displayName,
//        "photoUrl": fireuser.photoUrl,
//        "timestamp":timestamp
//      }
//    );
  }

  get_user_location() async {
    _req_location();
    Position position = await Geolocator
        .getCurrentPosition();
    LatLng _lastMapPosition = LatLng(position.latitude, position.longitude);
    return _lastMapPosition;
  }

  update_user_location_fire(String id, bg.Location location) async {
//    String userlocationId = Uuid().v4();
//    locationsRef.doc(id).collection("userLocations").doc(time.toString()).set(
    locationsRef.doc(id).collection("current").doc("current").set(
      {
        "lat": location.coords.latitude,
        "lon": location.coords.longitude,
        "timestamp": location.timestamp,
        "is_moving": location.isMoving,
        "activity_type":location.activity.type,
        "battery_level": location.battery.level,
        "is_charging": location.battery.isCharging,

      }
    );
    locationsRef.doc(id).collection("history").doc(location.timestamp).set(
        {
          "lat": location.coords.latitude,
          "lon": location.coords.longitude,
          "timestamp": location.timestamp,
          "is_moving": location.isMoving,
          "activity_type":location.activity.type,
          "battery_level": location.battery.level,
          "is_charging": location.battery.isCharging,
        }
    );
                print("LOCATION WRITE");

    final circles = await userCirclesRef.doc(id).collection('circles').get();
//
    circles.docs.forEach((doc) {
      final d = doc.data() as Map<String, dynamic>;
      update_user_circle_location_fire(d['circleId'], id, location);
    });

  }



  update_user_circle_location_fire(String cid, String id, bg.Location location) {



    circleLocationsRef.doc(cid).collection("memberLocations").doc(id).set(
      {
        "lat": location.coords.latitude,
        "lon": location.coords.longitude,
        "timestamp": location.timestamp,
        "is_moving": location.isMoving,
        "activity_type":location.activity.type,
        "battery_level": location.battery.level,
        "is_charging": location.battery.isCharging,
      }
    );
//    locationsRef.doc(id).collection("userLocations").doc(time.toString()).set(

    print("UPDATED CIRCLE LOC");
  }


}


class LocationService {
  late LatLng _currentLocation;

  final location = Location();

  Future<LatLng> getLocation() async {
    try {
      final userLocation = await location.getLocation();

      _currentLocation = LatLng(
        userLocation.latitude!,
        userLocation.longitude!,
      );
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }

    return _currentLocation;
  }

  StreamController<LatLng> _locationController = StreamController<LatLng>();

  Stream<LatLng> get locationStream => _locationController.stream;

  LocationService() {
    // Request permission to use location
    location.requestPermission().then((PermissionStatus status) {
      if (status == PermissionStatus.granted) {
        // If granted listen to the onLocationChanged stream and emit over our controller
        location.onLocationChanged.listen((locationData) {
          if (locationData != null) {
            print("DA LOC SERVICE");
            print(locationData);
            _locationController.add(LatLng(
              locationData.latitude!,
              locationData.longitude!,
            ));
          }
        });
      }
    });
  }
}
