import 'dart:math';
import 'package:flutter/material.dart';
import 'package:Kaeskanest/pages/components/appbar.dart';
import 'package:Kaeskanest/pages/components/navbar.dart';
import 'package:Kaeskanest/pages/components/userNavbar.dart';


class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
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
        child: DefaultAppBar(title:"About Us")
        ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/app/about.jpg'), // Replace with your image path
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: Text(
                "Our Team",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Center(
                child: Text(
                  "Lorem ipsum, dolor sit amet consectetur adipisicing elit. Impedit veritatis reprehenderit expedita dignissimos commodi fugiat id consequatur odit est. Necessitatibus pariatur delectus voluptatum aspernatur placeat eum ex recusandae, doloribus sapiente, dolorem, nemo assumenda. Magnam, libero sit asperiores assumenda quidem sapiente?Lorem ipsum dolor, sit amet consectetur adipisicing elit. Aut perspiciatis sapiente et placeat! Accusantium, cum quam numquam dolor nulla reiciendis et, atque odit dolorem vel eligendi. Natus modi magnam aperiam.",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            Divider(
              thickness: 5,
              indent: 12,
              endIndent: 12,
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top:25,right: 25),
                child: Text(
                  "Our Gallery",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline, 
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Center(
                child: Text(
                  "A visual feast for toy enthusiasts and collectors alike! Step into a world of wonder as we showcase a stunning array of action figures, playsets, and vehicles that will ignite your imagination.",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              primary: false,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              padding: const EdgeInsets.all(20),
              children: List<Widget>.generate(16, (index){
                return GridTile(
                  child: Card(
                    color: Color((Random().nextDouble()*0xFFFFFF).toInt()<<0).withOpacity(1.0),
                  ),
                );
              })
            )
          ],
        ),
      )
    );
  }
}