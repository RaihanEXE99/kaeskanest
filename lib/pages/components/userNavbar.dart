import 'dart:convert';
import 'package:http/http.dart';
import 'package:Kaeskanest/actions/action.dart';
import "package:Kaeskanest/global.dart" as globals;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Kaeskanest/pages/home.dart';
import 'package:Kaeskanest/pages/userNav/login.dart';

import 'package:http/http.dart'as http;

class UserNavBar extends StatefulWidget {
  const UserNavBar({super.key});

  @override
  State<UserNavBar> createState() => _UserNavBarState();
}

class _UserNavBarState extends State<UserNavBar> {
  final secureStorage = FlutterSecureStorage();
  bool hasToken = false;
  String userName = "Guest User";
  String role = "...";
  String userEmail = "...";
  

  @override
  void initState() {
    super.initState();
    _checkAccessTokenOnce();
  }

  Future<bool> _checkAccessTokenOnce() async {
    var token = await secureStorage.read(key: 'access');
    if (token != null) {
      final response = await _getUserData(token);
      if (response.statusCode>=400){
        await secureStorage.deleteAll();
        if(mounted){
          setState(() {
            token=null;
            deleteAllFromSS();
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Login(), // Replace with your login screen
            ),
          );
        }
        return false;
      }
      else{
        final Map<String, dynamic> responseData = json.decode(response.body);
        if(mounted){
          setState(() {
            userName = responseData['full_name'];
            userEmail = responseData['email'];
            role = responseData['role'];
            hasToken = true;
          });
        }
        print(role);
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
  Future<Response> _getUserData(String token) async {
    final Uri uri = Uri.parse("http://" + globals.apiUrl + '/api/users/me/');
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'JWT $token',
    };
    final response = await http.get(uri, headers: headers);
    return response;
  }



void _updateStateWithUserData(Map<String, dynamic> responseData) {
  if (mounted) {
    setState(() {
      userName = responseData['full_name'];
      userEmail = responseData['email'];
      role = responseData['role'];
      hasToken = true;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: hasToken
          ? _userAcc(context) // Show the main app
          : FutureBuilder<bool>(
              key: UniqueKey() ,
              future: _checkAccessTokenOnce(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LinearProgressIndicator(
                    color: Colors.black87,
                  );
                } else if (snapshot.hasError) {
                  return ErrorWidget(snapshot.error.toString());
                } else {
                  return Login(); // Show the login screen or another screen
                }
              },
            ),
    );
  }

  ListView _userAcc(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName:RichText(
            text: TextSpan(
              children: [
                TextSpan(text:
                  role=="1"?"":
                  (role=="2"?"Agent\n":"Organization\n"),
                  style: TextStyle(color: Colors.orange.shade300,fontWeight: FontWeight.bold,fontSize: 10)
                ),
                TextSpan(text:userName,style: TextStyle(fontSize: 25,fontWeight: FontWeight.w700)),
              ]
            ),
          ),
          accountEmail:Text(
            userEmail
          ),
          decoration: BoxDecoration(
            // color: Colors.black87
            color: Colors.black
          ),
        ),
        if(!hasToken)...[
          ListTile(
            leading: Icon(
              Icons.login_rounded,
              color: Colors.black87,
              ),
            title: const Text('Login'),
            onTap: ()=> {
              Navigator.pushNamed(context, '/login')
            },
          )]
        else...[
           ListTile(
            leading: Icon(
              Icons.search_rounded,
              color: Colors.black,
              ),
            title: const Text('Property List'),
            onTap: ()=> {
              Navigator.pushNamed(context, "/propertyList")
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings_outlined,
              color: Colors.black87,
              ),
            title: const Text('Settings'),
            onTap: ()=> {
              Navigator.pushNamed(context, '/settings')
            },
          ),
          ListTile(
            leading: Icon(
              Icons.account_circle_outlined,
              color: Colors.black87,
              ),
            title: const Text('Profile Settings'),
            onTap: ()=> {
              Navigator.pushNamed(context, "/profileSettings")
            },
          ),
          if(role=="2"||role=="3")
            ...[
            // if(role=='3')ListTile(
            //   leading: Icon(
            //     Icons.supervised_user_circle_outlined,
            //     color: Colors.black87,
            //     ),
            //   title: const Text('Organization Settings'),
            //   onTap: ()=> {
            //     Navigator.pushNamed(context, "/organizationSettings")
            //   },
            // ),
            // if(role=='2')ListTile(
            //   leading: Icon(
            //     Icons.supervised_user_circle_outlined,
            //     color: Colors.black87,
            //     ),
            //   title: const Text('Agent Settings'),
            //   onTap: ()=> {
            //     Navigator.pushNamed(context, "/agentSettings")
            //   },
            // ),
            // Container(
            //     margin: EdgeInsets.symmetric(vertical: 10),
            //     child: Row(
            //       children: <Widget>[
            //         Expanded(
            //           child: Divider(
            //             thickness: 1,
            //           ),
            //         ),
            //         // Padding(
            //         //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
            //         //   child: ElevatedButton.icon(onPressed: ()=>{}, icon: Icon(Icons.account_circle_rounded), label: Text("Agent")),
            //         // ),
            //         Expanded(
            //           child: Divider(
            //             thickness: 1,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            if(role=='2')ListTile(
              leading: Icon(
                Icons.notifications,
                color: Colors.black87,
                ),
              title: const Text('Invitations'),
              onTap: ()=> {
                Navigator.pushNamed(context, "/invitations")
              },
            ),
              ListTile(
              leading: Icon(
                Icons.house_outlined,
                color: Colors.black87,
                ),
              title: const Text('My Property'),
              onTap: ()=> {
                Navigator.pushNamed(context, "/myProperty")
              },
            ),
              ListTile(
              leading: Icon(
                Icons.add_home_work_outlined,
                color: Colors.black87,
                ),
              title: const Text('Add Property'),
              onTap: ()=> {
                Navigator.pushNamed(context, "/addProperty")
              },
            ),
            if(role=='3')ListTile(
              leading: Icon(
                Icons.group_outlined,
                color: Colors.black87,
                ),
              title: const Text('My Agents'),
              onTap: ()=> {
                Navigator.pushNamed(context, "/myAgents")
              },
            ),
            if(role=='3')ListTile(
              leading: Icon(
                Icons.group_add_outlined,
                color: Colors.black87,
                ),
              title: const Text('Add Agent'),
              onTap: ()=> {
                Navigator.pushNamed(context, "/addAgent")
              },
            ),
            ]
          ],
          ListTile(
              leading: Icon(
                Icons.logout_outlined,
                color: Colors.black87,
                ),
              title: const Text('Logout'),
              onTap: ()=> {
                logoutUser()
              },
            )
      ],
    );
  }
  Future<void> logoutUser() async{
    await secureStorage.delete(key: "access");
    setState(() {
      hasToken=false;
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomePage(), // Replace with your authenticated screen
      ),
    );
  }
}