import 'package:flutter/material.dart';
import 'package:skype_clone/screens/callscreens/pickup/pickup_layout.dart';

import 'package:skype_clone/widgets/skype_appbar.dart';

import 'widgets/log_list_container.dart';

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        // backgroundColor: Theme.of(context).backgroundColor,
        appBar: SkypeAppBar(
           leading: Text(""),
          title: "Calls",
          actions: <Widget>[],
        ),
        body: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [
          Theme.of(context).backgroundColor,
          Theme.of(context).scaffoldBackgroundColor
        ]),),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: LogListContainer(),
          ),
        ),
      ),
    );
  }
}
