import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/screens/callscreens/pickup/pickup_layout.dart';

import 'package:skype_clone/widgets/skype_appbar.dart';

import 'widgets/log_list_container.dart';

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return PickupLayout(
      scaffold: Scaffold(
        appBar: SkypeAppBar(
          leading: Text(""),
          title: "Calls",
          actions: <Widget>[],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              userProvider.getUser.firstColor != null
                  ? Color(userProvider.getUser.firstColor ?? Colors.white.value)
                  : Theme.of(context).colorScheme.background,
              userProvider.getUser.secondColor != null
                  ? Color(
                      userProvider.getUser.secondColor ?? Colors.white.value)
                  : Theme.of(context).scaffoldBackgroundColor,
            ]),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: LogListContainer(),
          ),
        ),
      ),
    );
  }
}
