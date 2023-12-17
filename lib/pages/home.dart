import 'dart:convert';
// import 'dart:ffi';
import 'dart:math';

import 'package:Kaeskanest/pages/navbar/propertyList.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart'as http;
import 'package:http/http.dart';
import 'package:Kaeskanest/global.dart' as globals;
import 'package:Kaeskanest/pages/components/navbar.dart';
import 'package:Kaeskanest/pages/components/userNavbar.dart';
import 'package:Kaeskanest/pages/components/appbar.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:geolocator/geolocator.dart';

import 'package:permission_handler/permission_handler.dart';

import 'dart:async'; 
import 'dart:typed_data'; 
import 'dart:ui' as ui;

import 'package:Kaeskanest/pages/navbar/property.dart';




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
  String selectedSaleOption = 'Rent';
  String selectedHomeOption = 'Home';

  final _locationController = TextEditingController();

  List<Place> _places = [];

  FocusNode textFocusNode = FocusNode();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ScrollController scrollController = ScrollController();

  final String apiKey = globals.apiKey;

  var properties = [];
  var searchedProperties = [];

  LatLng sendLocation=LatLng(0, 0) ;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }
  Future<void> _loadProperties() async {
    final response = await http.get(
      Uri.parse("https://" + globals.apiUrl + '/api/hprop/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode>=400){
        print("ERROR 400!");
      }
      else{
        final List<dynamic> responseData = json.decode(response.body);
        for (Map<String, dynamic> item in responseData) {
          print(item);
        }
        if(mounted){
          setState(() {
            properties = responseData;
          });
        }
      }
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

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      drawer: const Navbar(),
      endDrawer: const UserNavBar(),
      appBar: _appBar(context),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [ 
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/app/bgImage.jpg'), // Replace with your image path
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                margin: EdgeInsets.only(top:30,bottom:30,left:20,right:20), 
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        "Find Your Property",
                        style: TextStyle(
                          fontSize:20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                    ),
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
                      padding: const EdgeInsets.only(top:20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 250, 
                            height: 45,
                            child: TextFormField(
                              autofocus: false,
                              obscureText: false,
                              controller: _locationController,
                              focusNode: textFocusNode,
                              key:formKey,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                isDense: true,
                                contentPadding: EdgeInsets.all(13),
                                hintText: "Find Properties by location ..",
                                labelStyle: const TextStyle(
                                  fontSize: 16, // Adjust as needed
                                  fontWeight: FontWeight.normal, // Adjust as needed
                                  color: Colors.black54, // Adjust as needed
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
                          SizedBox(
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  // MAIN
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MapScreen(lat: sendLocation.latitude, long: sendLocation.longitude, postType: selectedSaleOption, propertyCategory: selectedHomeOption, pLocation: _locationController.text, initNeed: true,),
                                    ),
                                  );
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
                                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                child: Icon(
                                  Icons.search
                                )
                              ),
                            ),
                          )
                        ],
                      ),
                    ),  
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        color: Colors.white,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _places.length>4?4:_places.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(_places[index].name),
                              subtitle: Text(_places[index].vicinity),
                              onTap: () {
                                setState(() {
                                  _locationController.text = _places[index].name;
                                  sendLocation = LatLng(_places[index].lat, _places[index].long);
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
                      ),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              ),
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,0,30),
              child: SizedBox(
                width: 200,
                child: ElevatedButton(onPressed: ()=>{
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(lat: 0, long: 0, postType: '', propertyCategory: '', pLocation: '', initNeed: false,),
                    ),
                  )
                }, child: Text("Load More",style: TextStyle(fontSize: 20),)),
              ),
            )
          ]
        ),
      )
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
                  ImageLoader(imageUrl: "https://${globals.apiUrl}"+ppt['thumbnail'],),
                  // Image.network(
                  //   "https://${globals.apiUrl}"+ppt['thumbnail'],
                  //   height: 160,
                  //   width: double.infinity,
                  //   fit: BoxFit.cover,
                  // ),
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
                            Icon(Icons.maps_home_work_sharp,color: Theme.of(context).colorScheme.primary),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Text(
                                ppt['title'],
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Theme.of(context).colorScheme.primary,
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
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

class ImageLoader extends StatelessWidget {
  final String imageUrl;

  ImageLoader({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: precacheImage(NetworkImage(imageUrl), context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Image successfully loaded
          return Image.network(imageUrl,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover
          );
        } else if (snapshot.hasError) {
          // Error loading image
          return Text('Error loading image');
        } else {
          // Image is still loading
          return Padding(
            padding: const EdgeInsets.all(25),
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}