import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';


final darkTheme = ThemeData(

    // backgroundColor: Colors.black87,

    backgroundColor: HexColor('#000000'),
    scaffoldBackgroundColor: HexColor('#000000'),
    dialogBackgroundColor: Colors.grey,
    canvasColor: Colors.black.withOpacity(0.4),
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
    canvasColor: Colors.white,
    // backgroundColor: Colors.grey.shade100,
    backgroundColor: HexColor("#F5E3E6"),
    scaffoldBackgroundColor: HexColor("#D9E4F5"),
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
