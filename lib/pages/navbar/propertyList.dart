import 'dart:convert';
import 'dart:math';
import 'package:Kaeskanest/pages/components/appbar.dart';
import 'package:Kaeskanest/pages/components/navbar.dart';
import 'package:Kaeskanest/pages/components/userNavbar.dart';
import 'package:Kaeskanest/pages/navbar/compPropertyCard.dart';
import 'package:Kaeskanest/pages/navbar/propertyListByPolygone.dart';
import 'package:Kaeskanest/pages/navbar/propertyListOnMap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Kaeskanest/global.dart' as globals;

class MapScreen extends StatefulWidget {
  final double lat;
  final double long;
  final String postType;
  final String propertyCategory;
  final String pLocation;
  final bool initNeed;
  MapScreen({
    required this.lat,
    required this.long,
    required this.postType,
    required this.propertyCategory,
    required this.pLocation,
    required this.initNeed,
  });
  @override
  _MapScreenState createState() => _MapScreenState();
}

class Place {
  final String name;
  final String vicinity;
  final String placeId;
  final double lat;
  final double long;

  Place({
    required this.name,
    required this.vicinity,
    required this.placeId,
    required this.lat,
    required this.long,
  });
}

class _MapScreenState extends State<MapScreen> {

  @override
  void initState() {
    super.initState();
    if (widget.initNeed) {
      _cameFromHomePage();
    }
  }

  void _cameFromHomePage() async {
    if (mounted) {
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Navbar(),
      endDrawer: const UserNavBar(),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: DefaultAppBar(title:"Search Property")
        ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25,15,25,10),
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height/2.5,
                child: ElevatedButton(onPressed: ()=>{
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreenSearchByMap(lat: widget.lat, long: widget.long, postType: widget.postType, propertyCategory: widget.propertyCategory, pLocation: widget.pLocation, initNeed: widget.initNeed,),
                      ),
                    )
                }, child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.search,size: 85),
                    Text("SEARCH ON MAP",style: TextStyle(fontSize: 25),),
                  ],
                ))
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25,10,25,10),
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height/2.5,
                child: ElevatedButton(onPressed: ()=>{
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreenSearchByPolygon(lat: widget.lat, long: widget.long, postType: widget.postType, propertyCategory: widget.propertyCategory, pLocation: widget.pLocation, initNeed: widget.initNeed,),
                      ),
                    )
                }, child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.polyline,size: 85),
                    Text("DRAW YOUR AREA",style: TextStyle(fontSize: 25),),
                  ],
                ))
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        "Kaeskanest",
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontFamily: "Poppins",
          fontSize: 18,
          fontWeight: FontWeight.w600
        ),
      ),
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: Icon(
              Icons.menu,
              color: Theme.of(context).colorScheme.primary,
              ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      actions:[
        Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(
                Icons.account_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 30,
                ),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            );
          },
        ),
      ]
    );
  }

}
