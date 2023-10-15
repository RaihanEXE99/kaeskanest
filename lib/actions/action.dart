import 'dart:convert';

import "package:realestate/global.dart" as globals;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart'as http;

Future <bool> CHECKVALIDUSER() async{
  final secureStorage = FlutterSecureStorage();
  var token = await secureStorage.read(key: 'access');
  if (token != null) {
    final response = await http.post(
      Uri.parse("https://" + globals.apiUrl + '/api/jwt/verify/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token':token
      })
    );
    if (response.statusCode>=400){
      await secureStorage.deleteAll();
      return false;
    }else{
      return true;
    }
  }else{
    return false;
  }
}