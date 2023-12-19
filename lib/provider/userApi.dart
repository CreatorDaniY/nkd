import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../model/Account.dart';
import '../model/error.dart';

const baseUrl = 'http://43.201.33.217:8080';
// const baseUrl = 'http://127.0.0.1:8080';
final headers = {
  "Content-Type" : "application/json",
  "Accept" : "application/json",
};

class ApiClient {
  final http.Client httpClient;

  ApiClient({required this.httpClient});

  getUser(String email) async {
    var response = await httpClient.get(Uri.parse(baseUrl + '/joinus'));
    if (response.statusCode == 200){
      Iterable jsonResponse = json.decode(response.body);

    }
  }

  static Future<dynamic> postUser(AccountModel user) async{
    print('this is url : $baseUrl');
    var response = await http.post(Uri.parse(baseUrl + '/joinus'),
      body: json.encode(user.toJson()),
    );
    return response;
  }


  static Future<dynamic> sendEmailVerification(String email) async{
    var response = await http.post(Uri.parse(baseUrl + "/request/email-validation"),
      body: {
        'email' : email
      },
    );
    var statusCode = response.statusCode;
    var headers = response.headers;
    var body = json.decode(utf8.decode(response.bodyBytes));

    if(statusCode != 200){
      ErrorMessage error = ErrorMessage.fromJson(body);
      return error;
    }else{
      PostResponse postResponse = PostResponse.fromJson(body);
      return postResponse;
    }
  }

  static Future<Account?> checkSession(BuildContext context, String sessionKey) async{
    FlutterSecureStorage storage = FlutterSecureStorage();
    var headers = {
      "Content-Type" : "application/json",
      "Accept" : "application/json",
      "norKor_token" : sessionKey,
    };
    var response = await http.get(Uri.parse(baseUrl + '/hello-world'), headers: headers);
    if(response.statusCode == HttpStatus.unauthorized){
      await storage.delete(key: 'session');
      Navigator.pop(context);
      return null;
    }
    else{
      var body = json.decode(utf8.decode(response.bodyBytes));
      Account account = Account.fromJson(body);
      await storage.write(key: 'session', value: account.toString());
      return account;
    }
  }
}