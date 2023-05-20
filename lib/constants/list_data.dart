  import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skype_clone/BottomBar/bar_item.dart';

final List<BarItem> barItems = [
    BarItem(
      text: "Chats",
      iconData: FontAwesomeIcons.comment,
      color: Colors.indigo,
    ),
    // BarItem(text: "Search", iconData: Icons.search, color: Colors.green),
      BarItem(text: "Status", iconData: Icons.add, color: Colors.green),
    BarItem
    (
      text: "Contacts",
      iconData: FontAwesomeIcons.userGroup, 
      color: Colors.pinkAccent,
    ),
    BarItem(
      text: "Calls",
      iconData: Icons.call,
      color: Colors.yellow.shade900,
    ),
  ];