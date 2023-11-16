import 'dart:convert';
import 'package:realestate/actions/action.dart';
import "package:realestate/global.dart" as globals;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:realestate/pages/components/appbar.dart';
import 'package:realestate/pages/components/navbar.dart';
import 'package:realestate/pages/components/userNavbar.dart';
import 'package:realestate/pages/userNav/login.dart';

import 'package:http/http.dart'as http;

class MyAgents extends StatefulWidget {
  const MyAgents({super.key});

  @override
  State<MyAgents> createState() => _MyAgentsState();
}

class _MyAgentsState extends State<MyAgents> {
  final secureStorage = FlutterSecureStorage();
  bool hasToken = false;
  bool onLoadState =false;
  late final Future<bool> _checkAccessTokenFuture = _checkAccessTokenOnce();
  List<dynamic> myAgents = [];

  late int userId;
  @override
  void initState() {
    super.initState();
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
        Future<http.Response> fetchAllMyAgents(String token) async {
          final url = Uri.parse("https://" + globals.apiUrl + '/api/myAgents/');
          final headers = {
            'Content-Type': 'application/json',
            'Authorization': 'JWT $token',
          };

          final response = await http.get(url, headers: headers);
          return response;
        }
        final gresponse = await fetchAllMyAgents(token);
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
          final List<dynamic> gresponseData = json.decode(gresponse.body);
          setState(() {
            myAgents =gresponseData;
          });
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
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Navbar(),
      endDrawer: const UserNavBar(),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: DefaultAppBar(title:"My Agents")
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
            return onLoadState?Center(child: CircularProgressIndicator()):myAgents.isNotEmpty?ListView.builder(
              itemCount: myAgents.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.account_circle,color: Colors.black54,size: 120,),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: Text(myAgents[index]['name'],style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700,color: Colors.black87),)),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Email: "+(myAgents[index]['email']==""?"Not Available":myAgents[index]['email']),style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400,color: Colors.black54),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Website: "+(myAgents[index]['website']==""?"Not Available":myAgents[index]['website']),style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400,color: Colors.black54),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Number: "+(myAgents[index]['number']==""?"Not Available":myAgents[index]['number']),style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400,color: Colors.black54),),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(onPressed: ()=>{
                                  _showBottomDrawer(context,(myAgents[index]['twitter']==""?"Not Available":myAgents[index]['twitter']))
                                }, icon: Icon(Icons.link,color: Colors.black54,),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                                  label: Text("Twitter",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),)
                                ),
                          ElevatedButton.icon(onPressed: ()=>{
                            _showBottomDrawer(context,(myAgents[index]['facebook_link']==""?"Not Available":myAgents[index]['facebook_link']))
                          }, icon: Icon(Icons.link,color: Colors.black54,),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                            label: Text("Facebook",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),)
                          ),
                          ElevatedButton.icon(onPressed: ()=>{
                            _showBottomDrawer(context,(myAgents[index]['linkedin_link']==""?"Not Available":myAgents[index]['linkedin_link']))
                          }, icon: Icon(Icons.link,color: Colors.black54,),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                            label: Text("Linkedin",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),)
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(onPressed: ()=>{
                            _showBottomDrawer(context,(myAgents[index]['pinterest']==""?"Not Available":myAgents[index]['pinterest']))
                          }, icon: Icon(Icons.link,color: Colors.black54,),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                            label: Text("Pinterest",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),)
                          ),
                          ElevatedButton.icon(onPressed: ()=>{
                            _showBottomDrawer(context,(myAgents[index]['skype_link']==""?"Not Available":myAgents[index]['skype_link']))
                          }, icon: Icon(Icons.link,color: Colors.black54,),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                            label: Text("Skype",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),)
                          ),
                          ElevatedButton.icon(onPressed: ()=>{
                            _showBottomDrawer(context,(myAgents[index]['website']==""?"Not Available":myAgents[index]['website']))
                          }, icon: Icon(Icons.link,color: Colors.black54,),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                            label: Text("Website",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),)
                          ),
                        ],
                      ),
                      SizedBox(height: 15,),
                      ElevatedButton.icon(onPressed: ()=>{
                        _removeAgentDrawer(context,myAgents[index]['id'].toString())
                        }, icon: Icon(Icons.no_accounts,color: Colors.white,),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent)),
                        label: Text("Remove Agent",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.white),)
                      ),
                      SizedBox(height: 15,),
                    ],
                  )
                );
              },
            ):Center(child: Text("You have no agent in your organization!",style: TextStyle(fontSize: 14),));
          }
         },
      ),
    );
  }
  void _removeAgentReq(String eID) async {
    var token = await secureStorage.read(key: 'access');
    final url = Uri.parse("https://" + globals.apiUrl + '/api/removeAgent/${eID}/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'JWT $token',
    };
    final response = await http.post(url, headers: headers);
    print(response.body);
    setState(() {
      onLoadState=false;
    });
    Navigator.pushNamed(context, "/myAgents");
  }
  void _showBottomDrawer(BuildContext context, String s) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                s,
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
  void _removeAgentDrawer(BuildContext context,String eid) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Remove this Agent?",
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent)),
                  onPressed: () {
                    _removeAgentReq(eid);
                  },
                  child: Text('Yes'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('No'),
                ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}