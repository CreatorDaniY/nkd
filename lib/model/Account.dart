import 'dart:convert';

import 'package:crypto/crypto.dart';

class AccountModel {
  var email;
  var admin_name;
  var password;


  AccountModel({
    required this.email,
    required this.admin_name,
    required this.password,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      email: json["email"],
      admin_name: json["admin_name"],
      password: json["password"],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'email' : email,
      'name' : admin_name,
      'password' : sha256.convert(utf8.encode(password)).toString(),
    };
  }

}


class PostResponse {
  dynamic user_no;
  dynamic user_name;
  dynamic email;
  dynamic session_key;
  dynamic profile;


  PostResponse({required this.user_no, required this.user_name, required this.email, required this.session_key, required this.profile});

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      user_no: json["user_no"],
      user_name: json["user_name"],
      email: json["email"],
      session_key: json["session_key"],
      profile: json['profile']
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return '$email,,$user_name,,$session_key,,$profile';
  }
}

class Account {
  dynamic userNo;
  dynamic email;
  dynamic name;
  dynamic profile;
  dynamic session_key;


  Account({
    required this.userNo,
    required this.email,
    required this.name,
    required this.profile,
    required this.session_key,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      userNo: json["user_no"],
      email: json["email"],
      name: json["name"],
      profile: json["profile"],
      session_key: json["session_key"],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'email' : email,
      'name' : name,
      'profile' : profile,
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return '$email,,$name,,$session_key,,$profile';
  }

}
