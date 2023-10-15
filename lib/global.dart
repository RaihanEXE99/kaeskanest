library globals;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String apiUrl = "realestate.nbytetech.com";
String apiKey = "AIzaSyDE1Y0JpqJE6v4vuRpsmpZCoL5ZmTfrHmI";

// BitmapDescriptor customIcon;
// await BitmapDescriptor.fromAssetImage(
//   ImageConfiguration(devicePixelRatio: 2.0),
//   'assets/images/custom_icon.png',
// ).then((d) {
//   customIcon = d;
// });

// BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
//     ImageConfiguration(),
//     "assets/map/boy.png",
// );

// addMarkers() async {
//   BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
//       ImageConfiguration(),
//       "assets/images/bike.png",
//   );

//   markers.add(
//     Marker( //add start location marker
//       markerId: MarkerId(startLocation.toString()),
//       position: startLocation, //position of marker
//       infoWindow: InfoWindow( //popup info 
//         title: 'Starting Point ',
//         snippet: 'Start Marker',
//       ),
//       icon: markerbitmap, //Icon for Marker
//     )
//   );
// }
