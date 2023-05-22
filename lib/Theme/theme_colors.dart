import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

final darkTheme = ThemeData(
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
    displayLarge: TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
    bodyLarge: TextStyle(color: Colors.white, fontSize: 18.0),
    bodyMedium: TextStyle(color: Colors.white, fontSize: 16.0),
  ),
  appBarTheme: AppBarTheme(
      centerTitle: true,
      color: Colors.black87,
      elevation: 10.0,
      iconTheme: IconThemeData(color: Colors.white),
      toolbarTextStyle: TextTheme(
        displayLarge: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
      ).bodyMedium,
      titleTextStyle: TextTheme(
        displayLarge: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
      ).titleLarge),
  // colorScheme: ColorScheme(
  //     background: HexColor('#000000'),
  //     onPrimary: Colors.white,
  //     brightness: Brightness.dark,
  //     primary:Colors.black,
  //     error: Colors.black)
);

final lightTheme = ThemeData(
  splashColor: Colors.black,
  canvasColor: Colors.white,
  scaffoldBackgroundColor: HexColor("#D9E4F5"),
  dialogBackgroundColor: Colors.grey.shade800,
  cardColor: Colors.grey.shade200,
  dividerColor: Colors.grey,
  iconTheme: IconThemeData(
    color: Colors.black,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
        color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
    bodyLarge: TextStyle(color: Colors.black, fontSize: 18.0),
    bodyMedium: TextStyle(color: Colors.black, fontSize: 14.0),
  ),
  appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(color: Colors.white),
      centerTitle: true,
      color: Colors.white,
      elevation: 10.0,
      toolbarTextStyle: TextTheme(
        displayLarge: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
      ).bodyMedium,
      titleTextStyle: TextTheme(
        displayLarge: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
      ).titleLarge),
  // colorScheme: ColorScheme(background: HexColor("#F5E3E6"))
);
