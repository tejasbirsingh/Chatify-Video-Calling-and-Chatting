import 'package:chatify/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/screens/callscreens/pickup/pickup_layout.dart';
import 'package:chatify/widgets/chatify_app_bar.dart';
import 'widgets/log_list_container.dart';

/*
 * It is responsible for showing the call logs.
 */
class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return PickupLayout(
      scaffold: Scaffold(
        appBar: ChatifyAppBar(
          leading: Text(""),
          title: Strings.calls,
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
