import 'package:flutter/widgets.dart';
import 'package:chatify/models/userData.dart';
import 'package:chatify/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  UserData? _user;
  AuthMethods _authMethods = AuthMethods();

  UserData get getUser => _user ?? UserData();

  Future<void> refreshUser() async {
    UserData user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }

}
