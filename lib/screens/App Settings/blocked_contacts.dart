import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skype_clone/models/contact.dart';
import 'package:skype_clone/models/userData.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';
import 'package:skype_clone/resources/chat_methods.dart';
import 'package:skype_clone/screens/chatscreens/widgets/cached_image.dart';
import 'package:skype_clone/screens/pageviews/friends/widgets/friend_customTile.dart';

class blockedContacts extends StatefulWidget {
  @override
  _blockedContactsState createState() => _blockedContactsState();
}

class _blockedContactsState extends State<blockedContacts> {
  ChatMethods _chatMethods = ChatMethods();
 
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          title: Text('Blocked Contacts',
              style: GoogleFonts.oswald(
                  textStyle: Theme.of(context).textTheme.displayLarge,
                  fontSize: 28.0)),
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
          child: StreamBuilder<QuerySnapshot>(
            stream: _chatMethods.fetchBlockedUsers(
                userId: userProvider.getUser.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var docList = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemCount: docList.length,
                  itemBuilder: (context, i) {
                    Contact user = Contact.fromMap(docList[i].data() as Map<String, dynamic>);

                    return BlockedContactView(user);
                  },
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class BlockedContactView extends StatelessWidget {
  final Contact contact;
  final AuthMethods _authMethods = AuthMethods();

  BlockedContactView(this.contact);

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
  final ChatMethods _chatMethods = ChatMethods();


  ViewLayout({
    required this.friendViewLayout,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider user = Provider.of<UserProvider>(context, listen: true);
    return FriendCustomTile(
      mini: false,
      onLongPress: () {},
      onTap: () {},
      title: Text(
          (friendViewLayout != null ? friendViewLayout.name : null) != null
              ? friendViewLayout.name!
              : "..",
          style: GoogleFonts.patuaOne(
            textStyle: Theme.of(context).textTheme.displayLarge,
          ) // style:

          ),
      trailing: IconButton(
        icon: Icon(
          Icons.block_flipped,
          color: Colors.green,
        ),
        onPressed: () {
          _chatMethods.addToBlockedList(
              senderId: user.getUser.uid, receiverId: friendViewLayout.uid);
        },
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 70, maxWidth: 70),
        child: Stack(
          children: <Widget>[
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
