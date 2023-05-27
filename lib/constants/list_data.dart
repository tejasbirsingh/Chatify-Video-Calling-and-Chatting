import 'package:chatify/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chatify/BottomBar/bar_item.dart';

final List<BarItem> barItems = [
  BarItem(
    text: Strings.chats,
    iconData: FontAwesomeIcons.comment,
    color: Colors.indigo,
  ),
  BarItem(text: Strings.status, iconData: Icons.add, color: Colors.green),
  BarItem(
    text: Strings.contacts,
    iconData: FontAwesomeIcons.userGroup,
    color: Colors.pinkAccent,
  ),
  BarItem(
    text: Strings.calls,
    iconData: Icons.call,
    color: Colors.yellow.shade900,
  ),
];
