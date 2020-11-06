  import 'package:flutter/material.dart';
import 'package:skype_clone/BottomBar/bar_item.dart';

final List<BarItem> barItems = [
    BarItem(
      text: "Chats",
      iconData: Icons.chat,
      color: Colors.indigo,
    ),
    BarItem(text: "Search", iconData: Icons.search, color: Colors.green),
    BarItem(
      text: "Contacts",
      iconData: Icons.contacts,
      color: Colors.pinkAccent,
    ),
    BarItem(
      text: "Calls",
      iconData: Icons.call,
      color: Colors.yellow.shade900,
    ),
  ];