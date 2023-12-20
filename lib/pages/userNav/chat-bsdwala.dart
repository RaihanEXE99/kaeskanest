import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import "package:Kaeskanest/global.dart" as globals;

class Chat extends StatefulWidget {
  final String chatID;
  const Chat({required this.chatID});
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late String id;
  late List<dynamic> messages;
  late String mi;
  late bool isSending;
  late Timer interval;

  final secureStorage = FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
    id = widget.chatID;
    // print(id);
    messages = [];
    mi = "";
    isSending = false;

    fetchData(); // Call the function when the component mounts
    interval = Timer.periodic(Duration(seconds: 5), (Timer t) {
      fetchData(); // Fetch data every 2 seconds
    });
  }

  @override
  void dispose() {
    // Clear the interval when the component unmounts
    interval.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    print("FETCHING DATA");
    try {
      var token = await secureStorage.read(key: 'access');
      final response = await http.get(
        Uri.parse("https://" + globals.apiUrl +"/api/inbox/$id"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT ${token}',
        },
      );

      final newMessages = json.decode(response.body)['messages'];
      print(newMessages);

      final newMessagesToAdd = newMessages;
      // final newMessagesToAdd = newMessages.where((newMessage) =>
      //     !messages.any((message) => message['id'] == newMessage['id']));

      if (newMessagesToAdd.isNotEmpty) {
        setState(() {
          messages = newMessagesToAdd;
        });
        print("Added new messages: $newMessagesToAdd");
      } else {
        print("No new messages to add.");
      }
    } catch (error) {
      print("ERROR FOUND");
      print(error);
    }
  }

  void handleValue(String value) {
    setState(() {
      mi = value;
    });
  }

  Future<void> sendMessage() async {
    try {
      setState(() {
        isSending = true;
      });
      var token = await secureStorage.read(key: 'access');
      final response = await http.post(
        Uri.parse("https://" + globals.apiUrl +"/api/inbox/$id/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'JWT ${token}',
        },
        body: {
          "message": mi,
        },
      );
      fetchData();
      print("SENT..........");
      // Handle the response as needed
    } catch (error) {
      // print(error);
    } finally {
      setState(() {
        isSending = false;
        mi = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Your design
              for (var i = 0; i < messages.length; i++)
                Container(
                  child: Column(
                    children: [
                      Text(messages[i]['sender']),
                      Container(
                        color: i % 2 == 0 ? Colors.blue : Colors.green,
                        child: Text(messages[i]['message']),
                      ),
                      // Other UI elements
                    ],
                  ),
                ),
              // Other UI elements
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) => handleValue(value),
                      decoration: InputDecoration(
                        hintText: "Message",
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed:() => sendMessage(),
                    child: isSending
                        ? CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text("Send"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
