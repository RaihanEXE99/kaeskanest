import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:realestate/pages/userNav/login.dart';

import 'package:http/http.dart' as http;

import "package:realestate/global.dart" as globals;

import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class PropertyDetails extends StatefulWidget {
  final String propertyID;
  PropertyDetails({required this.propertyID});
  @override
  _PropertyDetailsState createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails> {
  bool loadState =false;
  late String propertyID;
  var uploadedBy;
  @override
  void initState() {
    super.initState();
    // Access the userId from the widget's property and store it in the local state
    propertyID = widget.propertyID;
    // Add any additional initialization logic here
  }
  Map<String, dynamic> _propertyDetails = {};
  List<String> propertyImages = [];
  final secureStorage = FlutterSecureStorage();


    Future<bool> _checkAccessTokenOnce() async {
    var token = await secureStorage.read(key: 'access');
    if (token != null) {
      final response = await http.get(
        Uri.parse("https://" + globals.apiUrl + '/api/users/me/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'JWT $token',
        },
      );
      if (response.statusCode>=400){
        await secureStorage.deleteAll();
        setState(() {
          token=null;
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Login(), // Replace with your login screen
          ),
        );
        return false;
      }
      else{
        // final Map<String, dynamic> responseData = json.decode(response.body);
        final pResponse = await http.get(
        Uri.parse("https://" + globals.apiUrl + '/api/property/${propertyID}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'JWT $token',
          },
        );
        final Map<String, dynamic> pData = json.decode(pResponse.body);
        setState(() {
          _propertyDetails=pData;
        });
        List<String> tList = [];
        _propertyDetails['images'].forEach((e) => {
          tList=[...tList,"https://${globals.apiUrl}"+e['image']]
        });
        setState(() {
          propertyImages=tList;
        });
        final int aid = _propertyDetails['user'];
        final agentResponse = await http.get(
        Uri.parse("https://" + globals.apiUrl + '/api/agentDetails/${aid.toString()}/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'JWT $token',
          },
        );
        final Map<String, dynamic> ares = json.decode(agentResponse.body);
        setState(() {
          uploadedBy=ares;
        });
        return true;
      }
    } else {
      // Access token doesn't exist, navigate to the login or onboarding screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Login(), // Replace with your login screen
        ),
      );
      return false;
    }
  }
  late final Future<bool> _checkAccessTokenFuture = _checkAccessTokenOnce();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: FutureBuilder<bool>(
        key: UniqueKey() ,
        future: _checkAccessTokenFuture,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) { 
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle error
            return ErrorWidget(snapshot.error.toString());
          } else {
            return SingleChildScrollView(
              child: Column(children: [
                Card(
                  elevation: 15,
                  margin: EdgeInsets.fromLTRB(20,15,20,5),
                  child: Column(children: [
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => HeroDetailPage(imageUrl: "https://${globals.apiUrl}"+_propertyDetails['thumbnail']),
                            ),
                          );
                        },
                        child: Hero(
                          tag: "thumbnail", // Unique tag for each image
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            // margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                            ),
                            child: Image.network(
                              "https://${globals.apiUrl}"+_propertyDetails['thumbnail'],
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child; // If the image is already loaded, show it
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(top:8.0,bottom: 8),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: 150.0,
                            enlargeCenterPage: true,
                            autoPlay: true,
                            aspectRatio: 1/1,
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enableInfiniteScroll: true,
                            autoPlayAnimationDuration: Duration(milliseconds: 800),
                            viewportFraction: .6,
                          ),
                          items: propertyImages.map((url) {
                            return Builder(
                              builder: (BuildContext context) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => HeroDetailPage(imageUrl: url),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: url, // Unique tag for each image
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                      ),
                                      child: Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child; // If the image is already loaded, show it
                                          } else {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                                    : null,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  ]),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 1,
                    margin: EdgeInsets.fromLTRB(20,15,20,5),
                    child: Column(children: [
                      SizedBox(height: 15,),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10,0,10,0),
                        child: Card(elevation: 0,child: Column(children: [
                            SizedBox(height: 15,),
                            Card(elevation: 0,
                              child: Column(children: [
                                // Align(alignment: Alignment.centerLeft,child: Padding(
                                //   padding: const EdgeInsets.fromLTRB(20,0,0,0),
                                //   child: Text("Overview",overflow: TextOverflow.fade,softWrap: false,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16,color: Theme.of(context).colorScheme.primary)),
                                // )),
                                Align(alignment: Alignment.centerLeft,child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10,0,0,0),
                                  child: Text("Post Type: "+_propertyDetails['post_type']+"  ||  "+"Category: "+_propertyDetails['property_category']+"  ||  "+"Status: "+_propertyDetails['property_status'],
                                  style: TextStyle(fontWeight: FontWeight.w600,fontSize: 11,color: Colors.black45)),
                                )),
                            ])),
                            Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(10,0,0,0),
                            child: Text(_propertyDetails['title'],overflow: TextOverflow.fade,softWrap: false,style: TextStyle(fontWeight: FontWeight.w700,fontSize: 25,color: Theme.of(context).colorScheme.primary)),
                            )),
                            Align(alignment: Alignment.centerLeft,child: Padding(
                              padding: const EdgeInsets.fromLTRB(10,0,0,0),
                              child: Text(_propertyDetails['price_unit']+_propertyDetails['price'].toString()+_propertyDetails['price_type'],style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: Colors.black87),),
                            )),
                            SizedBox(height: 15,),
                          ])
                        ),
                      ),
                      SizedBox(height: 20,),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
                        Card(elevation: 0,
                          child: Column(children: [
                            Icon(Icons.bed,size: 35,color: Colors.black54),
                            Text(_propertyDetails['details']['bed'].toString()+" Bed",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54))
                        ])),
                        Card(elevation: 0,
                          child: Column(children: [
                            Icon(Icons.bathtub_outlined,size: 35,color: Colors.black54),
                            Text(_propertyDetails['details']['bath'].toString()+" Bath",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54))
                        ])),
                        Card(elevation: 0,
                          child: Column(children: [
                            Icon(Icons.square_foot,size: 35,color: Colors.black54),
                            Text(_propertyDetails['details']['size'].toString()+" "+_propertyDetails['details']['size_unit'],style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54))
                        ])),
                        Card(elevation: 0,
                          child: Column(children: [
                            Icon(Icons.timelapse,size: 35,color: Colors.black54),
                            Text(_propertyDetails['details']['available_from'],style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54))
                        ])),
                      ]),
                      Card(elevation: 0,child: Column(children: [
                        Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("Description",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 25,color: Theme.of(context).colorScheme.primary)),
                            )),
                        Align(alignment: Alignment.centerLeft,child: Padding(
                          padding: const EdgeInsets.fromLTRB(20,0,0,0),
                          child: Text(_propertyDetails['desc'],style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15,color: Colors.black54),),
                        )),
                      ],),),
                      Card(elevation: 0,
                        child: Column(children: [
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("Address",softWrap: false,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16,color: Theme.of(context).colorScheme.primary)),
                          )),
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("Area: "+_propertyDetails['loc'],style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54)),
                          )),
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("House No: "+_propertyDetails['address']['house'],style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54)),
                          )),
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("Street: "+_propertyDetails['address']['street'],style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54)),
                          )),
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("City: "+_propertyDetails['address']['city'],style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54)),
                          )),
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("State: "+_propertyDetails['address']['state'],style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54)),
                          )),
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("Country: "+_propertyDetails['address']['country'],style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54)),
                          )),
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("Zip: "+_propertyDetails['address']['zip'].toString(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54)),
                          )),
                      ])),
                      SizedBox(height: 10,),
                      Card(elevation: 0,
                        child: Column(children: [
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("Details",softWrap: false,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16,color: Theme.of(context).colorScheme.primary)),
                          )),
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("Property ID: "+_propertyDetails['id'].toString(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54)),
                          )),
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("Size: "+_propertyDetails['details']['size'].toString()+" "+_propertyDetails['details']['size_unit'],style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54)),
                          )),
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("Bedrooms: "+_propertyDetails['details']['bed'].toString(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54)),
                          )),
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("Bathrooms: "+_propertyDetails['details']['bath'].toString(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54)),
                          )),
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("Floor No: "+_propertyDetails['details']['floor'].toString(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54)),
                          )),
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("Built Year: "+_propertyDetails['details']['built'].toString(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54)),
                          )),
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("Garages: "+_propertyDetails['details']['garage'].toString(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54)),
                          )),
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("Garage Size: "+_propertyDetails['details']['garage_size'].toString(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54)),
                          )),
                          Align(alignment: Alignment.centerLeft,child: Padding(
                            padding: const EdgeInsets.fromLTRB(20,0,0,0),
                            child: Text("Custom ID: "+_propertyDetails['details']['cid'].toString(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.black54)),
                          )),
                      ])),
                      SizedBox(height: 10,),
                      _propertyDetails['video']!=null?SizedBox(
                        width: 250,
                        child: ElevatedButton.icon(
                          icon:Icon(Icons.video_camera_back),
                          onPressed: () {
                            _launchURL("https://${globals.apiUrl}"+_propertyDetails['video']['video']);
                          },
                          label: Text('Watch Video'),
                        ),
                      ):SizedBox(),
                    ]),
                  ),
                ),
                
                uploadedBy!=null?Card(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(height: 18,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.account_circle,color: Colors.black54,size: 20,),
                              ),
                              Center(child: Text("This property is added by "+uploadedBy['name'],style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color: Colors.black54),)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Email: "+(uploadedBy['email']==""?"Not Available":uploadedBy['email']),style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400,color: Colors.black54),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Website: "+(uploadedBy['website']==""?"Not Available":uploadedBy['website']),style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400,color: Colors.black54),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Number: "+(uploadedBy['number']==""?"Not Available":uploadedBy['number']),style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400,color: Colors.black54),),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(onPressed: ()=>{
                                  _showBottomDrawer(context,(uploadedBy['twitter']==""?"Not Available":uploadedBy['twitter']))
                                }, icon: Icon(Icons.link,color: Colors.black54,),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                                  label: Text("Twitter",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),)
                                ),
                          ElevatedButton.icon(onPressed: ()=>{
                            _showBottomDrawer(context,(uploadedBy['facebook_link']==""?"Not Available":uploadedBy['facebook_link']))
                          }, icon: Icon(Icons.link,color: Colors.black54,),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                            label: Text("Facebook",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),)
                          ),
                          ElevatedButton.icon(onPressed: ()=>{
                            _showBottomDrawer(context,(uploadedBy['linkedin_link']==""?"Not Available":uploadedBy['linkedin_link']))
                          }, icon: Icon(Icons.link,color: Colors.black54,),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                            label: Text("Linkedin",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),)
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(onPressed: ()=>{
                            _showBottomDrawer(context,(uploadedBy['pinterest']==""?"Not Available":uploadedBy['pinterest']))
                          }, icon: Icon(Icons.link,color: Colors.black54,),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                            label: Text("Pinterest",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),)
                          ),
                          ElevatedButton.icon(onPressed: ()=>{
                            _showBottomDrawer(context,(uploadedBy['skype_link']==""?"Not Available":uploadedBy['skype_link']))
                          }, icon: Icon(Icons.link,color: Colors.black54,),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                            label: Text("Skype",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),)
                          ),
                          ElevatedButton.icon(onPressed: ()=>{
                            _showBottomDrawer(context,(uploadedBy['website']==""?"Not Available":uploadedBy['website']))
                          }, icon: Icon(Icons.link,color: Colors.black54,),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                            label: Text("Website",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),)
                          ),
                        ],
                      ),
                      SizedBox(height: 15,),
                    ],
                  )
                ):Text("LOADING..."),
              
              ]),
            );
          }
         },
      ),
    );
  }
  void _showBottomDrawer(BuildContext context, String s) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                s,
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}

class HeroDetailPage extends StatelessWidget {
  final String imageUrl;

  HeroDetailPage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: imageUrl, // Same tag as the original Hero
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
