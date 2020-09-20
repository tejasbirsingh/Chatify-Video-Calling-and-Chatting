import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:skype_clone/models/contact.dart';
import 'package:skype_clone/models/userData.dart';
import 'package:skype_clone/provider/user_provider.dart';

import 'package:skype_clone/resources/auth_methods.dart';

import 'package:skype_clone/screens/chatscreens/chat_screen.dart';
import 'package:skype_clone/screens/chatscreens/widgets/cached_image.dart';

import 'package:skype_clone/screens/pageviews/chats/widgets/online_dot_indicator.dart';
import 'package:skype_clone/screens/pageviews/friends/widgets/friend_customTile.dart';

class friendView extends StatelessWidget {
  final Contact contact;
  final AuthMethods _authMethods = AuthMethods();

  friendView(this.contact);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserData>(
      future: _authMethods.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData user = snapshot.data;

          return ViewLayout(
            friendViewLayout: user,
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final UserData friendViewLayout;

  final AuthMethods _authMethods = AuthMethods();

  ViewLayout({
    @required this.friendViewLayout,
  });

  @override
  Widget build(BuildContext context) {
  final UserProvider user =
        Provider.of<UserProvider>(context, listen: true);
    return friendCustomTile(
      mini: false,
      onLongPress: () {
        _authMethods.removeFriend(user.getUser.uid, friendViewLayout.uid);
      },
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiver: friendViewLayout,
            ),
          )),
      title: Text(
        (friendViewLayout != null ? friendViewLayout.name : null) != null
            ? friendViewLayout.name
            : "..",
        style:
            TextStyle(color: Colors.white, fontFamily: "Arial", fontSize: 19),
      ),
      trailing: IconButton(icon: Icon(Icons.info,color: Colors.green,),
      onPressed: (){},),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 70, maxWidth: 70),
        child: Stack(
          children: <Widget>[
            OnlineDotIndicator(
              uid: friendViewLayout.uid,
            ),
            Center(
              child: CachedImage(
                friendViewLayout.profilePhoto,
                radius: 60,
                isRound: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
