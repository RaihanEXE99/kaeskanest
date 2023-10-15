import 'dart:convert';
import "package:realestate/global.dart" as globals;
import 'package:flutter/material.dart';
import 'package:realestate/pages/components/navbar.dart';
import 'package:realestate/pages/components/userNavbar.dart';
import 'package:http/http.dart'as http;
import 'package:realestate/pages/userNav/regSuccess.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String selectRole = 'Normal User';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String errorText = "";

  bool onLoadState =false;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: SingleChildScrollView(
        child: Padding(
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
                            'Register',
                            style: TextStyle(
                              fontSize: 18, // Adjust as needed
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: ()=>{
                          Navigator.pushNamed(context, "/login")
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
                            'Login',
                            style: TextStyle(
                              fontSize: 18, // Adjust as needed
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
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
                            padding: const EdgeInsets.only(top:13,bottom: 13),
                            child: Text(
                              "Role"
                            ),
                          )
                        ),
                        SizedBox(
                          width: 220, 
                          child: SizedBox(
                            height: 45,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2.0,         
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: DropdownButton<String>(
                                  icon: Container(),
                                  underline: Container(),
                                  value: selectRole,
                                  elevation: 0,
                                  borderRadius: BorderRadius.circular(10),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectRole = newValue!;
                                    });
                                  },
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                    items: <String>['Normal User', 'Agent','Organization']
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                              ),
                            )
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
                            padding: const EdgeInsets.only(top:13,bottom: 13),
                            child: Text(
                              "Name"
                            ),
                          )
                        ),
                        SizedBox(
                          width: 220, 
                          child: SizedBox(
                            height: 45,
                            child: TextFormField(
                              controller: nameController,
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'Enter your name',
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
                          child:  Padding(
                            padding: const EdgeInsets.only(top:13,bottom: 13),
                            child: Text(
                              "Email"
                            ),
                          )
                        ),
                        SizedBox(
                          width: 220, 
                          child: SizedBox(
                            height: 45,
                            child: TextFormField(
                              maxLines: 1,
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
                          child:  Padding(
                            padding: const EdgeInsets.only(top:13,bottom: 13),
                            child: Text(
                              "Phone"
                            ),
                          )
                        ),
                        SizedBox(
                          width: 220, 
                          child: SizedBox(
                            height: 45,
                            child: TextFormField(
                              controller: phoneController,
                              autofocus: false,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'Enter phone number',
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
                            padding: const EdgeInsets.only(top:10,bottom: 10),
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
                            padding: const EdgeInsets.only(top:10,bottom: 10),
                            child: Icon(Icons.key),
                          )
                        ),
                        SizedBox(
                          width: 220, 
                          child: SizedBox(
                            height: 45,
                            child: TextFormField(
                              controller: confirmPasswordController,
                              autofocus: false,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Confirm password',
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
                  Text(
                    errorText,
                    style: TextStyle(
                      color:Colors.redAccent,
                      fontSize: 12
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                          onPressed: ()=>{
                            _registerUser()
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
                              "Register",
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
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        "Register",
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

  Future<void> _registerUser() async {
    setState(() {
      onLoadState = true;
    });
    // Prepare the data to send in the POST request
    String roleController;
    if (selectRole=="Agent"){
      roleController="2";
    }else if(selectRole=="Organization"){
      roleController="3";
    }else{
      roleController="1";
    }
    final response = await http.post(
      Uri.parse("https://"+globals.apiUrl+'/api/users/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'role': roleController,
        'full_name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'password': passwordController.text,
        're_password': confirmPasswordController.text,
      })
    );

    if (response.statusCode < 303) {
      print('Registration successful');
      await Future.delayed(Duration(seconds: 1)); // Wait for 2 seconds
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RegSuccess(), // Replace with your success screen
        ),
      );
    }else if(response.statusCode >= 500){
      errorText = "Server Error! 500";
    }
     else {
      print(response.body);
      final Map<String, dynamic> responseData = json.decode(response.body);
      print(response.body);
      setState((){
        errorText = responseData.values.first[0];
      });
    }
    setState(() {
      onLoadState = false;
    });
  }

}

