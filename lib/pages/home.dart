import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:realestate/global.dart' as globals;
import 'package:realestate/pages/components/navbar.dart';
import 'package:realestate/pages/components/userNavbar.dart';
import 'package:realestate/pages/components/appbar.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:geolocator/geolocator.dart';

import 'package:permission_handler/permission_handler.dart';

import 'dart:async'; 
import 'dart:typed_data'; 
import 'dart:ui' as ui; 


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class Place {
  final String name;
  final String vicinity;
  final String placeId;
  final double lat;
  final double long;

  Place({required this.name, required this.vicinity,required this.placeId,required this.lat,required this.long});
}
class _HomePageState extends State<HomePage> {
  String selectedSaleOption = 'Sale';
  String selectedHomeOption = 'Home';
  String selectedTypeValue = 'Sale';
  String selectedCategoryValue = 'Home';

  final _locationController = TextEditingController();

  late GoogleMapController _mapController;
  var _currentPosition;

  Uint8List? markerIcon;

  List<Place> _places = [];

  FocusNode textFocusNode = FocusNode();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ScrollController scrollController = ScrollController();

  final String apiKey = globals.apiKey;

  final double _zoom = 18.0;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }

  Future<void> autoCompleteSearch(String input) async {
    final response = await get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey',
      ),
    );
    
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final predictions = jsonResponse['predictions'] as List;

      final futures = predictions.map((prediction) async {
        var data = await _getLatlong(prediction['place_id']);
        return Place(
          name: prediction['description'],
          vicinity: prediction['structured_formatting']['main_text'],
          placeId: prediction['place_id'],
          lat: data['lat'],
          long: data['long'],
        );
      }).toList();

      _places = await Future.wait(futures);
      setState(() {
        _places=_places;
      });
    }
  }
  
  Future _getLatlong(prediction) async{
    final response = await get(Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?placeid=$prediction&key=$apiKey'
    ));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return {
        'lat':jsonResponse['result']['geometry']['location']['lat'],
        'long':jsonResponse['result']['geometry']['location']['lng']
      };
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }
  
  void _getCurrentPosition() async {
    final tmpImg = await getBytesFromAsset('assets/map/boy.png', 125);
    setState(() {
      markerIcon=tmpImg;
    });
    // Get the current position using geolocator package
    final loc = await Permission.location.request();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (mounted){
      setState(() {
        // Set the current position as a LatLng object
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    // Set the map controller when the map is created
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Navbar(),
      endDrawer: const UserNavBar(),
      appBar: _appBar(context),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: _currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                  gestureRecognizers: {                 
                    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())
                  },
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: _zoom,
                    tilt: 45,
                  ),
                  mapType: MapType.normal,
                  markers: {
                    Marker(
                      markerId: MarkerId('current'),
                      position: _currentPosition,
                      icon: BitmapDescriptor.fromBytes(markerIcon!)
                    ),
                  },
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top:40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _saleDropdown(),
                      _homeDropdown()
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _places.length>4?4:_places.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_places[index].name),
                      subtitle: Text(_places[index].vicinity),
                      onTap: () {
                        setState(() {
                          _locationController.text = _places[index].name;
                          _currentPosition = LatLng(_places[index].lat, _places[index].long);
                          _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target:_currentPosition,zoom: _zoom)));
                        });
                        setState(() {
                          _places = [];
                        });
                        setState(() {
                          scrollController.animateTo(
                            0,
                            duration: Duration(seconds: 1), // Duration of the scroll animation
                            curve: Curves.ease,
                          );
                        });
                      },
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top:40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200, 
                        child: SizedBox(
                          height: 45,
                          child: TextFormField(
                            autofocus: false,
                            obscureText: false,
                            controller: _locationController,
                            focusNode: textFocusNode,
                            key:formKey,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.all(13),
                              labelText: 'Search your location',
                              labelStyle: const TextStyle(
                                fontSize: 16, // Adjust as needed
                                fontWeight: FontWeight.normal, // Adjust as needed
                                color: Colors.black, // Adjust as needed
                              ),
                              hintStyle: const TextStyle(
                                fontSize: 16, // Adjust as needed
                                fontWeight: FontWeight.normal, // Adjust as needed
                                color: Colors.grey, // Adjust as needed
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary, // Adjust as needed
                                  width: 1.4,
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(0),
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(0),
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.green, // Adjust as needed
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(0),
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(0),
                                ),
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red, // Adjust as needed
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(0),
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(0),
                                ),
                              ),
                              focusedErrorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red, // Adjust as needed
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(0),
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(0),
                                ),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16, // Adjust as needed
                              fontWeight: FontWeight.normal, // Adjust as needed
                              color: Colors.black, // Adjust as needed
                            ),
                            validator: (value) {
                              // Add your validation logic here
                            },
                            onChanged: (value) async {
                              if(value.isEmpty){
                                setState(() {
                                  _places = [];
                                });
                              }else{ 
                                await autoCompleteSearch(value);
                              }
                            },
                            onTap: () {
                              // When the TextFormField is tapped, scroll to it.
                              scrollController.jumpTo(
                                formKey.currentContext!.findRenderObject()!.paintBounds.top,
                              );
                              // scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _places = [];
                              _locationController.text = "";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 3,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(8),
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(8),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                            child: _locationController.text.isEmpty?
                            const Text(
                              'Search',
                              style: TextStyle(
                                fontSize: 16, // Adjust as needed
                                color: Colors.white,
                              ),
                            )
                            :Icon(
                              Icons.clear_rounded
                            )
                          ),
                        ),
                      )
                    ],
                  ),
                ),  
              
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top:40,bottom: 20),
                  child: Divider(
                    color: Theme.of(context).colorScheme.primary,
                    thickness: 3,
                    indent: 85,
                    endIndent: 85,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "Get Your Best Match",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top:40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Type:', // Your label text
                        style: TextStyle(
                          fontSize: 16, // Adjust label font size as needed
                          fontWeight: FontWeight.normal, // Adjust label font weight as needed
                          color: Colors.black54, // Adjust label text color as needed
                        ),
                      ),
                      _typeDropdown(),
                    ]
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Category:', // Your label text
                        style: TextStyle(
                          fontSize: 16, // Adjust label font size as needed
                          fontWeight: FontWeight.normal, // Adjust label font weight as needed
                          color: Colors.black54, // Adjust label text color as needed
                        ),
                      ),
                      _categoryDropdown(),
                    ]
                  ),
                ],
              ),
            ),
            const SizedBox(height:20),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  _propertyCard(context),
                  _propertyCard(context),
                  _propertyCard(context),
                ],
              ),
            )
          ]
        ),
      )
    );
  }

  Column _propertyCard(BuildContext context) {
    return Column(
      children: [
        Card(
          // Set the shape of the card using a rounded rectangle border with a 8 pixel radius
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          // Set the clip behavior of the card
          clipBehavior: Clip.antiAliasWithSaveLayer,
          // Define the child widgets of the card
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                children: [
                  Image.asset(
                    "assets/img/cardimage.jpg",
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "€ 1600 / month",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                          ),
                        ),
                        // Add a space between the title and the text
                        Container(height: 10),
                        // Display the card's title using a font size of 24 and a dark grey color
                        Text(
                          "Stylish Apartment (3 Bed)",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey[700],
                            fontWeight:FontWeight.w500
                          ),
                        ),
                        // Add a space between the title and the text
                        Container(height: 10),
                        // Display the card's text using a font size of 15 and a light grey color
                        Text(
                          "This property is mostly wooded and sits high on a hilltop overlooking the Mohawk River",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                        Container(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Beds: ",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  "3",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Baths: ",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  "2",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Area: ",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  "Saint Germain",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Add a row with two buttons spaced apart and aligned to the right side of the card
                        Container(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text
                            ElevatedButton.icon(
                              icon: Icon(
                                Icons.account_circle_rounded,
                                color: Colors.black54,
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                shadowColor: Colors.transparent,
                                backgroundColor: Colors.white,
                              ),
                              label: const Text(
                                "Michael Suttherland",
                                style: TextStyle(
                                  color: Colors.black54
                                  ),
                              ),
                              onPressed: () {},
                            ),
                            // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                            ElevatedButton.icon(
                              icon: Icon(Icons.more_horiz_rounded),
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                              ),
                              label: Text(
                                "Details",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20,)
      ],
    );
  }

  Container _homeDropdown() {
  return Container(
    width: 150,
    decoration: BoxDecoration(
      border: Border.all(
        color: const Color(0xffE0E3E7),
        width: 2.0,         
      ),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Padding(
      padding: const EdgeInsets.only(left: 8),
      child: DropdownButton<String>(
        icon: Container(),
        underline: Container(),
        value: selectedHomeOption,
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        onChanged: (String? newValue) {
          setState(() {
            selectedHomeOption = newValue!;
          });
        },
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 18,
          color: Colors.black54,
        ),
          items: <String>['Home', 'Office', 'Appartment']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
    ),
  );
  }

  Container _saleDropdown() {
    return Container(
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xffE0E3E7),
                      width: 2.0,         
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: DropdownButton<String>(
                      icon: Container(),
                      underline: Container(),
                      value: selectedSaleOption,
                      elevation: 2,
                      borderRadius: BorderRadius.circular(10),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSaleOption = newValue!;
                        });
                      },
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                        items: <String>['Sale', 'Rent']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                  ),
                );
  }

  Container _categoryDropdown() {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xffE0E3E7),
          width: 2.0,         
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: DropdownButton<String>(
          icon: Container(),
          underline: Container(),
          value: selectedCategoryValue,
          elevation: 0,
          borderRadius: BorderRadius.circular(10),
          onChanged: (String? newValue) {
            setState(() {
              selectedCategoryValue = newValue!;
            });
          },
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black45,
          ),
            items: <String>['Home', 'Office', 'Appartment']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
      ),
    );
  }

  Container _typeDropdown() {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xffE0E3E7),
          width: 2.0,         
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: DropdownButton<String>(
          icon: Container(),
          underline: Container(),
          value: selectedTypeValue,
          elevation: 0,
          borderRadius: BorderRadius.circular(10),
          onChanged: (String? newValue) {
            setState(() {
              selectedTypeValue = newValue!;
            });
          },
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black45,
          ),
            items: <String>['Sale', 'Rent']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        "Realestate",
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