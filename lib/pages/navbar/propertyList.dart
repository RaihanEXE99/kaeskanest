import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}
class Place {
  final String name;
  final String vicinity;

  Place({required this.name, required this.vicinity});
}
class _MapScreenState extends State<MapScreen> {
  
  final TextEditingController _locationController = TextEditingController();
  List<Place> _places = [];

  Future<void> autoCompleteSearch(String input) async {
    final response = await get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=AIzaSyDE1Y0JpqJE6v4vuRpsmpZCoL5ZmTfrHmI',
      ),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      final predictions = jsonResponse['predictions'] as List;

      _places = predictions.map((prediction) {
        return Place(
          name: prediction['description'],
          vicinity: prediction['structured_formatting']['main_text'],
        );
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auto Suggest Location'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _locationController,
            onChanged: (value) async {
              await autoCompleteSearch(value);
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Enter a location...',
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _places.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_places[index].name),
                  subtitle: Text(_places[index].vicinity),
                  onTap: () {
                    setState(() {
                      _locationController.text = _places[index].name;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}