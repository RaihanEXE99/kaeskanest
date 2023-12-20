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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import "package:Kaeskanest/global.dart" as globals;

import 'login.dart'; // Import your login screen

class Chat extends StatefulWidget {
  final String chatID;
  const Chat({required this.chatID});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final secureStorage = FlutterSecureStorage();
  late final Future<bool> _checkAccessTokenFuture = _checkAccessTokenOnce();

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _checkAccessTokenOnce() async {
    var token = await secureStorage.read(key: 'access');
    if (token != null) {
      final response = await http.get(
        Uri.parse("https://" + globals.apiUrl + '/api/users/me/'), // Replace with your API URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'JWT $token',
        },
      );
      if (response.statusCode >= 400) {
        await secureStorage.deleteAll();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Login(), // Replace with your login screen
          ),
        );
        return false;
      } else {
        return true;
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Login(), // Replace with your login screen
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text("Inbox"),
      ),
      body: FutureBuilder<bool>(
        key: UniqueKey(),
        future: _checkAccessTokenFuture,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return ErrorWidget(snapshot.error.toString());
          } else {
            return WebViewContainer(id: widget.chatID);
          }
        },
      ),
    );
  }
}

class WebViewContainer extends StatefulWidget {
  final String id;

  WebViewContainer({required this.id});

  @override
  _WebViewContainerState createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  late WebViewController _webViewController;
  late Completer<WebViewController> _controllerCompleter;

  final secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _controllerCompleter = Completer<WebViewController>();
  }

  void setLocalStorageData() async {
    // Wait for the _webViewController to be initialized
    await _controllerCompleter.future;
    var token = await secureStorage.read(key: 'access');
    // Execute JavaScript to set data in local storage
    await _webViewController.evaluateJavascript('''
      localStorage.setItem('access', '${token}');
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://kaeskanest.com/inbox/${widget.id}',
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (controller) {
        _webViewController = controller;
        _controllerCompleter.complete(controller);
      },
      onPageStarted: (String url) {
        print("WebView started loading: $url");
        setLocalStorageData();
        _webViewController.evaluateJavascript('''
          // Example: Remove header and footer by setting their display property to none
          // document.querySelector('header').style.display = 'none';
          document.querySelector('footer').style.display = 'none';
        '''); // Call setLocalStorageData when the page starts loading
      },
      onWebResourceError: (WebResourceError error) {
        print("WebView error: ${error.description}");
      },
      navigationDelegate: (NavigationRequest request) {
        final targetUrl = 'https://kaeskanest.com/inbox/${widget.id}';
        if (request.url == targetUrl) {
          print("GOING");
          return NavigationDecision.navigate;
        } else {
          // Block navigation for all other URLs
          print("INVALID URL");
          return NavigationDecision.prevent;
        }
      },
      onPageFinished: (String url) {
        // setLocalStorageData();
        _webViewController.evaluateJavascript('''
          // Example: Remove footer by setting its display property to none
          document.querySelector('footer').style.display = 'none';
          var elementToRemove = document.querySelector('.sticky.top-0.z-20');
          if (elementToRemove) {
            elementToRemove.parentNode.removeChild(elementToRemove);
          }
        ''');
      },
    );
  }
}
// class WebViewContainer extends StatefulWidget {
//   final String id;

//   WebViewContainer({required this.id});

//   @override
//   _WebViewContainerState createState() => _WebViewContainerState();
// }

// class _WebViewContainerState extends State<WebViewContainer> {
//   late WebViewController _webViewController;
//   final secureStorage = FlutterSecureStorage();

//   @override
//   void initState() {
//     super.initState();
//     setLocalStorageData();
//   }

//   void setLocalStorageData() async {
//     var token = await secureStorage.read(key: 'access');
//     // Execute JavaScript to set data in local storage
//     await _webViewController.evaluateJavascript('''
//       localStorage.setItem('access', ${token});
//     ''');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WebView(
//       initialUrl: 'https://kaeskanest.com/inbox/${widget.id}',
//       javascriptMode: JavascriptMode.unrestricted,
//       onWebViewCreated: (controller) {
//         _webViewController = controller;
//       },
//       onPageStarted: (String url) {
//         print("WebView started loading: $url");
//       },
//       onWebResourceError: (WebResourceError error) {
//         print("WebView error: ${error.description}");
//       },
//       navigationDelegate: (NavigationRequest request) {
//         if (request.url.contains('/inbox/${widget.id}')) {
//           print("GOING");
//           return NavigationDecision.navigate;
//         } else {
//           print("INVALID URL");
//           return NavigationDecision.prevent;
//         }
//       },
//     );
//   }
// }
