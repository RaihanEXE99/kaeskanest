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

class OrganizationSettings extends StatefulWidget {
  const OrganizationSettings({super.key});

  @override
  State<OrganizationSettings> createState() => _OrganizationSettingsState();
}

class _OrganizationSettingsState extends State<OrganizationSettings> {
  final secureStorage = FlutterSecureStorage();
  bool hasToken = false;
  bool passwordVisible=false;
  bool onLoadState =false;
  late final Future<bool> _checkAccessTokenFuture = _checkAccessTokenOnce();

  final TextEditingController pname = TextEditingController();
  final TextEditingController pphone = TextEditingController();
  final TextEditingController pemail = TextEditingController();
  final TextEditingController pdes = TextEditingController();

  late final String rtitle;
  late final String rtype;

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
        Future<http.Response> fetchProfileData(String token) async {
          final url = Uri.parse("https://" + globals.apiUrl + '/api/organization/profile/');
          final headers = {
            'Content-Type': 'application/json',
            'Authorization': 'JWT $token',
          };

          final response = await http.get(url, headers: headers);
          return response;
        }
        final gresponse = await fetchProfileData(token);
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
          final Map<String, dynamic> gresponseData = json.decode(gresponse.body);
          setState(() {
            userId = responseData['id'];
            hasToken = true;
            pname.text = gresponseData['name']??"";
            pphone.text = gresponseData['phone']??"";
            pemail.text = gresponseData['email']??"";
            pdes.text = gresponseData['about_organization']??"";
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
        child: DefaultAppBar(title:"Organization Settings")
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
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top:25),
                    child: Center(
                      child: Text(
                        "Organization Settings",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationThickness: 1,
                        ),
                      ),
                    ),
                  ),  
                  Padding(
                    padding: const EdgeInsets.only(left:20,right: 20,top:20),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // Set the clip behavior of the card
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment:CrossAxisAlignment.stretch,
                          children: [
                            OrganizationSettingsRow(property: pname,rtitle:"Organization Name",rtype:"name"),
                            OrganizationSettingsRow(property: pemail,rtitle:"Email",rtype:"email"),
                            OrganizationSettingsRow(property: pphone,rtitle:"Contact No",rtype:"phone"),
                            OrganizationSettingsRow(property: pdes,rtitle:"About Organization",rtype:"mul"),
                            SizedBox(
                              width: 220,
                              child: ElevatedButton(
                                onPressed: ()=>{
                                  _upateOrganizationSettings()
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)
                                  )
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top:13,bottom: 13),
                                  child: onLoadState?Container(width: 30,height: 5,child: LinearProgressIndicator()):Text(
                                    "Update",
                                    style: TextStyle(
                                      color: Colors.white
                                    ),
                                  ),
                                )
                              ),
                            ),
                      
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                ],
              ),
            );
          }
         },
        
      ),
    );
  }
  Future _upateOrganizationSettings() async {
    final token = await secureStorage.read(key: 'access');
    print("Process Started:");
    setState(() {
      onLoadState = true;
    });
    final response = await http.post(
      Uri.parse("https://"+globals.apiUrl+'/api/organization/profile/update/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'JWT $token',
      },
      body: jsonEncode(<String, String>{
        "name": pname.text,
        "phone": pphone.text,
        "email": pemail.text,
        "description": pdes.text 
    })
    );
    setState(() {
      onLoadState = false;
    });
    print({
        "name": pname.text,
        "phone": pphone.text,
        "email": pemail.text,
        "description": pdes.text 
    });
    if (response.statusCode < 303) {
      return _showPopUpDialog("","Organization settings updated successfully.");
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
      return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
  // Future<void> _updatePassowrd() async {
  //   final token = await secureStorage.read(key: 'access');
  //   final response = await http.post(
  //     Uri.parse("https://"+globals.apiUrl+'/api/change-password/'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //       'Authorization': 'JWT $token',
  //     },
  //     body: jsonEncode(<String, String>{
  //       // "old_password":old_password_controller.text,
  //       // "new_password":new_password_controller.text,
  //       // "re_new_password":re_new_password_controller.text
  //     })
  //   );

  //   if (response.statusCode < 303) {
  //     _showPopUpDialog("","Passwor has been reset successfully.");
  //   }else if(response.statusCode >= 500){
  //     _showPopUpDialog("Error","Server 500!");
  //   }
  //    else {
  //     final Map<String, dynamic> responseData = json.decode(response.body);
  //     return _showPopUpDialog("Error",responseData['detail']);
  //   }
  // }
}

class OrganizationSettingsRow extends StatelessWidget {
  const OrganizationSettingsRow({
    super.key,
    required this.property, required String this.rtitle,required this.rtype
  });

  final TextEditingController property;
  final String rtitle;
  final String rtype;

  @override
  Widget build(BuildContext context) {
    
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.only(top:5,bottom: 5,left:20,right: 20),
                child: Text(
                    rtitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ),
            )
          ),
        ),
        Align(
          alignment: AlignmentDirectional.center,
          child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: SizedBox(
                child: TextFormField(
                  controller: property,
                  autofocus: false,
                  obscureText: false,
                  minLines: rtype=="mul"?3:1,
                  maxLines: rtype=="mul"?5:1,
                  keyboardType: rtype=="phone"?TextInputType.phone:
                                  rtype=="email"?TextInputType.emailAddress:
                                    rtype=="url"?TextInputType.url:
                                      rtype=="mul"?TextInputType.multiline:TextInputType.name,
                  decoration: InputDecoration(
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
                        color: Theme.of(context).colorScheme.primary, // Adjust as needed
                        width: 1.4,
                      ),
                      borderRadius: BorderRadius.circular(2),
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
                    color: Colors.black, // Adjust as needed
                  ),
                  validator: (value) {
                    // Add your validation logic here
                  },
                  onChanged: (value) {
                    // Handle onChanged event if needed
                  },
                ),
              ),
            ),
        ),
        SizedBox(height: 5),
      ],
    );
  }
}