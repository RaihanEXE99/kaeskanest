import 'package:flutter/material.dart';
import 'package:realestate/pages/components/navbar.dart';
import 'package:realestate/pages/components/userNavbar.dart';

class RegSuccess extends StatelessWidget {
  const RegSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100.0,
            ),
            SizedBox(height: 16.0),
            Center(
              child: Text(
                'Registration Successful!',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                'Please Check your email to activate your account!',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Navigate back to the previous screen or perform other actions
                Navigator.pop(context);
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      )
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        "Back",
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
}