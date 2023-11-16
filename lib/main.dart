import 'package:flutter/material.dart';
import 'package:realestate/pages/home.dart';
import 'package:realestate/pages/navbar/about.dart';
import 'package:realestate/pages/navbar/contact.dart';
import 'package:realestate/pages/navbar/property.dart';
import 'package:realestate/pages/navbar/propertyList.dart';
import 'package:realestate/pages/userNav/addAgent.dart';
import 'package:realestate/pages/userNav/addProperty.dart';
// import 'package:realestate/pages/userNav/agentSettings.dart';
import 'package:realestate/pages/userNav/invitations.dart';
import 'package:realestate/pages/userNav/login.dart';
import 'package:realestate/pages/userNav/myAgents.dart';
import 'package:realestate/pages/userNav/myProperty.dart';
// import 'package:realestate/pages/userNav/organizationSettings.dart';
import 'package:realestate/pages/userNav/profileSettings.dart';
import 'package:realestate/pages/userNav/register.dart';
import 'package:realestate/pages/userNav/settigns.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xff0E8E94),
          onPrimary: Colors.white,
          secondary: Color(0xff12486B),
          onSecondary: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
          background: Colors.white,
          onBackground: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black
        ),
        fontFamily: "Poppins"
      ),
      initialRoute: "/",
      routes: {
        '/':(context) => HomePage(),
        '/login':(context) => Login(),
        '/register':(context) => Register(),
        '/settings':(context) => Settings(),
        "/propertyList":(context)=> MapScreen(),
        "/profileSettings":(context)=> ProfileSettings(),
        "/addAgent":(context)=> AddAgent(),
        "/myProperty":(context)=> MyProperty(),
        "/myAgents":(context)=> MyAgents(),
        "/addProperty":(context)=> AddProperty(),
        "/invitations":(context)=> Invitations(),
        "/about":(context)=> About(),
        "/contact":(context)=> Contact(),
        "/property":(context)=> PropertyDetails(propertyID: '',),
      },
    );
  }
}

