import 'dart:convert';
import 'package:Kaeskanest/actions/action.dart';
import "package:Kaeskanest/global.dart" as globals;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Kaeskanest/pages/components/appbar.dart';
import 'package:Kaeskanest/pages/components/navbar.dart';
import 'package:Kaeskanest/pages/components/userNavbar.dart';
import 'package:Kaeskanest/pages/userNav/login.dart';

import 'package:http/http.dart'as http;

class Invitations extends StatefulWidget {
  const Invitations({super.key});

  @override
  State<Invitations> createState() => _InvitationsState();
}

class _InvitationsState extends State<Invitations> {
  final secureStorage = FlutterSecureStorage();
  bool hasToken = false;
  bool onLoadState =false;
  late final Future<bool> _checkAccessTokenFuture = _checkAccessTokenOnce();
  List<dynamic> invitations = [];

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
        final Map<String, dynamic> responseData = json.decode(response.body);
        Future<http.Response> fetchAllInvitations(String token) async {
          final url = Uri.parse("https://" + globals.apiUrl + '/api/invitations/');
          final headers = {
            'Content-Type': 'application/json',
            'Authorization': 'JWT $token',
          };

          final response = await http.get(url, headers: headers);
          return response;
        }
        final gresponse = await fetchAllInvitations(token);
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
          print(gresponse.body);
          final List<dynamic> gresponseData = json.decode(gresponse.body);
          setState(() {
            invitations =gresponseData;
            hasToken = true;
            token=token;
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

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Navbar(),
      endDrawer: const UserNavBar(),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: DefaultAppBar(title:"Invitation")
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
            return onLoadState?Center(child: CircularProgressIndicator()):invitations.isNotEmpty?ListView.builder(
              itemCount: invitations.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text('You received an invitation from the organization called ${invitations[index]['organization']}. Are you willing to join this organization?',style: TextStyle(fontSize: 15,),),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  onLoadState=true;
                                });
                                _acceptInvitation(invitations[index]['id']);
                              },
                              child: Text('Accept'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  onLoadState=true;
                                });
                                _rejectInvitation(invitations[index]['id']);
                              },
                              child: Text('Reject'),
                            ),
                          ],
                        ),
                        SizedBox(height: 15,)
                      ],
                    )
                );
              },
            ):Center(child: Text("You have no invitation!",style: TextStyle(fontSize: 14),));
          }
         },
      ),
    );
  }
  void _acceptInvitation(invitation) async {
    var token = await secureStorage.read(key: 'access');
    final url = Uri.parse("https://" + globals.apiUrl + '/api/invitation/${invitation}/accept/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'JWT $token',
    };

    final response = await http.post(url, headers: headers);
    print(response.body);
    setState(() {
      onLoadState=false;
    });
    Navigator.pushNamed(context, "/invitations");
  }
  void _rejectInvitation(invitation) async {
    var token = await secureStorage.read(key: 'access');
    final url = Uri.parse("https://" + globals.apiUrl + '/api/invitation/${invitation}/reject/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'JWT $token',
    };
    setState(() {
      onLoadState=false;
    });
    final response = await http.post(url, headers: headers);
    print(response);
    Navigator.pushNamed(context, "/invitations");
  }
}