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

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final secureStorage = FlutterSecureStorage();
  bool hasToken = false;
  bool passwordVisible=false;
  late final Future<bool> _checkAccessTokenFuture = _checkAccessTokenOnce();

  final TextEditingController pname = TextEditingController();
  final TextEditingController pnumber = TextEditingController();
  final TextEditingController pemail = TextEditingController();
  final TextEditingController pskype = TextEditingController();
  
  final TextEditingController pfb = TextEditingController();
  final TextEditingController pli = TextEditingController();
  final TextEditingController ptitle = TextEditingController();
  final TextEditingController pwebsite = TextEditingController();
  final TextEditingController ptwitter = TextEditingController();
  final TextEditingController pint = TextEditingController();
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
        final gresponse = await http.get(
        Uri.parse("https://" + globals.apiUrl + '/api/profiles/'+responseData['id'].toString()+'/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'JWT $token',
          },
        );
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
            pname.text = gresponseData['name'];
            pnumber.text = gresponseData['number'];
            pemail.text = gresponseData['email'];
            pskype.text = gresponseData['skype_link'];
            pfb.text = gresponseData['facebook_link'];
            pli.text = gresponseData['linkedin_link'];
            ptitle.text = gresponseData['title'];
            pwebsite.text = gresponseData['website'];
            ptwitter.text = gresponseData['twitter'];
            pint.text = gresponseData['pinterest'];
            pdes.text = gresponseData['description'];
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
        child: DefaultAppBar(title:"Profile Settings")
        ),
      body: FutureBuilder<bool>(
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
                        "Profile Settings",
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
                            profileSettingsRow(property: pname,rtitle:"Name",rtype:"name"),
                            profileSettingsRow(property: pnumber,rtitle:"Number",rtype:"phone"),
                            profileSettingsRow(property: pemail,rtitle:"Email",rtype:"email"),
                            profileSettingsRow(property: ptitle,rtitle:"Title",rtype:"name"),
                            profileSettingsRow(property: pskype,rtitle:"Skype",rtype:"url"),
                            profileSettingsRow(property: pfb,rtitle:"Facebook",rtype:"url"),
                            profileSettingsRow(property: pli,rtitle:"Linkedin",rtype:"url"),
                            profileSettingsRow(property: pwebsite,rtitle:"Website",rtype:"url"),
                            profileSettingsRow(property: ptwitter,rtitle:"Twitter",rtype:"url"),
                            profileSettingsRow(property: pint,rtitle:"Pinterest",rtype:"url"),
                            profileSettingsRow(property: pdes,rtitle:"Description",rtype:"mul"),
                            SizedBox(
                              width: 220,
                              child: ElevatedButton(
                                onPressed: ()=>{
                                  _upateProfileSettings()
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)
                                  )
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top:13,bottom: 13),
                                  child: Text(
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
  Future _upateProfileSettings() async {
    final token = await secureStorage.read(key: 'access');
    final response = await http.post(
      Uri.parse("https://"+globals.apiUrl+'/api/profile/update/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'JWT $token',
      },
      body: jsonEncode(<String, String>{
        "name": pname.text,
        "number": pnumber.text,
        "skype_link": pskype.text,
        "facebook_link": pfb.text,
        "linkedin_link": pli.text,
        "title": ptitle.text,
        "email": pemail.text,
        "website": pwebsite.text,
        "twitter": ptwitter.text,
        "pinterest": pint.text,
        "description": pdes.text 
    })
    );
    print({
        "name": pname.text,
        "number": pnumber.text,
        "skype_link": pskype.text,
        "facebook_link": pfb.text,
        "linkedin_link": pli.text,
        "title": ptitle.text,
        "email": pemail.text,
        "website": pwebsite.text,
        "twitter": ptwitter.text,
        "pinterest": pint.text,
        "description": pdes.text 
    });
    if (response.statusCode < 303) {
      return _showPopUpDialog("","Profile settings updated successfully.");
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

class profileSettingsRow extends StatelessWidget {
  const profileSettingsRow({
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