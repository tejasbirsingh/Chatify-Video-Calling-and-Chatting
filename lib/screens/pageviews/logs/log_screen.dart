import 'package:flutter/material.dart';
import 'package:skype_clone/screens/callscreens/pickup/pickup_layout.dart';

import 'package:skype_clone/widgets/skype_appbar.dart';

import 'widgets/log_list_container.dart';

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: SkypeAppBar(
          title: "Calls",
          actions: <Widget>[],
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 15),
          child: LogListContainer(),
        ),
      ),
    );
  }
}
