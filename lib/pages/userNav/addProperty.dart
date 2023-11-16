import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:realestate/actions/action.dart';
import "package:realestate/global.dart" as globals;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:realestate/pages/components/appbar.dart';
import 'package:realestate/pages/components/navbar.dart';
import 'package:realestate/pages/components/userNavbar.dart';
import 'package:realestate/pages/userNav/login.dart';

import 'package:path_provider/path_provider.dart';

class AddProperty extends StatefulWidget {
  @override
  _AddPropertyState createState() => _AddPropertyState();
}

class Place {
  final String name;
  final String vicinity;
  final String placeId;
  final double lat;
  final double long;

  Place({required this.name, required this.vicinity,required this.placeId,required this.lat,required this.long});
}

class _AddPropertyState extends State<AddProperty> {
  final secureStorage = FlutterSecureStorage();
  bool hasToken = false;
  bool onLoadState =false;
  String? token;
  final String apiKey = globals.apiKey;
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }
  late int userId;
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
          userId=responseData['id'];
        });
        print(userId);
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
  late final Future<bool> _checkAccessTokenFuture = _checkAccessTokenOnce();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  
  TextEditingController priceController = TextEditingController();
  TextEditingController currencyType = TextEditingController(text:"\$");
  TextEditingController durationType = TextEditingController(text:"/month");

  String?  selectedCategory="Home";
  String?  selectedPostType="Rent";
  String?  selectedPostStatus="Available";

  List<XFile>? selectedImages;
  XFile? selectedVideo;
  XFile? selectedThumbnail;
  List<XFile>? multipleImages;

  TextEditingController houseController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController zipController = TextEditingController();

  String? selectedSizeUnit="m²";
  TextEditingController propertySizeController = TextEditingController();
  TextEditingController bathroomsController = TextEditingController();
  TextEditingController bedroomsController = TextEditingController();
  TextEditingController customIdController = TextEditingController();
  TextEditingController yearBuiltController = TextEditingController();
  TextEditingController garagesController = TextEditingController();
  TextEditingController garageSizeController = TextEditingController();
  TextEditingController floorController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  TextEditingController errorController = TextEditingController();

  GoogleMapController? mapController;
  LatLng _selectedLocation = LatLng(37.7749, -122.4194);
  Set<Marker> _markers = {};

  FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  void _scrollToTextField(BuildContext context) {
  final RenderBox? renderBox = context.findRenderObject() as RenderBox?;

  // Check if renderBox is not null before proceeding
  if (renderBox != null) {
    final position = renderBox.localToGlobal(Offset.zero);

    // Scroll to the top of the text field with a smooth animation
    Scrollable.ensureVisible(
      context,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.0, // Set alignment to 0.0 to scroll to the top
    );
  }
}
  
  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _addMarker(location);
    });
  }

  void _addMarker(LatLng location) {
    _markers.clear(); // Clear existing markers
    _markers.add(
      Marker(
        markerId: MarkerId("selected_location"),
        position: location,
        infoWindow: InfoWindow(title: 'Selected Location', snippet: 'Lat: ${location.latitude}, Long: ${location.longitude}'),
      ),
    );
  }

  final TextEditingController _locationController = TextEditingController();
  List<Place> _places = [];

  Future<void> autoCompleteSearch(String input) async {
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey',
      ),
    );
    
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final predictions = jsonResponse['predictions'] as List;

      final futures = predictions.map((prediction) async {
        var data = await _getLatlong(prediction['place_id']);
        return Place(
          name: prediction['description'],
          vicinity: prediction['structured_formatting']['main_text'],
          placeId: prediction['place_id'],
          lat: data['lat'],
          long: data['long'],
        );
      }).toList();

      _places = await Future.wait(futures);
      setState(() {
        _places=_places;
      });
    }
  }
  Future _getLatlong(prediction) async{
    final response = await http.get(Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?placeid=$prediction&key=$apiKey'
    ));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return {
        'lat':jsonResponse['result']['geometry']['location']['lat'],
        'long':jsonResponse['result']['geometry']['location']['lng']
      };
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Your Property Details'),
      ),
      body: 
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title*'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),


                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Center(child: Text("Property Price",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Theme.of(context).colorScheme.primary),)),
                ),
                // Price Field
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'Price'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Price is required';
                    }
                    // Add any additional validation as needed
                    return null;
                  },
                ),
                // Currency Type Field
                TextFormField(
                  controller: currencyType,
                  decoration: InputDecoration(labelText: 'Currency Type (ex: \$)'),
                ),
                TextFormField(
                  controller: durationType,
                  decoration: InputDecoration(labelText: 'Price For Duration (ex: "/month")'),
                ),
                


                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Center(child: Text("Select Categories",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Theme.of(context).colorScheme.primary),)),
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  items: ['Home', 'Office','Apartment'].map((String x) {
                    return DropdownMenuItem<String>(
                      value: x,
                      child: Text(x),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Category',
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedPostType,
                  onChanged: (value) {
                    setState(() {
                      selectedPostType = value;
                    });
                  },
                  items: ['Rent', 'Sales'].map((String x) {
                    return DropdownMenuItem<String>(
                      value: x,
                      child: Text(x),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Post Type',
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select post type';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedPostStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedPostStatus = value;
                    });
                  },
                  items: ['Available', 'Upcoming'].map((String x) {
                    return DropdownMenuItem<String>(
                      value: x,
                      child: Text(x),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Post Status',
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select post status';
                    }
                    return null;
                  },
                ),


                // Thumbnail
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      XFile? thumbnail = await ImagePicker().pickImage(source: ImageSource.gallery);
                      setState(() {
                        selectedThumbnail = thumbnail;
                      });
                    },
                    style: ButtonStyle(),
                    icon: Icon(Icons.image),
                    label: Text('Select Thumbnail'),
                  ),
                ),
                // Display selected thumbnail
                if (selectedThumbnail != null)
                  Column(
                    children: [
                      Text('Selected Thumbnail:'),
                      Image.file(File(selectedThumbnail!.path)),
                    ],
                  ),

                // Multiple Images
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      List<XFile>? images = await ImagePicker().pickMultiImage();
                      setState(() {
                        multipleImages = images;
                      });
                    },
                    icon: Icon(Icons.image),
                    label: Text('Add Property Images (Multiple)'),
                  ),
                ),
                // Display selected multiple images
                if (multipleImages != null && multipleImages!.isNotEmpty)
                  Column(
                    children: [
                      Text('Selected Multiple Images:'),
                      for (var image in multipleImages!) Image.file(File(image.path)),
                    ],
                  ),

                // Video
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      XFile? video = await ImagePicker().pickVideo(source: ImageSource.gallery);
                      setState(() {
                        selectedVideo = video;
                      });
                    },
                    icon: Icon(Icons.video_camera_back),
                    label: Text('Add a Video'),
                  ),
                ),
                // Display selected video
                if (selectedVideo != null)
                  Column(
                    children: [
                      Text('Selected Video:'),
                      Text(selectedVideo!.path),
                    ],
                  ),

                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Center(child: Text("Listing Location",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Theme.of(context).colorScheme.primary),)),
                ),



                Container(
                  height: 300,
                  color: Colors.white60,
                  child: GoogleMap(
                    gestureRecognizers: {                 
                      Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())
                    },
                    onMapCreated: _onMapCreated,
                    onTap: _onMapTapped,
                    initialCameraPosition: CameraPosition(
                        target: _selectedLocation, // Initial map position (San Francisco)
                        zoom: 15,
                        tilt: 45,
                      ),
                    markers: _markers,
                  ),
                ),

                ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _places.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_places[index].name),
                          subtitle: Text(_places[index].vicinity),
                          onTap: () {
                            setState(() {
                              _locationController.text = _places[index].name;
                              _selectedLocation = LatLng(_places[index].lat, _places[index].long);
                              _addMarker(_selectedLocation);
                              mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target:_selectedLocation,zoom: 17)));
                            });
                            setState(() {
                              _places=[];
                            });
                          },
                        );
                      },
                    ),


                GestureDetector(
                  onTap: () {
                    _scrollToTextField(context);
                  },
                  child: TextField(
                    controller: _locationController,
                    focusNode: _focusNode,
                    onChanged: (value) async {
                      await autoCompleteSearch(value);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter a location...',
                    ),
                  ),
                ),


                TextFormField(
                  controller: houseController,
                  decoration: InputDecoration(labelText: 'House'),
                ),
                TextFormField(
                  controller: streetController,
                  decoration: InputDecoration(labelText: 'Street Address'),
                ),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextFormField(
                  controller: cityController,
                  decoration: InputDecoration(labelText: 'City'),
                ),
                TextFormField(
                  controller: stateController,
                  decoration: InputDecoration(labelText: 'State'),
                ),
                TextFormField(
                  controller: countryController,
                  decoration: InputDecoration(labelText: 'Country'),
                ),
                TextFormField(
                  controller: zipController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Zip'),
                ),


                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Center(child: Text("Listing Details",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Theme.of(context).colorScheme.primary),)),
                ),
                DropdownButtonFormField<String>(
                  value: selectedSizeUnit,
                  onChanged: (value) {
                    setState(() {
                      selectedSizeUnit = value;
                    });
                  },
                  items: ['m²', 'ft²'].map((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Size Unit',
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a size unit';
                    }
                    return null;
                  },
                ),

                TextFormField(
                  controller: propertySizeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Property Size'),
                ),
                TextFormField(
                  controller: bedroomsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Bedrooms'),
                ),
                TextFormField(
                  controller: bathroomsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Bathrooms'),
                ),
                TextFormField(
                  controller: customIdController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Custom ID'),
                ),
                TextFormField(
                  controller: yearBuiltController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Year Built'),
                ),
                TextFormField(
                  controller: garagesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Garages'),
                ),
                TextFormField(
                  controller: garageSizeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Garage Size'),
                ),
                TextFormField(
                  controller: floorController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Floor No'),
                ),

                TextFormField(
                  controller: dateController,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(labelText: 'Available from'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Date is required';
                    }
                    // Add any additional validation as needed
                    return null;
                  },
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != DateTime.now()) {
                      dateController.text = pickedDate.toLocal().toString().split(' ')[0];
                    }
                  },
                ),
                // Submit button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      handleSubmit(_selectedLocation,_locationController.text);
                    }
                  },
                  child: Text('Submit'),
                ),

                // TextFormField(
                //   controller: errorController,
                //   keyboardType: TextInputType.text,
                //   decoration: InputDecoration(labelText: 'Error'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void handleSubmit(LatLng selectedLocation, String text) async {
    setState(() {
      onLoadState=true;
    });
    try {
      Uri url = Uri.parse("https://" + globals.apiUrl + '/api/add-property/');

      // Create a multipart request
      var request = http.MultipartRequest('POST', url);
      var token = await secureStorage.read(key: 'access');
      print(token);
      request.headers['Authorization'] = 'JWT $token';

      if (selectedThumbnail != null) {
        request.files.add(
          await http.MultipartFile.fromPath('thumbnail', selectedThumbnail!.path),
        );
      }

      // Add video
      if (selectedVideo != null) {
        request.files.add(
          await http.MultipartFile.fromPath('video', selectedVideo!.path),
        );
      }

      // Add images
      if (multipleImages != null && multipleImages!.isNotEmpty) {
        for (var image in multipleImages!) {
          request.files.add(
            await http.MultipartFile.fromPath('images', image.path),
          );
        }
      }
      // Add other form fields
      request.fields['desc'] = descriptionController.text;
      request.fields['lat'] = _selectedLocation.latitude.toString();
      request.fields['loc'] = text;
      request.fields['long'] = _selectedLocation.longitude.toString();
      request.fields['post_type'] = selectedPostType!;
      request.fields['price'] = priceController.text;
      request.fields['price_unit'] = currencyType.text;
      request.fields['price_type'] = durationType.text;
      request.fields['property_category'] = selectedCategory!;
      request.fields['title'] = titleController.text;
      request.fields['property_status'] = selectedPostStatus!;
      request.fields['user'] = userId.toString();

      Map<String, dynamic> address = {
        "house": houseController.text,
        "street": streetController.text,
        "city": cityController.text,
        "state": stateController.text,
        "country": countryController.text,
        "zip": zipController.text,
      };

      // Details JSON
      Map<String, dynamic> details = {
        "cid": customIdController.text,
        "size_unit": selectedSizeUnit!,
        "size": propertySizeController.text,
        "bed": bedroomsController.text,
        "bath": bathroomsController.text,
        "floor": floorController.text,
        "built": yearBuiltController.text,
        "garage": garagesController.text,
        "garage_size": garageSizeController.text,
        "available_from": dateController.text,
      };

      request.fields['address'] = jsonEncode(address);
      request.fields['details'] = jsonEncode(details);
      // Send the request
      var response = await request.send();

      // Check the response
      if (response.statusCode <= 300) {
        print('Form Data Uploaded: ${await response.stream.bytesToString()}');
      } else {
        print('Error: ${response.reasonPhrase}');
        String errorResponse = await response.stream.bytesToString();
        print('Error: $errorResponse');
        setState(() {
          errorController.text = errorResponse;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
    setState(() {
      onLoadState=false;
    });
  }

}
