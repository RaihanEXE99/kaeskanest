// import 'dart:convert';
// import 'package:Kaeskanest/actions/action.dart';
// import "package:Kaeskanest/global.dart" as globals;
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:Kaeskanest/pages/components/appbar.dart';
// import 'package:Kaeskanest/pages/components/navbar.dart';
// import 'package:Kaeskanest/pages/components/userNavbar.dart';
// import 'package:Kaeskanest/pages/userNav/login.dart';
// import 'package:Kaeskanest/pages/navbar/property.dart'; 

// import 'package:http/http.dart'as http;

// class Chat extends StatefulWidget {
//   final String chatID;
//   const Chat({required this.chatID});

//   @override
//   State<Chat> createState() => _ChatState();
// }

// class _ChatState extends State<Chat> {
//   final secureStorage = FlutterSecureStorage();
//   bool onLoadState=false;
//   late final Future<bool> _checkAccessTokenFuture = _checkAccessTokenOnce();

//   var conversations = [];

//   late int userId;
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
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) => Login(), // Replace with your login screen
//           ),
//         );
//         return false;
//       }
//       else{
//         // print(json.decode(response.body));
//         // String myID = json.decode(response.body)['id'].toString();
//         Future<http.Response> fetchMyCoversations(String token) async {
//           final url = Uri.parse("https://" + globals.apiUrl + '/api/inbox/${widget.chatID.toString()}');
//           final headers = {
//             'Content-Type': 'application/json; charset=UTF-8',
//             'Authorization': 'JWT $token',
//           };

//           final response = await http.get(url, headers: headers);
//           return response;
//         }
//         final gresponse = await fetchMyCoversations(token);
//         if (response.statusCode>=400){
//           await secureStorage.deleteAll();
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder: (context) => Login(), // Replace with your login screen
//             ),
//           );
//           return false;
//         }
//         else{
//           final Map<String, dynamic> gresponseData = json.decode(gresponse.body);
//           print(gresponseData);
//           setState(() {
//             conversations=gresponseData['messages'];
//           });
//           // print(gresponseData);
//           return true;
//         }
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
//   void dispose() {
//     super.dispose();
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const Navbar(),
//       endDrawer: const UserNavBar(),
//       appBar: const PreferredSize(
//         preferredSize: Size.fromHeight(kToolbarHeight),
//         child: DefaultAppBar(title:"Conversations")
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
//             return conversations.isNotEmpty?SingleChildScrollView(
//               child: Column(
//                 children: [  
//                   ListView.builder(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: conversations.length,
//                     itemBuilder: (context, index) {
//                       return GestureDetector(
//                         onTap: ()=>{
//                           // print(conversations[index]['id'])
//                         },
//                         child: Card(
//                             child: Row(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Icon(Icons.chat_sharp,size: 60,),
//                                 ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(conversations[index]['sender'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
//                                     Text(conversations[index]['message']),
//                                   ],
//                                 )
//                               ],
//                             )
//                           ),
//                       );
//                     },
//                   )
//                 ],
//               ),
//             ):Center(child:Text("No Conversations yet!"));
//           }
//          },
        
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:Kaeskanest/actions/action.dart';
import "package:Kaeskanest/global.dart" as globals;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Kaeskanest/pages/components/appbar.dart';
import 'package:Kaeskanest/pages/components/navbar.dart';
import 'package:Kaeskanest/pages/components/userNavbar.dart';
import 'package:Kaeskanest/pages/userNav/login.dart';
import 'package:Kaeskanest/pages/navbar/property.dart'; 

import 'package:http/http.dart'as http;

import 'dart:async';

class Chat extends StatefulWidget {
  final String chatID;
  const Chat({required this.chatID});
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  // final String yourName = "Your Name"; // Replace with the user's name
  // final List<Message> _messages = [
  //   Message(sender: 'John', text: 'Hello!'),
  //   Message(sender: 'You', text: 'Hi there!'),
  //   // Add more messages as needed
  // ];

  final TextEditingController _textEditingController = TextEditingController();

  final secureStorage = FlutterSecureStorage();
  bool onLoadState=false;
  late final Future<bool> _checkAccessTokenFuture = _checkAccessTokenOnce();

  var _messages = [];
  int myID=-1;

  late int userId;
  @override
  void initState() {
    super.initState();
    // Timer.periodic(Duration(seconds: 5), (Timer t) => _loadMessages());
  }

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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Login(), // Replace with your login screen
          ),
        );
        return false;
      }
      else{
        // print(json.decode(response.body));
        myID = json.decode(response.body)['id'];
        Future<http.Response> fetchMyCoversations(String token) async {
          final url = Uri.parse("https://" + globals.apiUrl + '/api/inbox/${widget.chatID.toString()}');
          final headers = {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'JWT $token',
          };

          final response = await http.get(url, headers: headers);
          return response;
        }
        final gresponse = await fetchMyCoversations(token);
        if (response.statusCode>=400){
          await secureStorage.deleteAll();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Login(), // Replace with your login screen
            ),
          );
          return false;
        }
        else{
          final Map<String, dynamic> gresponseData = json.decode(gresponse.body);
          print(gresponseData);
          setState(() {
            _messages=gresponseData['messages'];
          });
          // print(gresponseData);
          return true;
        }
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

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("yourName"),
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
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    // reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(
                        message: _messages[index],
                        isMe: _messages[index]['sender_id'] == myID,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textEditingController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          _sendMessage();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        }
      )
    );
  }

  void _sendMessage() {
    String text = _textEditingController.text;
    if (text.isNotEmpty) {
      setState(() {
        // _messages.add(Message(sender: 'You', text: text));
        _textEditingController.clear();
      });
    }
  }
}

// class Message {
//   final String sender;
//   final String text;

//   Message({required this.sender, required this.text});
// }

class MessageBubble extends StatelessWidget {
  final message;
  final bool isMe;

  MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            isMe ? "You" : message['sender'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              message['message'],
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}