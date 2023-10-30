import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:realestate/pages/components/appbar.dart';
import 'package:realestate/pages/components/navbar.dart';
import 'package:realestate/pages/components/userNavbar.dart';


class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Navbar(),
      endDrawer: const UserNavBar(),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: DefaultAppBar(title:"Contact")
        ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Text(
                "Get In Touch",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary
                ),
              ),
            ),
            Divider(
              thickness: 5,
              indent: 30,
              endIndent: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                contactCard(title:"New York, City",subtitle:"Dhanmondi, Dhaka",icon:const Icon(Icons.map,size: 20,)),
                contactCard(title:"Email",subtitle:"Neuroxie@gmail.com",icon:const Icon(Icons.email,size: 20,)),
              ],
            ),
            SizedBox(height: 10,),
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20,bottom: 20,left: 60,right: 60),
                  child: Column(
                    children: [
                      OutlinedButton(
                        onPressed: ()=>{},
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1000),
                            side: BorderSide(color: Colors.black54),
                          )),
                        ),
                        child: Icon(Icons.phone)
                      ),
                      Text(
                        "Phone",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:FontWeight.w500,
                        ),
                      ),
                      Text(
                        "+8802 7114499",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: SizedBox(
                height: 300,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(37.422131,-122.084801),
                    zoom: 15,
                  )
                ),
              ),
            )
          ]
        ),
      )
    );
  }
}

Card contactCard ({required String title, required Icon icon, required String subtitle}){
  return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 20,bottom: 20,left: 20,right: 20),
        child: Column(
          children: [
            OutlinedButton(
              onPressed: ()=>{},
              style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(1000),
                  side: BorderSide(color: Colors.black54),
                )),
              ),
              child: icon
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight:FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                fontWeight:FontWeight.w400,
              ),
            )
      
          ],
        ),
      ),
    );
}