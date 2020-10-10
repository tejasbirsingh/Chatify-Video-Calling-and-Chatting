import 'package:flutter/material.dart';

final darkTheme = ThemeData(
    backgroundColor: Colors.black87,
    dialogBackgroundColor: Colors.grey,
    cardColor: Colors.grey.withOpacity(0.8),
    splashColor: Colors.white,
    dividerColor: Colors.grey,
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    textTheme: TextTheme(
      headline1: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
      bodyText1: TextStyle(color: Colors.white, fontSize: 18.0),
      bodyText2: TextStyle(color: Colors.white, fontSize: 14.0),
    ),
    appBarTheme: AppBarTheme(
        centerTitle: true,
        color: Colors.black87,
        elevation: 10.0,
        iconTheme: IconThemeData(color: Colors.white),
        textTheme: TextTheme(
          headline1: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
        )));

final lightTheme = ThemeData(
    splashColor: Colors.black,
    backgroundColor: Colors.white,
    dialogBackgroundColor: Colors.grey.shade800,
    cardColor: Colors.grey.shade200,
    dividerColor: Colors.grey,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    textTheme: TextTheme(
      headline1: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
      bodyText1: TextStyle(color: Colors.black, fontSize: 18.0),
      bodyText2: TextStyle(color: Colors.white, fontSize: 14.0),
    ),
    appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        color: Colors.white,
        elevation: 10.0,
        textTheme: TextTheme(
          headline1: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
        )));
