import 'dart:async';
import 'package:chatify/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatify/models/userData.dart';

class ViewMapPage extends StatefulWidget {
  final GeoPoint pos;
  final UserData receiver;
  final bool isSender;
  const ViewMapPage(
      {Key? key,
      required this.pos,
      required this.receiver,
      this.isSender = false})
      : super(key: key);
  @override
  State<ViewMapPage> createState() => ViewMapPageState();
}

class ViewMapPageState extends State<ViewMapPage> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? pos;
  List<Placemark>? placemarks;
  CameraPosition? _kGooglePlex;
  Set<Marker>? _markers = Set<Marker>();
  Marker? marker;
  @override
  void initState() {
    super.initState();
    pos = LatLng(widget.pos.latitude, widget.pos.longitude);
    _kGooglePlex = CameraPosition(
      target: pos!,
      zoom: 16,
    );
    _onAddMarkerButtonPressed();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onAddMarkerButtonPressed() async {
    placemarks = await placemarkFromCoordinates(pos!.latitude, pos!.longitude);
    // placemarks.forEach((element) {print(element);});
    // print(placemarks.length);
    setState(() {
      _markers!.add(Marker(
        markerId: MarkerId(pos.toString()),
        position: pos!,
        infoWindow: InfoWindow(
          title: placemarks![0].street! + " " + placemarks![0].thoroughfare!,
          snippet: placemarks![0].locality! +
              ", " +
              placemarks![0].postalCode! +
              ", " +
              placemarks![0].administrativeArea!,
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
          backgroundColor: Colors.amberAccent,
          title: widget.isSender
              ? Text(Strings.yourLocation)
              : Text("${widget.receiver.name!.split(' ')[0]}'s Location"),
        ),
        body: Container(
          color: Colors.white,
          child: GoogleMap(
            mapType: MapType.hybrid,
            markers: _markers!,
            initialCameraPosition: _kGooglePlex!,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ),
      ),
    );
  }
}
