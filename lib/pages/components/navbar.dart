import 'package:flutter/material.dart';

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
                  "Realestate",
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
            },
          ),
          ListTile(
            leading: Icon(
              Icons.arrow_circle_right_rounded,
              color: Theme.of(context).colorScheme.primary,
              ),
            title: const Text('Property List'),
            onTap: ()=> {
              Navigator.pushNamed(context, "/propertyList")
            },
          ),
          ListTile(
            leading: Icon(
              Icons.arrow_circle_right_rounded,
              color: Theme.of(context).colorScheme.primary,
              ),
            title: const Text('Contact'),
            onTap: ()=> {
            },
          ),
          ListTile(
            leading: Icon(
              Icons.arrow_circle_right_rounded,
              color: Theme.of(context).colorScheme.primary,
              ),
            title: const Text('Agent List'),
            onTap: ()=> {
            },
          ),
          ListTile(
            leading: Icon(
              Icons.arrow_circle_right_rounded,
              color: Theme.of(context).colorScheme.primary,
              ),
            title: const Text('Agent Profile'),
            onTap: ()=> {
            },
          ),
          ListTile(
            leading: Icon(
              Icons.arrow_circle_right_rounded,
              color: Theme.of(context).colorScheme.primary,
              ),
            title: const Text('Organization'),
            onTap: ()=> {
            },
          ),
          ListTile(
            leading: Icon(
              Icons.arrow_circle_right_rounded,
              color: Theme.of(context).colorScheme.primary,
              ),
            title: const Text('Add Listing'),
            onTap: ()=> {
            },
          ),
        ],
      ),
    );
  }
}