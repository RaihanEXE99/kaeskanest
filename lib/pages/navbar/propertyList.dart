import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart'as http;
import 'package:http/http.dart';

import 'dart:async'; 
import 'dart:typed_data'; 
import 'dart:ui' as ui; 

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:Kaeskanest/global.dart' as globals;
import 'package:Kaeskanest/pages/navbar/property.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}
class Place {
  final String name;
  final String vicinity;
  final String placeId;
  final double lat;
  final double long;

  Place({required this.name, required this.vicinity,required this.placeId,required this.lat,required this.long});
}
class _MapScreenState extends State<MapScreen> {
  final String apiKey = globals.apiKey;
  late GoogleMapController _mapController;
  var _selectedLocation = LatLng(0, 0);
  Set<Marker> _markers = Set();
  
  double _radius = 1*1000;
  double zoomLevel = 10;

  final TextEditingController _locationController = TextEditingController();
  List<Place> _places = [];

  var properties = [];

  String selectedSaleOption = 'Rent';
  String selectedHomeOption = 'Home';

  Uint8List? markerIcon;

  double sliderValue = 1.0;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }

  void _onMapCreated(GoogleMapController controller) {
    // Set the map controller when the map is created
    _mapController = controller;
  }

  // double calculateZoomLevel(double radius, LatLng center) {
  //     var _add = 1;
  //     if(radius>10000){
  //       _add = 2;
  //     }
  //     // Assuming the Earth's radius is approximately 6371 kilometers
  //     double earthRadius = 6371.0;

  //     // Convert radius to radians
  //     double radiusInRadians = radius / earthRadius;

  //     // Calculate the angular distance on the Earth's surface
  //     double centralAngle = 2 * asin(sqrt(pow(sin(radiusInRadians / 2), 2) +
  //         cos(center.latitude * (pi / 180)) *
  //             cos(center.latitude * (pi / 180)) *
  //             pow(sin(radiusInRadians / 2), 2)));

  //     // Calculate the zoom level based on the central angle
  //     double zoomLevel = 12/_add - (log(centralAngle) / log(2));

  //     return zoomLevel;
  //   }
  double calculateZoomLevel(double radius, LatLng center) {
    // Assuming the Earth's radius is approximately 6371 kilometers
    double earthRadius = 6371.0;

    // Convert radius to radians
    double radiusInRadians = radius / earthRadius;

    // Calculate the zoom level based on the radius
    double zoomLevel = 10 - log(radiusInRadians) / log(2);

    return zoomLevel;
  }
  
  Future<void> autoCompleteSearch(String input) async {
    final response = await get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=AIzaSyDE1Y0JpqJE6v4vuRpsmpZCoL5ZmTfrHmI',
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
      if(mounted){
        setState(() {
          _places=_places;
        });
      }
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
    if(mounted){
      setState(() {
        markerIcon=tmpImg;
      });
    }
    // Get the current position using geolocator package
    final loc = await Permission.location.request();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (mounted){
      setState(() {
        // Set the current position as a LatLng object
        _selectedLocation = LatLng(position.latitude, position.longitude);
        Marker newMarker = Marker(
            markerId: MarkerId("Current location"),
            position: _selectedLocation,
            // icon: BitmapDescriptor.fromBytes(markerIcon!),
            onTap: () => {
              print("This is your current location!")
            },
          );

        setState(() {
          _markers.add(newMarker);
          zoomLevel = calculateZoomLevel(_radius,LatLng(position.latitude, position.longitude));
        });
        getProperties(_selectedLocation);
        // getProperties(LatLng(position.latitude, position.longitude));
      });
    }
  }

  Future<void> getProperties(LatLng location) async {
    setState(() {
      zoomLevel = calculateZoomLevel(_radius,location);
    });
    _clearMarkers();
    Marker newMarker = Marker(
      markerId: MarkerId(location.toString()),
      position: location,
      // infoWindow: InfoWindow(title: 'New Marker', snippet: 'This is a new marker'),
    );

    if(mounted){
      setState(() {
        _markers.add(newMarker);
      });
    }
    Future<http.Response> getRecProperties(LatLng location) async {
      // final url = Uri.parse("https://" + globals.apiUrl + '/api/search/`');
      final headers = {
        'Content-Type': 'application/json',
      };
      final Map<String, dynamic> queryParams = {
        "type": selectedSaleOption,
        "category": selectedHomeOption,
        "lat": location.latitude.toString(),
        "long": location.longitude.toString(),
        "radius": (_radius/1000).toString(),
      };
      print(queryParams);
      final String url = "https://" + globals.apiUrl + '/api/search/';
      final String queryString = Uri(queryParameters: queryParams).query;
      final String requestUrl = '$url?$queryString';
      print(requestUrl);
      final response = await http.get(Uri.parse(requestUrl), headers: headers,);
      return response;
    }
    final response = await getRecProperties(_selectedLocation);

    if (response.statusCode < 303) {
      final List<dynamic> responseData = json.decode(response.body);
      if(mounted){
        setState(() {
          properties=responseData;
          zoomLevel=calculateZoomLevel(_radius, _selectedLocation);
        });
      }
      for (Map<String, dynamic> item in responseData) {
        _addMarker(LatLng(item['lat'], item['long']));
      }
      setState(() {
        _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target:_selectedLocation,zoom: zoomLevel)));
      });
      // _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target:_selectedLocation,zoom: zoomLevel)));
    }else if(response.statusCode < 510){
      print("Error! 400");
      final String encodeFirst = json.encode(response.body);
      var data = json.decode(encodeFirst);
      print(data);
    }else{
      print("Server Error! 500");
    }
  }

  void _addMarker(LatLng position) async {
    Future<Uint8List> getBytesFromAsset(String path, int width) async {
      ByteData data = await rootBundle.load(path);
      ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
      ui.FrameInfo fi = await codec.getNextFrame();
      return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    }
    final tmpImg = await getBytesFromAsset('assets/map/houseIcon.png', 180);
    Marker newMarker = Marker(
      markerId: MarkerId(position.toString()),
      position: position,
      // infoWindow: InfoWindow(title: 'New Marker', snippet: 'This is a new marker'),
      icon: BitmapDescriptor.fromBytes(tmpImg!),
    );

    if(mounted){
      setState(() {
        _markers.add(newMarker);
      });
    }
      // _mapController.animateCamera(CameraUpdate.newLatLng(position));
  }

  void _addMeMarker(LatLng position) async {
    Marker newMarker = Marker(
      markerId: MarkerId(position.toString()),
      position: position,
      // infoWindow: InfoWindow(title: 'New Marker', snippet: 'This is a new marker'),
    );

    if(mounted){
      setState(() {
        // _markers.add(newMarker);
      });
    }
      // _mapController.animateCamera(CameraUpdate.newLatLng(position));
  }

  void _clearMarkers() {
    setState(() {
      _markers = {};
    });
  }

  void _onMapTapped(LatLng location) {
    _addMeMarker(location);
    setState(() {
      _selectedLocation = location;
      _locationController.text=location.latitude.toString()+","+location.longitude.toString();
    });
    getProperties(location);
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target:_selectedLocation,zoom: zoomLevel)));
  }

  @override
  void dispose() {
    super.dispose();
    _mapController.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Property'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              color: Theme.of(context).colorScheme.primary,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(top:15.0,bottom: 1.0,left:20,right:20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width/1.7,
                        child: TextField(
                          controller: _locationController,
                          onChanged: (value) async {
                            await autoCompleteSearch(value);
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                            hintText: 'Enter a location...',
                            labelStyle: const TextStyle(
                              fontSize: 16, // Adjust as needed
                              fontWeight: FontWeight.normal, // Adjust as needed
                              color: Colors.black54, // Adjust as needed
                            ),
                            // enabledBorder: OutlineInputBorder(
                            //   borderSide: BorderSide(
                            //     color: Colors.black, // Adjust as needed
                            //     width: 1.4,
                            //   ),
                            //   borderRadius: const BorderRadius.only(
                            //     bottomLeft: Radius.circular(0),
                            //     bottomRight: Radius.circular(0),
                            //     topLeft: Radius.circular(0),
                            //     topRight: Radius.circular(0),
                            //   ),
                            // ),
                          ),
                        ),
                      ),
                      if (_locationController.text!="")
                    ElevatedButton.icon(onPressed: ()=>{
                       setState(()=>{_locationController.text=""})
                      },style:ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent),), icon: Icon(Icons.search_off_outlined), label: Text("Clear")
                    )
                    ],
                  ),
                ),
                _places.isNotEmpty? Container(
                  height: 300,
                  child: ListView.builder(
                    itemCount: _places.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_places[index].name),
                        subtitle: Text(_places[index].vicinity),
                        onTap: () {
                          setState(() {
                            _locationController.text = _places[index].name;
                            _selectedLocation = LatLng(_places[index].lat, _places[index].long);
                            _addMeMarker(_selectedLocation);
                            _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target:_selectedLocation,zoom: zoomLevel)));
                            setState(() {
                              _places=[];
                            });
                          });
                        },
                      );
                    },
                  ),
                ):SizedBox(height:5,),
                Padding(
                  padding: const EdgeInsets.only(top:10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _saleDropdown(),
                      _homeDropdown()
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:40.0,right: 40,top: 10,bottom: 10),
                  child: Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: Text("Set Radius",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Selected Value: $sliderValue'),
                            Slider(
                              value: sliderValue,
                              min: 1,
                              max: 20,
                              divisions: 19, // Number of steps - 1 (since the range is 1 to 20)
                              onChanged: (newValue) {
                                setState(() {
                                  sliderValue = newValue;
                                  _radius = newValue*1000;
                                });
                                setState(() {
                                //   _addMeMarker(_selectedLocation);
                                //   getProperties(_selectedLocation);
                                  setState(() =>{_places=[],zoomLevel=calculateZoomLevel(_radius, _selectedLocation)} );
                                  _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target:_selectedLocation,zoom: zoomLevel)));
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 200,child: ElevatedButton.icon(onPressed: ()=>{
                      _addMeMarker(_selectedLocation),
                      getProperties(_selectedLocation),
                      setState(() =>{_places=[]} ),
                    },style:ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.lightBlue)), icon: Icon(Icons.search), label: Text("Search"))),
                  ],
                ),
                SizedBox(height: 10,)
              ]),
              
            ),
            Container(
                height: 300,
                color: Colors.white60,
                child: _selectedLocation == null
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
                    gestureRecognizers: {                 
                      Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())
                    },
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation,
                      zoom: zoomLevel,
                      tilt: 45,
                    ),
                    mapType: MapType.normal,
                    markers: _markers,
                    onTap: _onMapTapped,
                    circles: {
                    Circle(
                      circleId: CircleId('radius'),
                      center: _selectedLocation,
                      radius: _radius,
                      strokeWidth: 2,
                      strokeColor: Colors.blue,
                      fillColor: Colors.blue.withOpacity(0.2),
                    ),
                  },
                ),
                
              ),
            const SizedBox(height:20),
              Padding(
                padding: const EdgeInsets.all(15),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title:  _propertyCard(context,properties[index]),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
  Column _propertyCard(BuildContext context, ppt) {
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ppt["price_unit"]+" "+ppt["price"].toString()+ ppt['price_type'],
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[800],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.map_outlined),
                                Text(
                                  ppt['address']['country'],
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Add a space between the title and the text
                        Container(height: 10),
                        // Display the card's title using a font size of 24 and a dark grey color
                        Row(
                          children: [
                            Icon(Icons.maps_home_work_sharp),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Text(
                                ppt['title'],
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.grey[700],
                                  fontWeight:FontWeight.w500
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Add a space between the title and the text
                        Container(height: 10),
                        // Display the card's text using a font size of 15 and a light grey color
                        
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined),
                            Expanded(
                              child: Text(
                                "Area: "+ppt['loc'],
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(height: 15),
                        Padding(
                          padding: const EdgeInsets.only(left:2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.bed_outlined),
                                  Text(
                                    "Beds: ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    ppt['details']['bed'].toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.bathtub_outlined,size: 20),
                                  Text(
                                    "Baths: ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    ppt['details']['bath'].toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.square_foot_outlined,),
                                  Text(
                                    ppt['details']['size'].toString()+" "+ppt['details']['size_unit'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Add a row with two buttons spaced apart and aligned to the right side of the card
                        Container(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text
                            ElevatedButton.icon(
                              icon: Icon(
                                Icons.timelapse,
                                color: Colors.black54,
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                shadowColor: Colors.transparent,
                                backgroundColor: Colors.white,
                              ),
                              label: Text(
                                ppt['date'].substring(0, 10),
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PropertyDetails(propertyID: ppt["sku"]),
                                  ),
                                );
                              },
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
      color: Colors.white,
      border: Border.all(
        color: Colors.white,
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
        color: Colors.white,
        border: Border.all(
          color: Colors.white,
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
            items: <String>['Rent','Sale']
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
}