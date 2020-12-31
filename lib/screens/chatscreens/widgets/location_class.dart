import 'dart:async';

import 'package:flutter/material.dart';

import 'package:geocoding/geocoding.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skype_clone/models/userData.dart';

class showMap extends StatefulWidget {
  final GeoPoint pos;
  final UserData receiver;
  final bool isSender;
  const showMap({Key key, this.pos, this.receiver,this.isSender=false}) : super(key: key);
  @override
  State<showMap> createState() => showMapState();
}

class showMapState extends State<showMap> {
  Completer<GoogleMapController> _controller = Completer();
  static LatLng pos;
  List<Placemark> placemarks;
  CameraPosition _kGooglePlex;
  final Set<Marker> _markers = {};
  Marker marker;
  @override
  void initState() {
    super.initState();
    pos = LatLng(widget.pos.latitude, widget.pos.longitude);
    _kGooglePlex = CameraPosition(
      target: pos,
      zoom: 16,
    );
    _onAddMarkerButtonPressed();
  }
@override
  void dispose() {

    super.dispose();
  }
  void _onAddMarkerButtonPressed() async {
    placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
  // placemarks.forEach((element) {print(element);});
  // print(placemarks.length);
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(pos.toString()),
        position: pos,
        infoWindow: InfoWindow(
          title: placemarks[0].street + " "+ placemarks[0].thoroughfare,
          snippet: placemarks[0].locality + ", " + placemarks[0].postalCode + ", " + placemarks[0].administrativeArea,
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:  Theme.of(context).appBarTheme.color,
          title: widget.isSender ? Text("Your Location"):Text("${widget.receiver.name.split(' ')[0]}'s Location"),
        ),
        body: Container(
          color: Colors.white,
          child: GoogleMap(
            mapType: MapType.hybrid,
            markers: _markers,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ),
      ),
    );
  }
}
