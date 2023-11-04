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
            return ListView.builder(
              itemCount: invitations.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(16),
                  child: ListTile(
                    title: Text('Organization: ${invitations[index]['organization']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _acceptInvitation(invitations[index]['id']);
                          },
                          child: Text('Accept'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            _rejectInvitation(invitations[index]['id']);
                          },
                          child: Text('Reject'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
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
    Navigator.pushNamed(context, "/invitations");
  }
  void _rejectInvitation(invitation) async {
    var token = await secureStorage.read(key: 'access');
    final url = Uri.parse("https://" + globals.apiUrl + '/api/invitation/${invitation}/reject/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'JWT $token',
    };

    final response = await http.post(url, headers: headers);
    Navigator.pushNamed(context, "/invitations");
  }
}

// class InvitationCard extends StatelessWidget {
//   final Map<String, dynamic> invitation;

//   InvitationCard(this.invitation, token);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.all(16),
//       child: ListTile(
//         title: Text('Organization: ${invitation['organization']}'),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 _acceptInvitation(invitation['organization']);
//               },
//               child: Text('Accept'),
//             ),
//             SizedBox(width: 8),
//             ElevatedButton(
//               onPressed: () {
//                 // Handle Reject button click
//               },
//               child: Text('Reject'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
  
// }