import 'dart:convert';
import "package:realestate/global.dart" as globals;
import 'package:flutter/material.dart';
import 'package:realestate/pages/components/navbar.dart';
import 'package:realestate/pages/components/userNavbar.dart';
import 'package:http/http.dart'as http;
import 'package:realestate/pages/home.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final secureStorage = FlutterSecureStorage();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorText = "";

  bool onLoadState =false;

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: Padding(
        padding: const EdgeInsets.only(top: 120),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: ()=>{
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(0),
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(0),
                          ),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18, // Adjust as needed
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: ()=>{
                        Navigator.pushNamed(context, "/register")
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(8),
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(8),
                          ),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 18, // Adjust as needed
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                (errorText=="")?Padding(padding: const EdgeInsets.only(top:15),):
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(4)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            color: Colors.white,
                          ),
                          Text(
                            errorText,
                            style: TextStyle(
                              color:Colors.white,
                              fontSize: 12
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: ()=>{},
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              bottomLeft: Radius.circular(5)
                            )
                          )
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.email),
                        )
                      ),
                      SizedBox(
                                width: 220, 
                                child: SizedBox(
                                  height: 45,
                                  child: TextFormField(
                                    controller: emailController,
                                    autofocus: false,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(13),
                                      labelText: 'Enter email address',
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: ()=>{},
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              bottomLeft: Radius.circular(5)
                            )
                          )
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.key),
                        )
                      ),
                      SizedBox(
                                width: 220, 
                                child: SizedBox(
                                  height: 45,
                                  child: TextFormField(
                                    controller: passwordController,
                                    autofocus: false,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Enter password',
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 200,top: 10),
                  child: GestureDetector(
                    onTap: ()=>{
                
                    },
                    child: Text(
                      "Forget password?",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: ElevatedButton(
                        onPressed: ()=>{
                          _loginUser()
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                          )
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: onLoadState?Container(width: 30,height: 5,child: LinearProgressIndicator())
                          : Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        )
                      ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        "Login",
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontFamily: "Poppins",
          fontSize: 18,
          fontWeight: FontWeight.w600
        ),
      ),
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.primary,
              ),
            onPressed: () {
              Navigator.pushNamed(context, "/");
            },
          );
        },
      ),
    );
  }

  Future<void> _loginUser() async {
    Future<http.Response> createJwtToken(String email, String password) async {
      final url = Uri.parse("https://" + globals.apiUrl + '/api/jwt/create/');
      final headers = {
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'email': email.toLowerCase(),
        'password': password,
      });
      final response = await http.post(url, headers: headers, body: body);
      return response;
    }
    setState(() {
      onLoadState = true;
    });
    // final response = await http.post(
    //   Uri.parse("https://"+globals.apiUrl+'/api/jwt/create/'),
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //   },
    //   body: jsonEncode(<String, String>{
    //     'email': emailController.text,
    //     'password': passwordController.text,
    //   })
    // );
    final email = emailController.text;
    final password = passwordController.text;

    final response = await createJwtToken(email, password);

    if (response.statusCode < 303) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData['access']);
      print('Login successful');
      await secureStorage.write(key: 'access', value: responseData['access']);
      await Future.delayed(Duration(seconds: 1)); // Wait for 2 seconds
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(), // Replace with your success screen
        ),
      );
    }else if(response.statusCode >= 500){
      print("Server Error! 500");
      errorText = "Server Error! 500";
    }
    else if(response.statusCode == 400){
      print("Error! 400");
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState((){
        errorText = responseData.values.first[0];
      });
    }
     else {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState((){
        errorText = responseData.values.first;
      });
    }
    setState(() {
      onLoadState = false;
    });
  }
}