import 'dart:convert';
import 'dart:math';
import 'package:Kaeskanest/pages/navbar/compPropertyCard.dart';
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
  MapScreen({required this.lat, required this.long, required this.postType, required this.propertyCategory, required this.pLocation, required this.initNeed});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class Place {
  final String name;
  final String vicinity;
  final String placeId;
  final double lat;
  final double long;

  Place({required this.name, required this.vicinity, required this.placeId, required this.lat, required this.long});
}

class _MapScreenState extends State<MapScreen> {
  final String apiKey = globals.apiKey;
  late GoogleMapController _mapController;
  var _selectedLocation = LatLng(0, 0);
  Set<Marker> _markers = Set();

  double _radius = 1 * 1000;
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
    if (widget.initNeed) {
      _cameFromHomePage();
    } else {
      _getCurrentPosition();
    }
  }

  void _cameFromHomePage() async {
    if (mounted) {
      setState(() {
        _selectedLocation = LatLng(widget.lat, widget.long);
        Marker newMarker = Marker(
          markerId: MarkerId("Current location"),
          position: _selectedLocation,
          onTap: () => {print("This is your current location!")},
        );

        setState(() {
          _markers.add(newMarker);
          zoomLevel = calculateZoomLevel(_radius, LatLng(widget.lat, widget.long));
          _locationController.text = widget.pLocation;
          selectedSaleOption = widget.postType;
          selectedHomeOption = widget.propertyCategory;
          _selectedLocation = LatLng(widget.lat, widget.long);
        });
        getProperties(_selectedLocation);
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  double calculateZoomLevel(double radius, LatLng center) {
    double earthRadius = 6371.0;
    double radiusInRadians = radius / earthRadius;
    double zoomLevel = 10 - log(radiusInRadians) / log(2);
    return zoomLevel;
  }

  Future<void> autoCompleteSearch(String input) async {
    final response = await http.get(
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
      if (mounted) {
        setState(() {
          _places = _places;
        });
      }
    }
  }

  Future _getLatlong(prediction) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?placeid=$prediction&key=$apiKey'));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return {
        'lat': jsonResponse['result']['geometry']['location']['lat'],
        'long': jsonResponse['result']['geometry']['location']['lng']
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
    if (mounted) {
      setState(() {
        markerIcon = tmpImg;
      });
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted) {
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        Marker newMarker = Marker(
          markerId: const MarkerId("Current location"),
          position: _selectedLocation,
          onTap: () => {print("This is your current location!")},
        );
        setState(() {
          _markers.add(newMarker);
          zoomLevel = calculateZoomLevel(_radius, LatLng(position.latitude, position.longitude));
        });
        getProperties(_selectedLocation);
      });
    }
  }

  Future<void> getProperties(LatLng location) async {
    setState(() {
      zoomLevel = calculateZoomLevel(_radius, location);
    });
    _clearMarkers();
    Marker newMarker = Marker(
      markerId: MarkerId(location.toString()),
      position: location,
    );

    if (mounted) {
      setState(() {
        _markers.add(newMarker);
      });
    }
    Future<http.Response> getRecProperties(LatLng location) async {
      final headers = {
        'Content-Type': 'application/json',
      };
      final Map<String, dynamic> queryParams = {
        "type": selectedSaleOption,
        "category": selectedHomeOption,
        "lat": location.latitude.toString(),
        "long": location.longitude.toString(),
        "radius": (_radius / 1000).toString(),
      };
      final String url = "https://" + globals.apiUrl + '/api/search/';
      final String queryString = Uri(queryParameters: queryParams).query;
      final String requestUrl = '$url?$queryString';
      final response = await http.get(Uri.parse(requestUrl), headers: headers,);
      return response;
    }

    final response = await getRecProperties(_selectedLocation);
    if (response.statusCode < 303) {
      final List<dynamic> responseData = json.decode(response.body);
      if (mounted) {
        setState(() {
          properties = responseData;
          zoomLevel = calculateZoomLevel(_radius, _selectedLocation);
        });
      }
      for (Map<String, dynamic> item in responseData) {
        _addMarker(LatLng(item['lat'], item['long']));
      }
      if (mounted) {
        setState(() {
          _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _selectedLocation, zoom: zoomLevel)));
        });
      }
    } else if (response.statusCode < 510) {
      print("Error! 400");
      final String encodeFirst = json.encode(response.body);
      var data = json.decode(encodeFirst);
      print(data);
    } else {
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
      icon: BitmapDescriptor.fromBytes(tmpImg!),
    );

    if (mounted) {
      setState(() {
        _markers.add(newMarker);
      });
    }
  }

  void _addMeMarker(LatLng position) async {
    if (mounted) {
      setState(() {});
    }
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
      _locationController.text = location.latitude.toString() + "," + location.longitude.toString();
    });
    getProperties(location);
    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _selectedLocation, zoom: zoomLevel)));
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
        title: const Text('Search Property'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              color: Theme.of(context).colorScheme.primary,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 1.0, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.7,
                        child: TextField(
                          controller: _locationController,
                          onChanged: (value) async {
                            await autoCompleteSearch(value);
                            setState(() {});
                          },
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                            hintText: 'Enter a location...',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      if (_locationController.text != "")
                        ElevatedButton.icon(
                            onPressed: () => {setState(() => _locationController.text = "")},
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent),),
                            icon: Icon(Icons.search_off_outlined),
                            label: Text("Clear"),
                        )
                    ],
                  ),
                ),
                _places.isNotEmpty ? SizedBox(
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
                            _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _selectedLocation, zoom: zoomLevel)));
                            setState(() {
                              _places = [];
                            });
                          });
                        },
                      );
                    },
                  ),
                ) : const SizedBox(height: 5,),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _saleDropdown(),
                      _homeDropdown()
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 40, top: 10, bottom: 10),
                  child: Card(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text("Set Radius", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Selected Value: $sliderValue'),
                            Slider(
                              value: sliderValue,
                              min: 1,
                              max: 20,
                              divisions: 19,
                              onChanged: (newValue) {
                                setState(() {
                                  sliderValue = newValue;
                                  _radius = newValue * 1000;
                                });
                                setState(() {
                                  setState(() => {_places = [], zoomLevel = calculateZoomLevel(_radius, _selectedLocation)});
                                  _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _selectedLocation, zoom: zoomLevel)));
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
                    SizedBox(width: 200, child: ElevatedButton.icon(
                        onPressed: () => {
                          _addMeMarker(_selectedLocation),
                          getProperties(_selectedLocation),
                          setState(() => _places = []),
                        },
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.lightBlue)),
                        icon: Icon(Icons.search),
                        label: Text("Search"))),
                  ],
                ),
                SizedBox(height: 10,)
              ]),
            ),
            Container(
              height: 300,
              color: Colors.white60,
              child: _selectedLocation == null
                  ? const Center(child: CircularProgressIndicator())
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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(15),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: properties.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title:  PropertyCard(context,properties[index]),
                    );
                  },
                ),
              )
          ],
        ),
      ),
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
