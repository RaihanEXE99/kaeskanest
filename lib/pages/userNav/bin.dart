// import 'dart:convert';
// import 'package:realestate/actions/action.dart';
// import "package:realestate/global.dart" as globals;
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:realestate/pages/components/appbar.dart';
// import 'package:realestate/pages/components/navbar.dart';
// import 'package:realestate/pages/components/userNavbar.dart';
// import 'package:realestate/pages/userNav/login.dart';

// import 'package:http/http.dart'as http;

// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:image_picker/image_picker.dart';

// class AddProperty extends StatefulWidget {
//   const AddProperty({super.key});

//   @override
//   State<AddProperty> createState() => _AddPropertyState();
// }

// class _AddPropertyState extends State<AddProperty> {
//   final secureStorage = FlutterSecureStorage();
//   bool hasToken = false;
//   bool onLoadState =false;
//   late final Future<bool> _checkAccessTokenFuture = _checkAccessTokenOnce();

//   late int userId;

//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   TextEditingController titleController = TextEditingController();
//   TextEditingController descriptionController = TextEditingController();

//   List<XFile> selectedImages = [];
//   XFile? selectedVideo;

//   @override
//   void initState() {
//     super.initState();
//   }
//   Future<bool> _checkAccessTokenOnce() async {
//     var token = await secureStorage.read(key: 'access');
//     if (token != null) {
//       final response = await http.get(
//         Uri.parse("https://" + globals.apiUrl + '/api/users/me/'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//           'Authorization': 'JWT $token',
//         },
//       );
//       if (response.statusCode>=400){
//         await secureStorage.deleteAll();
//         setState(() {
//           token=null;
//         });
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) => Login(), // Replace with your login screen
//           ),
//         );
//         return false;
//       }
//       else{
//         print(response.body);
//         return true;
//       }
//     } else {
//       // Access token doesn't exist, navigate to the login or onboarding screen
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder: (context) => Login(), // Replace with your login screen
//         ),
//       );
//       return false;
//     }
//   }

  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const Navbar(),
//       endDrawer: const UserNavBar(),
//       appBar: const PreferredSize(
//         preferredSize: Size.fromHeight(kToolbarHeight),
//         child: DefaultAppBar(title:"Add Property")
//         ),
//       body: FutureBuilder<bool>(
//         key:  UniqueKey() ,
//         future: _checkAccessTokenFuture,
//         builder: (BuildContext context, AsyncSnapshot<bool> snapshot) { 
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             // Handle error
//             return ErrorWidget(snapshot.error.toString());
//           } else {
//             return onLoadState?Center(child: CircularProgressIndicator()):
//             SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         controller: titleController,
//                         decoration: InputDecoration(labelText: 'Title*'),
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return 'Title is required';
//                           }
//                           return null;
//                         },
//                       ),
//                       TextFormField(
//                         controller: descriptionController,
//                         decoration: InputDecoration(labelText: 'Description'),
//                         maxLines: 3,
//                       ),

//                       // Other form fields go here...

//                       // Thumbnail
//                       ElevatedButton(
//                         onPressed: () async {
//                           XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
//                           setState(() {
//                             selectedImages = [image];
//                           });
//                         },
//                         child: Text('Select Thumbnail'),
//                       ),
//                       // Display selected thumbnail
//                       if (selectedImages.isNotEmpty)
//                         Column(
//                           children: [
//                             Text('Selected Thumbnail:'),
//                             Image.file(File(selectedImages.first.path)),
//                           ],
//                         ),

//                       // Multiple Images
//                       ElevatedButton(
//                         onPressed: () async {
//                           List<XFile> images = await ImagePicker().pickMultiImage();
//                           setState(() {
//                             selectedImages = images;
//                           });
//                         },
//                         child: Text('Select Images'),
//                       ),
//                       // Display selected images
//                       if (selectedImages.isNotEmpty)
//                         Column(
//                           children: [
//                             Text('Selected Images:'),
//                             for (var image in selectedImages) Image.file(File(image.path)),
//                           ],
//                         ),

//                       // Video
//                       ElevatedButton(
//                         onPressed: () async {
//                           XFile? video = await ImagePicker().pickVideo(source: ImageSource.gallery);
//                           setState(() {
//                             selectedVideo = video!;
//                           });
//                         },
//                         child: Text('Select Video'),
//                       ),
//                       // Display selected video
//                       if (selectedVideo != null)
//                         Column(
//                           children: [
//                             Text('Selected Video:'),
//                             Text(selectedVideo!.path),
//                           ],
//                         ),

//                       // Submit button
//                       ElevatedButton(
//                         onPressed: () {
//                           if (_formKey.currentState!.validate()) {
//                             handleSubmit();
//                           }
//                         },
//                         child: Text('Submit'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }
//          },
//       ),
//     );
//   }

//   void handleSubmit() async {
//     try {
//       Uri url = Uri.parse('Your backend API endpoint');

//       var request = http.MultipartRequest('POST', url);
//       request.fields['title'] = titleController.text;
//       request.fields['description'] = descriptionController.text;

//       // Add other form fields...

//       if (selectedImages.isNotEmpty) {
//         request.files.add(await http.MultipartFile.fromPath('thumbnail', selectedImages.first.path));
//       }

//       for (var image in selectedImages) {
//         request.files.add(await http.MultipartFile.fromPath('images', image.path));
//       }

//       if (selectedVideo != null) {
//         request.files.add(await http.MultipartFile.fromPath('video', selectedVideo!.path));
//       }

//       var response = await request.send();
//       print(await response.stream.bytesToString());
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

// }
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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

  Place({required this.name, required this.vicinity});
}

class _AddPropertyState extends State<AddProperty> {
  final secureStorage = FlutterSecureStorage();
  bool hasToken = false;
  bool onLoadState =false;
  String? token;
  @override
  void initState() {
    super.initState();
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

  final TextEditingController _locationController = TextEditingController();
  List<Place> _places = [];

  Future<void> autoCompleteSearch(String input) async {
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=AIzaSyDE1Y0JpqJE6v4vuRpsmpZCoL5ZmTfrHmI',
      ),
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
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
        title: Text('Add Your Property Details'),
      ),
      body: FutureBuilder<bool>(
        key:  UniqueKey() ,
        future: _checkAccessTokenFuture,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) { 
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle error
            return ErrorWidget(snapshot.error.toString());
          } else {
            return 
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
                                    });
                                  },
                                );
                              },
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
                              handleSubmit();
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
              );
            
          }
        }
      )
    );
  }

  // void handleSubmit() async {
  //   try {
  //     Uri url = Uri.parse('Your backend API endpoint');

  //     // Send Thumbnail
  //     if (selectedThumbnail != null) {
  //       var thumbnailRequest = http.MultipartRequest('POST', url);
  //       thumbnailRequest.fields['title'] = titleController.text;
  //       thumbnailRequest.files.add(await http.MultipartFile.fromPath('thumbnail', selectedThumbnail!.path));

  //       var thumbnailResponse = await thumbnailRequest.send();
  //       print('Thumbnail Uploaded: ${await thumbnailResponse.stream.bytesToString()}');
  //     }

  //     // Send Multiple Images
  //     if (multipleImages != null && multipleImages!.isNotEmpty) {
  //       for (var image in multipleImages!) {
  //         var imageRequest = http.MultipartRequest('POST', url);
  //         imageRequest.fields['title'] = titleController.text;
  //         imageRequest.files.add(await http.MultipartFile.fromPath('multipleImages', image.path));

  //         var imageResponse = await imageRequest.send();
  //         print('Image Uploaded: ${await imageResponse.stream.bytesToString()}');
  //       }
  //     }

  //     if (selectedVideo != null) {
  //       var videoRequest = http.MultipartRequest('POST', url);
  //       videoRequest.fields['title'] = titleController.text;
  //       videoRequest.files.add(await http.MultipartFile.fromPath('video', selectedVideo!.path));

  //       var videoResponse = await videoRequest.send();
  //       print('Video Uploaded: ${await videoResponse.stream.bytesToString()}');
  //     }

  //     // Send other form fields...

  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }
  void handleSubmit() async {
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
      // Add Thumbnail
      // if (selectedThumbnail != null) {
      //   request.fields['title'] = titleController.text;
      //   request.files.add(await http.MultipartFile.fromPath('thumbnail', selectedThumbnail!.path));
      // }

      // // Add Multiple Images
      // if (multipleImages != null && multipleImages!.isNotEmpty) {
      //   for (var image in multipleImages!) {
      //     request.fields['title'] = titleController.text;
      //     request.files.add(await http.MultipartFile.fromPath('images', image.path));
      //   }
      // }

      // // Add Video
      // if (selectedVideo != null) {
      //   request.fields['title'] = titleController.text;
      //   request.files.add(await http.MultipartFile.fromPath('video', selectedVideo!.path));
      // }





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
      request.fields['lat'] = '23.7532533';
      request.fields['loc'] = 'DMD FAKE LOC';
      request.fields['long'] = '90.3754901';
      request.fields['post_type'] = selectedPostType!;
      request.fields['price'] = priceController.text;
      request.fields['price_unit'] = currencyType.text;
      request.fields['price_type'] = durationType.text;
      request.fields['property_category'] = selectedCategory!;
      request.fields['title'] = titleController.text;
      request.fields['property_status'] = selectedPostStatus!;
      request.fields['user'] = userId.toString();

      // request.fields['address[house]'] = houseController.text;
      // request.fields['address[street]'] = streetController.text;
      // request.fields['address[city]'] = cityController.text;
      // request.fields['address[state]'] = stateController.text;
      // request.fields['address[country]'] = countryController.text;
      // request.fields['address[zip]'] = zipController.text;

      // request.fields['details[cid]'] = customIdController.text;
      // request.fields['details[size_unit]'] = selectedSizeUnit!;
      // request.fields['details[size]'] = propertySizeController.text;
      // request.fields['details[bed]'] = bedroomsController.text;
      // request.fields['details[bath]'] = bathroomsController.text;
      // request.fields['details[floor]'] = floorController.text;
      // request.fields['details[built]'] = yearBuiltController.text;
      // request.fields['details[garage]'] = garagesController.text;
      // request.fields['details[garage_size]'] = garageSizeController.text;
      // request.fields['details[available_from]'] = dateController.text;

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
