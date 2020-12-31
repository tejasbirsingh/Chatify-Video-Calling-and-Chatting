import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:skype_clone/models/contact.dart';
import 'package:skype_clone/models/userData.dart';
import 'package:skype_clone/provider/user_provider.dart';

import 'package:skype_clone/resources/auth_methods.dart';

import 'package:skype_clone/screens/chatscreens/chat_screen.dart';
import 'package:skype_clone/screens/chatscreens/widgets/cached_image.dart';

import 'package:skype_clone/screens/pageviews/chats/widgets/online_dot_indicator.dart';
import 'package:skype_clone/screens/pageviews/friends/widgets/friend_customTile.dart';
import 'package:skype_clone/screens/status_view/status_screen.dart';

class statusView extends StatelessWidget {
  final Contact contact;
  final AuthMethods _authMethods = AuthMethods();

  statusView(this.contact);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserData>(
      future: _authMethods.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData user = snapshot.data;

          return StatusViewLayout(friendViewLayout: user, contact: contact);
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class StatusViewLayout extends StatelessWidget {
  final UserData friendViewLayout;
  final Contact contact;
  final AuthMethods _authMethods = AuthMethods();

  StatusViewLayout({@required this.friendViewLayout, this.contact});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => statusPage(
                    contact: contact,
                  ))),
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        color: Theme.of(context).cardColor,
        child: ListTile(
          contentPadding: EdgeInsets.all(10.0),

          title: Text(
              (friendViewLayout != null ? friendViewLayout.name : null) != null
                  ? friendViewLayout.name
                  : "..",
              style: GoogleFonts.patuaOne(
                  textStyle: Theme.of(context).textTheme.headline1,
                  letterSpacing: 1.0) // style:

              ),
          // subtitle: Text(),
          leading: CachedImage(
            friendViewLayout.profilePhoto,
            radius: 60,
            isRound: true,
          ),
        ),
      ),
    );
  }
}
