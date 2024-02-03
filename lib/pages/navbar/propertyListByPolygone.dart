import 'dart:convert';
import 'dart:math';
import 'package:Kaeskanest/pages/components/appbar.dart';
import 'package:Kaeskanest/pages/components/navbar.dart';
import 'package:Kaeskanest/pages/components/userNavbar.dart';
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

class MapScreenSearchByPolygon extends StatefulWidget {
  final double lat;
  final double long;
  final String postType;
  final String propertyCategory;
  final String pLocation;
  final bool initNeed;
  MapScreenSearchByPolygon({
    required this.lat,
    required this.long,
    required this.postType,
    required this.propertyCategory,
    required this.pLocation,
    required this.initNeed,
  });
  @override
  _MapScreenStateSearchByPolygon createState() => _MapScreenStateSearchByPolygon();
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

class _MapScreenStateSearchByPolygon extends State<MapScreenSearchByPolygon> {
  final String apiKey = globals.apiKey;
  late GoogleMapController _mapController;
  var _selectedLocation = LatLng(0, 0);
  // Set<Marker> _markers = Set();

  double _radius = 5 * 1000;
  double zoomLevel = 14;

  final TextEditingController _locationController = TextEditingController();
  List<Place> _places = [];

  var properties = [];

  String selectedSaleOption = 'Rent';
  String selectedHomeOption = 'Home';

  Uint8List? markerIcon;

  double sliderValue = 5.0;

  Set<Marker> _markers = Set();
  Set<Polygon> _polygons = Set();
  List<LatLng> _polygonPoints = [];

  @override
  void initState() {
    super.initState();
    if (widget.initNeed) {
      _cameFromHomePage();
    } else {
      _getCurrentPosition();
    }
  }

  void initBlackDot()async{
    final tmpImg = await getBytesFromAsset('assets/icons/bdot.png', 25);
    if(mounted){
      setState(() {
        markerIcon=tmpImg;
      });
    }
  }

  void _cameFromHomePage() async {
    if (mounted) {
    final tmpImg = await getBytesFromAsset('assets/icons/bdot.png', 25);
      setState(() {
        setState(() {
        markerIcon = tmpImg;
      });
        // _selectedLocation = LatLng(widget.lat, widget.long);
        // Marker newMarker = Marker(
        //   markerId: MarkerId("Current location"),
        //   position: _selectedLocation,
        // );

        setState(() {
          // _markers.add(newMarker);
          zoomLevel = 14;
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
    if (mounted) {
      final tmpImg = await getBytesFromAsset('assets/icons/bdot.png', 25);
      await Geolocator.requestPermission();
      setState(() {
        markerIcon = tmpImg;
      });
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
          // Marker newMarker = Marker(
          //   markerId: const MarkerId("Current location"),
          //   position: _selectedLocation,
          // );
          setState(() {
            // _markers.add(newMarker);
            // zoomLevel = calculateZoomLevel(_radius, LatLng(position.latitude, position.longitude));
          });
          getProperties(_selectedLocation);
        });
      }
    }
  }

  Future<void> getProperties(LatLng location) async {
    setState(() {
      // zoomLevel = calculateZoomLevel(_radius, location);
    });
    _clearMarkers();
    // Marker newMarker = Marker(
    //   markerId: MarkerId(location.toString()),
    //   position: location,
    // );

    if (mounted) {
      setState(() {
        // _markers.add(newMarker);
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
          // zoomLevel = calculateZoomLevel(_radius, _selectedLocation);
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
      });
    }
  }

  // void _clearPolygon() {
  //   setState(() {
  //     _polygonPoints.clear();
  //     _updatePolygons();
  //   });
  // }


  void _updatePolygons() {
    if (_polygonPoints.length > 2) {
      // _polygons.clear();
      _polygons.add(
        Polygon(
          polygonId: PolygonId('searchArea'),
          points: _polygonPoints,
          strokeWidth: 2,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.3),
        ),
      );
    } else {
      // _polygons.clear();
    }
  }

  void _drawPolygon() {
    if (_polygonPoints.length > 2) {
      LatLngBounds bounds = _getPolygonBounds(_polygonPoints);
      getPropertiesWithinBounds(bounds);
      setState(() {
        _updatePolygons();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please draw a complete polygon with at least 3 points. You can draw polygone by tapping on the map!'),
        ),
      );
    }
  }
  
  LatLngBounds _getPolygonBounds(List<LatLng> polygonPoints) {
    double minLat = polygonPoints[0].latitude;
    double maxLat = polygonPoints[0].latitude;
    double minLng = polygonPoints[0].longitude;
    double maxLng = polygonPoints[0].longitude;

    for (LatLng point in polygonPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void getPropertiesWithinBounds(LatLngBounds bounds) async {
    double minLat = bounds.southwest.latitude;
    double maxLat = bounds.northeast.latitude;
    double minLng = bounds.southwest.longitude;
    double maxLng = bounds.northeast.longitude;

    final type = selectedSaleOption;
    final cat = selectedHomeOption;

    final headers = {
        'Content-Type': 'application/json',
      };
    final Map<String, dynamic> queryParams = {
      "minlat": minLat.toString(),
      "maxlat": maxLat.toString(),
      "minlong": minLng.toString(),
      "maxlong": maxLng.toString(),
      "type": type,
      "category": cat,
    };
    final String url = 'https://' + globals.apiUrl + '/api/polygon/';
    final String queryString = Uri(queryParameters: queryParams).query;
    final String requestUrl = '$url?$queryString';
    final response = await http.get(Uri.parse(requestUrl), headers: headers,);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      if (mounted) {
        setState(() {
          properties = responseData;
          // zoomLevel = calculateZoomLevel(_radius, bounds.getCenter());
        });
      }
      // _clearMarkers();
      for (Map<String, dynamic> item in responseData) {
        _addMarker(LatLng(item['lat'], item['long']));
      }
      if (mounted) {
        setState(() {
          // _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: bounds.getCenter(), zoom: zoomLevel)));
        });
      }
      print(responseData.length);
    } else {
      // Handle errors
      print("Error! ${response.statusCode}");
      final String encodeFirst = json.encode(response.body);
      var data = json.decode(encodeFirst);
      print(data);
    }
  }

  void _clearMarkers() {
    setState(() {
      // _markers = {};
      _polygonPoints.clear();
      _markers.clear();
      _polygons.clear();
    });
  }

  void _clearMarkersAndPolygon() {
    setState(() {
      _polygonPoints.clear();
      _markers.clear();
      _polygons.clear();
      properties=[];
    });
  }

  // Future<Uint8List> getMarkerIcon() async {
  //   final tmpImg = await getBytesFromAsset('assets/map/dot.png', 50); // Adjust the size as needed
  //   return tmpImg!;
  // }

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
        child: Padding(
          padding: const EdgeInsets.only(top:15),
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
                        // if (_locationController.text != "")
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
                              _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _selectedLocation, zoom: zoomLevel)));
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
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: ()=>{
                          _clearMarkersAndPolygon()
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                        ),
                        icon: Icon(Icons.clear),
                        label: Text("Clear drawing"),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _drawPolygon,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                        ),
                        icon: Icon(Icons.search),
                        label: Text("Draw Your Area"),
                      ),
                    ],
                  ),
                ]),
              ),
          
              Padding(
                padding: const EdgeInsets.only(top:8.0),
                child: Container(
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
                        polygons: _polygons,
                        onTap: (LatLng point) {
                          setState(() {
                            _polygonPoints.add(point);
                            _markers.add(Marker(
                              markerId: MarkerId(point.toString()),
                              position: point,
                              icon: BitmapDescriptor.fromBytes(markerIcon!),
                            ));
                            _updatePolygons();
                          });
                        },
                      ),
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
