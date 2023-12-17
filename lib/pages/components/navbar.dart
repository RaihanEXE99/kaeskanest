import 'package:Kaeskanest/pages/navbar/propertyList.dart';
import 'package:flutter/material.dart';
import 'package:Kaeskanest/pages/navbar/property.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50,bottom: 15),
            child: Center(
              child: Text(
                  "Kaeskanest",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Divider(
              color: Theme.of(context).colorScheme.primary,
              thickness: 6,
              indent: 20,
              endIndent: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25,0,25,10),
            child: ElevatedButton.icon(
              icon: Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 30,
                ),
              label: Padding(
                padding: const EdgeInsets.fromLTRB(0,10,0,10),
                child: const Text('Search Property',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),
              ),
              onPressed: ()=> {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(lat: 0, long: 0, postType: '', propertyCategory: '', pLocation: '', initNeed: false,),
                  ),
                )
              },
            ),
          ),
          Divider(
            indent: 20,
            endIndent: 20,
          ),
          ListTile(
            leading: Icon(
              Icons.arrow_circle_right_rounded,
              color: Theme.of(context).colorScheme.primary,
              ),
            title: const Text('Home'),
            onTap: ()=> {
              Navigator.pushNamed(context, "/")
            },
          ),
          ListTile(
            leading: Icon(
              Icons.arrow_circle_right_rounded,
              color: Theme.of(context).colorScheme.primary,
              ),
            title: const Text('About'),
            onTap: ()=> {
              Navigator.pushNamed(context, "/about")
            },
          ),
          ListTile(
            leading: Icon(
              Icons.arrow_circle_right_rounded,
              color: Theme.of(context).colorScheme.primary,
              ),
            title: const Text('Contact'),
            onTap: ()=> {
              Navigator.pushNamed(context, "/contact")
            },
          ),
          // ListTile(
          //   leading: Icon(
          //     Icons.arrow_circle_right_rounded,
          //     color: Theme.of(context).colorScheme.primary,
          //     ),
          //   title: Text('Test'),
          //   onTap: ()=> {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => PropertyDetails(propertyID: "ff9b3efe-5d57-4cd0-ae56-a49b28443ba6"),
          //       ),
          //     )
          //   },
          // ),
          // ListTile(
          //   leading: Icon(
          //     Icons.arrow_circle_right_rounded,
          //     color: Theme.of(context).colorScheme.primary,
          //     ),
          //   title: const Text('Agent Profile'),
          //   onTap: ()=> {
          //   },
          // ),
          // ListTile(
          //   leading: Icon(
          //     Icons.arrow_circle_right_rounded,
          //     color: Theme.of(context).colorScheme.primary,
          //     ),
          //   title: const Text('Organization'),
          //   onTap: ()=> {
          //   },
          // ),
          // ListTile(
          //   leading: Icon(
          //     Icons.arrow_circle_right_rounded,
          //     color: Theme.of(context).colorScheme.primary,
          //     ),
          //   title: const Text('Add Listing'),
          //   onTap: ()=> {
          //   },
          // ),
        ],
      ),
    );
  }
}