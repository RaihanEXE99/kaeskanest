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

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final secureStorage = FlutterSecureStorage();
  bool hasToken = false;
  String userName = "Guest User";
  bool passwordVisible=false;
  late final Future<bool> _checkAccessTokenFuture = _checkAccessTokenOnce();

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController old_password_controller = TextEditingController();
  final TextEditingController new_password_controller = TextEditingController();
  final TextEditingController re_new_password_controller= TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  // @override
  // void dispose() {
  //   userNameController.dispose();
  //   super.dispose();
  // }
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

        setState(() {
          userName = responseData['full_name'];
          hasToken = true;
          userNameController.text = userName;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Navbar(),
      endDrawer: const UserNavBar(),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: DefaultAppBar(title:"Settings")
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
                        "General Profile Settings",
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
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 220,top:20,bottom: 10),
                            child: Text(
                              "Edit Name",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left:25),
                              child: RichText(
                                text: TextSpan(
                                  text:"Current name: ",
                                  style: TextStyle(
                                    // color: Theme.of(context).colorScheme.primary,
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: userName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black54
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 220, 
                                        child: SizedBox(
                                          height: 45,
                                          child: TextFormField(
                                            controller: userNameController,
                                            autofocus: false,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              // labelText: "Your Name",
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
                                      ElevatedButton(
                                        onPressed: ()=>{
                                          _upateUsername()
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(5),
                                              bottomRight: Radius.circular(5)
                                            )
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
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 20,)
                        ],
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
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right:20,top:20,bottom: 10),
                              child: Text(
                                "Change Password",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left:25),
                                  child: Text(
                                    "Current password",
                                    style: TextStyle(
                                      // color: Theme.of(context).colorScheme.primary,
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600
                                    ),
                                  )
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                    padding: const EdgeInsets.only(top: 2,left: 25),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 250,
                                          height: 45,
                                          child: TextFormField(
                                            controller: old_password_controller,
                                            autofocus: false,
                                            obscureText: passwordVisible,
                                            decoration: InputDecoration(
                                              suffixIcon: IconButton(
                                                icon: Icon(passwordVisible
                                                    ? Icons.visibility_off
                                                    : Icons.visibility),
                                                onPressed: () {
                                                  setState(
                                                    () {
                                                      passwordVisible = !passwordVisible;
                                                    },
                                                  );
                                                },
                                              ),
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
                                                borderRadius: BorderRadius.circular(7),
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
                                      ],
                                    ),
                                  ),
                              ),
                              SizedBox(height: 20,)
                            ],
                          ),
                          Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left:25),
                                  child: Text(
                                    "New password",
                                    style: TextStyle(
                                      // color: Theme.of(context).colorScheme.primary,
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600
                                    ),
                                  )
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                    padding: const EdgeInsets.only(top: 2,left: 25),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 250,
                                          height: 45,
                                          child: TextFormField(
                                            controller: new_password_controller,
                                            autofocus: false,
                                            obscureText: passwordVisible,
                                            decoration: InputDecoration(
                                              suffixIcon: IconButton(
                                                icon: Icon(passwordVisible
                                                    ? Icons.visibility_off
                                                    : Icons.visibility),
                                                onPressed: () {
                                                  setState(
                                                    () {
                                                      passwordVisible = !passwordVisible;
                                                    },
                                                  );
                                                },
                                              ),
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
                                                borderRadius: BorderRadius.circular(7),
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
                                      ],
                                    ),
                                  ),
                              ),
                              SizedBox(height: 20,)
                            ],
                          ),
                          Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left:25),
                                  child: Text(
                                    "Confirm new password",
                                    style: TextStyle(
                                      // color: Theme.of(context).colorScheme.primary,
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600
                                    ),
                                  )
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                    padding: const EdgeInsets.only(top: 2,left: 25),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 250,
                                          height: 45,
                                          child: TextFormField(
                                            controller: re_new_password_controller,
                                            autofocus: false,
                                            obscureText: passwordVisible,
                                            decoration: InputDecoration(
                                              suffixIcon: IconButton(
                                                icon: Icon(passwordVisible
                                                    ? Icons.visibility_off
                                                    : Icons.visibility),
                                                onPressed: () {
                                                  setState(
                                                    () {
                                                      passwordVisible = !passwordVisible;
                                                    },
                                                  );
                                                },
                                              ),
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
                                                borderRadius: BorderRadius.circular(7),
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
                                      ],
                                    ),
                                  ),
                              ),
                              SizedBox(height: 20,)
                            ],
                          ),
                          ElevatedButton(
                            onPressed: ()=>{
                              _updatePassowrd()
                            },
                            child: Text(
                              "Update Password"
                            )
                          ),
                          Padding(padding: EdgeInsets.all(15))
                        ],
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
  Future _upateUsername() async {
    final token = await secureStorage.read(key: 'access');
    final response = await http.post(
      Uri.parse("https://"+globals.apiUrl+'/api/user/update_full_name/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'JWT $token',
      },
      body: jsonEncode(<String, String>{
        'new_full_name': userNameController.text,
      })
    );

    if (response.statusCode < 303) {
      return _showPopUpDialog("","Your name has been updated.");
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
  Future<void> _updatePassowrd() async {
    final token = await secureStorage.read(key: 'access');
    final response = await http.post(
      Uri.parse("https://"+globals.apiUrl+'/api/change-password/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'JWT $token',
      },
      body: jsonEncode(<String, String>{
        "old_password":old_password_controller.text,
        "new_password":new_password_controller.text,
        "re_new_password":re_new_password_controller.text
      })
    );

    if (response.statusCode < 303) {
      _showPopUpDialog("","Passwor has been reset successfully.");
    }else if(response.statusCode >= 500){
      _showPopUpDialog("Error","Server 500!");
    }
     else {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return _showPopUpDialog("Error",responseData['detail']);
    }
  }
}