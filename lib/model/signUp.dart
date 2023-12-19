import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _email = "";
  String _password = "";
  String _univ = "";

  String get email => _email;
  String get password => _password;
  String get univ => _univ;

  set email(String input_email) {
    _email = input_email;
    notifyListeners();
  }

  set password(String input_password) {
    _password = input_password;
    notifyListeners();
    UserProvider up = UserProvider();
  }

  set univ(String input_univ) {
    _univ = input_univ;
    notifyListeners();
  }
}