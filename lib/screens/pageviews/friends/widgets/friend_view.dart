import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:chatify/models/contact.dart';
import 'package:chatify/models/userData.dart';
import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/resources/auth_methods.dart';
import 'package:chatify/screens/chatscreens/chat_screen.dart';
import 'package:chatify/screens/chatscreens/widgets/cached_image.dart';
import 'package:chatify/screens/pageviews/chats/widgets/online_dot_indicator.dart';
import 'package:chatify/screens/pageviews/friends/widgets/friend_custom_tile.dart';

class FriendView extends StatelessWidget {
  final Contact contact;
  final AuthMethods _authMethods = AuthMethods();

  FriendView(this.contact);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserData?>(
      future: _authMethods.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData user = snapshot.data!;

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
    required this.friendViewLayout,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider user = Provider.of<UserProvider>(context, listen: true);
    return FriendCustomTile(
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
          (friendViewLayout != null ? friendViewLayout.name! : null) != null
              ? friendViewLayout.name!
              : "..",
          style: GoogleFonts.patuaOne(
            textStyle: Theme.of(context).textTheme.displayLarge,
          ) // style:

          ),
      trailing: IconButton(
        icon: Icon(
          Icons.remove_circle,
          color: Colors.red,
        ),
        onPressed: () {
          _authMethods.removeFriend(user.getUser.uid, friendViewLayout.uid);
        },
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 70, maxWidth: 70),
        child: Stack(
          children: <Widget>[
            OnlineDotIndicator(
              uid: friendViewLayout.uid!,
            ),
            Center(
              child: CachedImage(
                friendViewLayout.profilePhoto!,
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
