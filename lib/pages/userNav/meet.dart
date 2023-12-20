import 'dart:convert';
import 'package:Kaeskanest/actions/action.dart';
import "package:Kaeskanest/global.dart" as globals;
import 'package:Kaeskanest/pages/userNav/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Kaeskanest/pages/components/appbar.dart';
import 'package:Kaeskanest/pages/components/navbar.dart';
import 'package:Kaeskanest/pages/components/userNavbar.dart';
import 'package:Kaeskanest/pages/userNav/login.dart';
import 'package:Kaeskanest/pages/navbar/property.dart'; 

import 'package:http/http.dart'as http;

class Meet extends StatefulWidget {
  const Meet({super.key});

  @override
  State<Meet> createState() => _MeetState();
}

class _MeetState extends State<Meet> {
  final secureStorage = FlutterSecureStorage();
  bool onLoadState=false;
  late final Future<bool> _checkAccessTokenFuture = _checkAccessTokenOnce();

  var conversations = [];

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
        Future<http.Response> fetchMyCoversations(String token) async {
          final url = Uri.parse("https://" + globals.apiUrl + '/api/meet/');
          final headers = {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'JWT $token',
          };

          final response = await http.get(url, headers: headers);
          return response;
        }
        final gresponse = await fetchMyCoversations(token);
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
          final Map<String, dynamic> gresponseData = json.decode(gresponse.body);
          print(gresponseData['users']);
          setState(() {
            conversations=gresponseData['users'];
          });
          // print(gresponseData);
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
        child: DefaultAppBar(title:"Conversations")
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
            return conversations.isNotEmpty?SingleChildScrollView(
              child: Column(
                children: [  
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: ()=>{
                          print(conversations[index]['id']),
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Chat(chatID: conversations[index]["id"].toString()),
                            ),
                          )
                        },
                        child: Card(
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.chat_sharp,size: 60,),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(conversations[index]['full_name'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                                    Text(conversations[index]['email']),
                                  ],
                                )
                              ],
                            )
                          ),
                      );
                    },
                  )
                ],
              ),
            ):Center(child:Text("No Conversations yet!"));
          }
         },
        
      ),
    );
  }
}