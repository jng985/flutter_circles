
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttercircles/models/directions_model.dart';
import 'package:fluttercircles/models/directions_repo.dart';
import 'package:fluttercircles/pages/circle_settings.dart';
import 'package:fluttercircles/pages/home.dart';
import 'package:fluttercircles/widgets/circle_places.dart';
import 'package:fluttercircles/widgets/header.dart';
import 'package:fluttercircles/widgets/my_color_picker.dart';
import 'package:fluttercircles/widgets/progress.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../utils.dart';

class CircleScreen extends StatefulWidget {
  final String userId;
  final String circleId;
  CircleScreen({required this.userId, required this.circleId});
  @override
  _CircleScreenState createState() => _CircleScreenState();
}
class _CircleScreenState extends State<CircleScreen> {
  int selectedIndex = 0;
  int placeIconIndex = 0;
  Color _color = Colors.purple;
  final List<IconData> icons = [Icons.home, Icons.work, Icons.store, IconData(0xe28d, fontFamily: 'MaterialIcons'), Icons.school, Icons.health_and_safety,Icons.outdoor_grill,Icons.location_on];
  final List<String> categories = ['Members','Places','Events', "Other"];
  TextEditingController placeController = TextEditingController();
  TextEditingController placeAddressController = TextEditingController();
  GoogleMapController? mapController;
  String? marker_selected;
  String user_selected = "";
  Directions? _info;
  String disttime = "";
  Set<Marker> _markers = {};
  Map<String, dynamic> markers_map= {};
  Map<Color, String> all_colors_col2str = {
    Colors.blue:"Colors.blue",
    Colors.green:"Colors.green",
    Colors.greenAccent:"Colors.greenAccent",
    Colors.orange:"Colors.orange",
    Colors.red:"Colors.red",
    Colors.purple:"Colors.purple",
    Colors.deepOrange:"Colors.deepOrange",
    Colors.teal:"Colors.teal"
  };
  Map<String, Color> all_colors_str2col = {
    "Colors.blue":Colors.blue,
    "Colors.green":Colors.green,
    "Colors.greenAccent":Colors.greenAccent,
    "Colors.orange":Colors.orange,
    "Colors.red":Colors.red,
    "Colors.purple":Colors.purple,
    "Colors.deepOrange":Colors.deepOrange,
    "Colors.teal:Colors.teal":Colors.teal
  };
//  late BitmapDescriptor purple_person;

  static const LatLng _center = const LatLng(40.7227753, -73.89059728);
  LatLng _lastMapPosition = _center;

  Widget places_icons() {

    List<Widget> wids = [];

    return Container(
      height: 70.0,
      child: ListView.builder(
        padding: EdgeInsets.only(left: 10.0),
        scrollDirection: Axis.horizontal,
        itemCount: icons.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: ()  {
              setState(() {
                placeIconIndex = index;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Icon(
                icons[index],
                color: index == placeIconIndex ? _color : Colors.grey,
                size: 40.0,
              )
            ),
          );
        },
      ),
    );


  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

//  load_purple_person() async {
//    BitmapDescriptor bitmap = await Utils().bitmap_from_icon(Icons.person, Colors.purple);
//    purple_person = bitmap;
//  }

  load_places() async {

    QuerySnapshot places = await circlePlacesRef.doc(widget.circleId).collection('places').get();
    places.docs.forEach((doc) async {
      final d = doc.data() as Map<String, dynamic>;
      markers_map[d['marker_id']] = d;
//        addMarker(d['marker_id'], false, icons[d['icon']], all_colors_str2col[d['color']]!, LatLng(d['lat'],d['lon']), false);

      BitmapDescriptor icon = await Utils().bitmap_from_icon(icons[d['icon']], all_colors_str2col[d['color']]!, 70.0);
      Marker mark = Marker(markerId: MarkerId(d['marker_id']),
        position: LatLng(d['lat'],d['lon']),
        infoWindow: InfoWindow(title: d['title'],),
        icon: icon,
//        consumeTapEvents: true,
        onTap: () {
          setState(() {
            marker_selected = d['marker_id'];
          });
        },
      );
      setState(() {
        _markers.add(mark);
      });

    });
  }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
//    setState(() {
//      load_places();
//    });
  }
  @override
  void initState() {
    load_places();
//    super.initState();
//    load_purple_person();
  }
  addMarker(String marker_id, bool drag, IconData iconData, Color color, LatLng position, bool save) async {
    print(position);
//    LatLng new_pos = _lastMapPosition;

    BitmapDescriptor bitmap = await Utils().bitmap_from_icon(iconData, color, 70.0);
    Marker mark = Marker(markerId: MarkerId(marker_id),
      position: position,
      infoWindow: InfoWindow(title: "",),
      draggable: drag,
//      onDragEnd: ((newPosition) {
//        circlePlacesRef.doc(widget.circleId).collection('places').doc(marker_id).set({
//          "marker_id" : marker_id,
//          "lat" : newPosition.latitude,
//          "lon":newPosition.longitude,
//          "title": placeController.text,
//          "address":placeAddressController.text,
//          "icon": placeIconIndex,
//          "color": all_colors_col2str[_color],
//          "owner":widget.userId
//
//        });
//      }),
        icon: bitmap
    );
    if (save) {
          setState(() {
            circlePlacesRef.doc(widget.circleId).collection('places').doc(
                mark.markerId.value).set({
              "marker_id": mark.markerId.value,
              "lat": mark.position.latitude,
              "lon": mark.position.longitude,
              "title": placeController.text,
              "address": placeAddressController.text,
              "icon": placeIconIndex,
              "color": all_colors_col2str[_color],
              "owner": widget.userId
            });
                  _markers.add(mark);

          });
    }

  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Object?>>(
      future: circlesRef.doc(widget.circleId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {return circularProgress();}
        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
        List<Widget> members = [];
        List<Map> m = [];
        data['members'].forEach((key, value) {
          value['id'] = key;
          m.add(value);
          members.add(Container(
                color: Theme.of(context).primaryColor.withOpacity(0.7),
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => print("hi"),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                      backgroundImage: CachedNetworkImageProvider(value['userProfileImg']),),
                        title: Text(value['circleDisplayName'], style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold
                        ),),
                        subtitle: Text(value['circleDisplayName'], style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    Divider(height: 2.0, color: Colors.white54,)
                  ],
                ),
              )
          );
        });
        return StreamBuilder<QuerySnapshot>(
          stream: circleLocationsRef.doc(widget.circleId).collection("memberLocations").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {return circularProgress();}
            Map memlocs = {};
            snapshot.data!.docs.forEach((doc) {
              final d = doc.data() as Map<String, dynamic>;
              memlocs[d['id']] = LatLng(d['lat'], d['lon']);
            });
            snapshot.data!.docs.forEach((doc) async {
              final d = doc.data() as Map<String, dynamic>;
              memlocs[d['id']] = LatLng(d['lat'], d['lon']);
              _markers.add(
                  Marker(markerId: MarkerId(d["id"]),
                      infoWindow: InfoWindow(title: data['members'][d["id"]]['circleDisplayName']),
                      position: LatLng(d['lat'], d['lon']),
                      icon: await Utils().bitmap_from_icon(Icons.person, Colors.deepPurpleAccent, 110.0)
//                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
//                    onTap: () async {
//                      mapController!.animateCamera(CameraUpdate.newLatLng(memlocs[m[index]['id']]));
//                    }
                  )
              );
            });
      return Scaffold(
          appBar: header(context, titleText: data['circleName']),
          body: Column(children:[
              Container(height: 280,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      onCameraMove: _onCameraMove,
                      myLocationEnabled: true,
                      markers: _markers,
                      polylines: {
                        if (_info != null)
                          Polyline(
                            polylineId: const PolylineId('overview_polyline'),
                            color: Colors.deepPurpleAccent, width: 5, points: _info!.polylinePoints
                                .map((e) => LatLng(e.latitude, e.longitude)).toList(),
                          ),
                      },
                      initialCameraPosition: CameraPosition(target: _center, zoom: 11.0),
                    ),
                    if (_info != null) Positioned(
                      left: 20.0,
                      top: 20.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.deepPurple,
                              offset: Offset(0, 2),
                              blurRadius: 6.0,
                            )
                          ],
                        ),
                        child: Text(
                          '${_info!.totalDuration} : ${_info!.totalDistance}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ]
                )
              ),
//              if (marker_selected != null) Container(height: 100,
//                child: Row(
//                  children: [
//                    user_selected != "" ? CircleAvatar(child: markers_map[],) :
//                  ],
//                ),
//              ),
              Column(children: [
                Container(height: 50, color: Colors.deepPurpleAccent.withOpacity(0.7),
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                          child: ElevatedButton(

                              onPressed: (){
                                setState(() {
                                  selectedIndex = index;
                                });},
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(10)),
                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.purple),
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                          side: BorderSide(color: Colors.deepPurpleAccent)
                                      )
                                  )
                              ),
                              child: Text(categories[index], style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold, letterSpacing: 1.2,
                          ),)),
                        );
                      }),
                  ),
                ]),
              [
                Container(
                  child: Column(children:[
                    Padding(padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: Column(
                        children: <Widget>[
                          Container(height: 80.0,
                            child: ListView.builder(
                            padding: EdgeInsets.only(left: 5.0),
                            scrollDirection: Axis.horizontal,
                            itemCount: m.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                              onTap: () async {
                                print(m[index]);
                                print(memlocs[m[index]['id']]);
                                mapController!.animateCamera(CameraUpdate.newLatLng(memlocs[m[index]['id']]));
//              final directions = await DirectionsRepository().getDirections(
//                  origin: _center, destination: memlocs[m[index]['id']]);
                                setState(() {
                  //                _info = directions;
                                  user_selected = m[index]['id'];
                                  print("USER SELECTED :$user_selected");
                                });
                                },
                                child: Padding(padding: EdgeInsets.all(5.0),
                                  child: Column(children: <Widget>[
                                    CircleAvatar(
                                      radius: 20.0,
                                      backgroundImage:
                                      CachedNetworkImageProvider(m[index]["userProfileImg"]),
                                    ),
                                    SizedBox(height: 6.0),
                                      Text(
                          //                          m[index]['circleDisplayName'],
                                      m[index]['circleDisplayName'],
                                      style: TextStyle(color: Colors.blueGrey, fontSize: 12.0, fontWeight: FontWeight.w600,)
                                      ,)
                                    ,]
                                    ,),),);},),),],),
                    ),
              SingleChildScrollView(child:
              Container(
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      user_selected != "" ? CircleAvatar(
                        radius: 40.0, backgroundColor: Colors.grey,
                        backgroundImage: CachedNetworkImageProvider(data['members'][user_selected]['userProfileImg']),
                      ) : Text(""),
                      user_selected != "" ? RaisedButton(
                        color: Colors.deepPurpleAccent,
                          child: Text("Route Info", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
                          onPressed: () async {
                            if (user_selected != "") {
                              mapController!.animateCamera(CameraUpdate.newLatLng(memlocs[user_selected]));
                              final directions = await DirectionsRepository().getDirections(
                                  origin: await Utils().get_user_location(),
                                  destination: memlocs[user_selected]);
                              setState(() {
                                _info = _info == null ? directions : null;
                                disttime = directions!.totalDuration + " : "+ directions!.totalDistance;
                              });
                            }
                          }) : Text(""),
//                      Text(disttime)
//                    Text(user_selected)
                    ],)
              )
                ,)
                  ])),

                SingleChildScrollView(child:Container(
//                  height: 800,
                    padding: EdgeInsets.all(10.0),
                  child: Column(children:[
                    SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
//                        ElevatedButton(
//                          onPressed: () async {
//                            String marker_id = Uuid().v4();
//                            setState(() {
//                              addMarker(marker_id, true, icons[placeIconIndex],_color, _lastMapPosition, true);
//                            });
//                          },
//
//                            style: ButtonStyle(
//                                padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(10)),
//                                foregroundColor: MaterialStateProperty.all<Color>(_color),
//                                backgroundColor: MaterialStateProperty.all<Color>(_color),
//                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                                RoundedRectangleBorder(
//                                  borderRadius: BorderRadius.circular(15.0),
//                                  side: BorderSide(color: _color)
//                                )
//                              )
//                            ),
//                          child: Text("Add Place", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),)
//                        ),


//                        Column(
//                          children: [
//                            Container(height: 40, width: 160,
//                                child:TextField(controller: placeController,
//                                  decoration: InputDecoration(
//                                      hintText: "Add Place Name",
//                                      border: InputBorder.none
//                                  ),
//                                )),
////                            Container(height: 40, width: 200,
////                                child:TextField(controller: placeAddressController,
////                                  decoration: InputDecoration(
////                                      hintText: "Add Place Address",
////                                      border: InputBorder.none
////                                  ),
////                                )),
//                          ],
//                        ),
                      ]),
//                    Row(children: [
                      places_icons(),
//                      MyColorPicker(
//                          onSelectColor: (value) {
//                            setState(() {
//                              _color = value;
//                            });
//                          },
//                          availableColors: [
//                            Colors.blue,
//                            Colors.green,
//                            Colors.greenAccent,
//                            Colors.orange,
//                            Colors.red,
//                            Colors.purple,
//                            Colors.deepOrange,
//                            Colors.teal
//                          ],
//                          initialColor: _color),
                    SizedBox(height: 1,),
                        Divider(height: 4, thickness: 4,),
                        SizedBox(height: 5,),
                        CirclePlaces(circleId: widget.circleId,
                            onSelectPlace: (place) {
                          mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(place['lat'], place['lon'])));
                              print(place);
                            }
                            )
//                    ],)


                  ])

                )),


                Center(heightFactor: 2,child: RaisedButton(
                  child: Text("Coming Soon"),
                  onPressed: () async {
                    print('');
                  },
                ) ),
                Center(
                  heightFactor: 5,
                  widthFactor: 5,
                  child: ElevatedButton(

                    child: Icon(Icons.settings, size: 40,),
                    onPressed: ()  {Navigator.push(context, MaterialPageRoute(builder: (context) => CircleSettings(userId: widget.userId, circleId: widget.circleId)));}
                  ),),
              ][selectedIndex]
            ]
          ));
        });
      },
    );
  }
}
//width: MediaQuery.of(context).size.width * 0.8,