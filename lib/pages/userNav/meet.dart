import 'dart:convert';
import 'package:Kaeskanest/actions/action.dart';
import "package:Kaeskanest/global.dart" as globals;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Kaeskanest/pages/components/appbar.dart';
import 'package:Kaeskanest/pages/components/navbar.dart';
import 'package:Kaeskanest/pages/components/userNavbar.dart';
import 'package:Kaeskanest/pages/userNav/login.dart';
import 'package:Kaeskanest/pages/navbar/property.dart'; 

import 'package:http/http.dart'as http;

class MyProperty extends StatefulWidget {
  const MyProperty({super.key});

  @override
  State<MyProperty> createState() => _MyPropertyState();
}

class _MyPropertyState extends State<MyProperty> {
  final secureStorage = FlutterSecureStorage();
  bool onLoadState=false;
  late final Future<bool> _checkAccessTokenFuture = _checkAccessTokenOnce();

  var properties = [];

  late int userId;
  @override
  void initState() {
    super.initState();
  }
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Login(), // Replace with your login screen
          ),
        );
        return false;
      }
      else{
        Future<http.Response> fetchMyProperties(String token) async {
          final url = Uri.parse("https://" + globals.apiUrl + '/api/myProperty/');
          final headers = {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'JWT $token',
          };

          final response = await http.get(url, headers: headers);
          return response;
        }
        final gresponse = await fetchMyProperties(token);
        if (response.statusCode>=400){
          await secureStorage.deleteAll();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Login(), // Replace with your login screen
            ),
          );
          return false;
        }
        else{
          final List<dynamic> gresponseData = json.decode(gresponse.body);
          setState(() {
            properties=gresponseData;
          });
          print(gresponseData);
          return true;
        }
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

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Navbar(),
      endDrawer: const UserNavBar(),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: DefaultAppBar(title:"My Property")
        ),
      body: FutureBuilder<bool>(
        key:  UniqueKey() ,
        future: _checkAccessTokenFuture,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) { 
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle error
            return ErrorWidget(snapshot.error.toString());
          } else {
            return properties.isNotEmpty?SingleChildScrollView(
              child: Column(
                children: [  
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
            ):Center(child:Text("You didn't list any property yet."));
          }
         },
        
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
                  Image.network(
                    "https://" + globals.apiUrl +ppt['thumbnail'],
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

  Future _upateMyProperty() async {
    final token = await secureStorage.read(key: 'access');
    setState(() {onLoadState=true;});
    final response = await http.post(
      Uri.parse("https://"+globals.apiUrl+'/api/profile/update/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'JWT $token',
      },
      body: jsonEncode(<String, String>{
    })
    ).whenComplete(() => setState(() {onLoadState=false;}));
    if (response.statusCode < 303) {
      return _showPopUpDialog("","Profile settings updated successfully.",context);
    }
    else if(response.statusCode == 400){
      final Map<String, dynamic> responseData = json.decode(response.body);
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(responseData['error']),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
     else {
      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);
      return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(responseData['error']??"Internal Error!"),
                Text(response.statusCode.toString()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    }
  }

  Future _showPopUpDialog(String type,String bodyTXT, BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(type),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(bodyTXT),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}