import 'dart:convert';
import 'package:realestate/actions/action.dart';
import "package:realestate/global.dart" as globals;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:realestate/pages/components/appbar.dart';
import 'package:realestate/pages/components/navbar.dart';
import 'package:realestate/pages/components/userNavbar.dart';
import 'package:realestate/pages/userNav/login.dart';

import 'package:http/http.dart'as http;

class AddAgent extends StatefulWidget {
  const AddAgent({super.key});

  @override
  State<AddAgent> createState() => _AddAgentState();
}

class _AddAgentState extends State<AddAgent> {
  final secureStorage = FlutterSecureStorage();
  bool hasToken = false;
  bool onLoadState =false;
  late final Future<bool> _checkAccessTokenFuture = _checkAccessTokenOnce();
  final TextEditingController pemail = TextEditingController();

  late int userId;
  List<dynamic> _suggestions = [];
  var loading = false;
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
        if (response.statusCode>=400){
          await secureStorage.deleteAll();
          setState(() {
            // token=null;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Login(), // Replace with your login screen
            ),
          );
          return false;
        }
        else{
          setState(() {
            hasToken = true;
          });
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
  
  void _getSuggestions(String query) async {
    final aApiUrl = "https://" + globals.apiUrl + '/api/autocomplete_agent_emails/';
    final response = await http.get(Uri.parse('$aApiUrl?q=$query'));

    if (response.statusCode == 200) {
      final List<dynamic> suggestions = json.decode(response.body);
      // final data = jsonDecode(response.body);
      // List<String> suggestions = Map<String, dynamic>.from(data);
      print(List);
      setState(() {
        _suggestions = suggestions;
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
        child: DefaultAppBar(title:"Add Agent")
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
            return onLoadState?Center(child: CircularProgressIndicator()):SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    "assets/img/cardimage.jpg",
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ), 
                  Padding(
                    padding: const EdgeInsets.only(left:20,right: 20,top:20),
                    child: Card(
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // Set the clip behavior of the card
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment:CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: AlignmentDirectional.center,
                              child: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: SizedBox(
                                    child: TextFormField(
                                      controller: pemail,
                                      autofocus: false,
                                      obscureText: false,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        hintText: "Search agent by email ..",
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
                                            color: Colors.black87, // Adjust as needed
                                            width: 1.4,
                                          ),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.black87, // Adjust as needed
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 16, // Adjust as needed
                                        fontWeight: FontWeight.normal, // Adjust as needed
                                        color: Colors.white, // Adjust as needed
                                      ),
                                      validator: (value) {
                                        // Add your validation logic here
                                      },
                                      onChanged: (query) {
                                        _getSuggestions(query);
                                      },
                                    ),
                                  ),
                                ),
                            ),
                            
                            // SizedBox(height: 5),
                            // SizedBox(
                            //   width: 220,
                            //   child: ElevatedButton(
                            //     onPressed: ()=>{
                            //       // _addAgent()
                            //     },
                            //     style: ElevatedButton.styleFrom(
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(5)
                            //       )
                            //     ),
                            //     child: Padding(
                            //       padding: const EdgeInsets.only(top:13,bottom: 13),
                            //       child: onLoadState?Container(width: 30,height: 5,child: LinearProgressIndicator()):Text(
                            //         "Search Agent",
                            //         style: TextStyle(
                            //           color: Colors.white
                            //         ),
                            //       ),
                            //     )
                            //   ),
                            // ),
                      
                          ],
                        ),
                      ),
                    ),
                  ),
                  _suggestions.isNotEmpty
                            ? ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _suggestions.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  onTap: ()=>{
                                    setState(() {
                                      pemail.text=_suggestions[index]['email'];
                                      loading=true;
                                    }),
                                    _addAgent()
                                  },
                                  title: Container(
                                    margin: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.0, // Set border width
                                      ),
                                      borderRadius: BorderRadius.circular(8.0), // Set border radius
                                    ), // Set your desired background color here
                                    padding: EdgeInsets.all(8), // Adjust padding as needed
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _suggestions[index]['name'],//comeback
                                              style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold), // Set text color
                                            ),
                                            Text(
                                              _suggestions[index]['email'],//comeback
                                              style: TextStyle(color: Colors.orange), // Set text color
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(Icons.send,color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                            : SizedBox(), 
                ],
              ),
            );
          }
         },
        
      ),
    );
  }
  Future _addAgent() async {
    final token = await secureStorage.read(key: 'access');
    setState(() {
      onLoadState = true;
    });
    final response = await http.post(
      Uri.parse("https://"+globals.apiUrl+'/api/addAgent/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'JWT $token',
      },
      body: jsonEncode(<String, String>{
        "email": pemail.text,
    })
    );
    setState(() {
      onLoadState = false;
    });
    if (response.statusCode < 303) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return _showPopUpDialog("",responseData['message']);
    }
    else if(response.statusCode == 400){
      final Map<String, dynamic> responseData = json.decode(response.body);
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(''),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(responseData['message']),
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
      print(response.body);
      return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Internal Error 500!"),
                Text(response.body)
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

  Future _showPopUpDialog(String type,String bodyTXT) {
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