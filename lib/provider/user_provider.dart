import 'package:flutter/widgets.dart';
import 'package:skype_clone/models/userData.dart';
import 'package:skype_clone/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  UserData _user;
  AuthMethods _authMethods = AuthMethods();

  UserData get getUser => _user;

  Future<void> refreshUser() async {
    UserData user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }

}
