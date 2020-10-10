import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skype_clone/resources/auth_methods.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skype_clone/utils/universal_variables.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final String token;

  const LoginScreen({Key key, this.token}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final AuthMethods _authMethods = AuthMethods();

  bool isLoginPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: UniversalVariables.blackColor,
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: [
          Center(
            child: loginButton(),
          ),
          isLoginPressed
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container()
        ],
      ),
    );
  }

  Widget loginButton() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: UniversalVariables.senderColor,
      child: FlatButton(
        padding: EdgeInsets.all(35),
        child: Text(
          "LOGIN",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyText1.color,
              fontSize: 35, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        onPressed: () => performLogin(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void performLogin() async {
  
    setState(() {
      isLoginPressed = true;
    });

    UserCredential user = await _authMethods.signIn();

    if (user != null) {
      authenticateUser(user,widget.token);
    }
    setState(() {
      isLoginPressed = false;
    });
  }
  setAppLocker() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLocked', false);
    
  }

  void authenticateUser(UserCredential user,String token) {
    _authMethods.authenticateUser(user).then((isNewUser) {
      setState(() {
        isLoginPressed = false;
      });

      if (isNewUser) {
        setAppLocker();
        _authMethods.addDataToDb(user.user,token).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return HomeScreen();
          }));
        });
      } else {
          setAppLocker();
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }));
      }
    });
  }
}
