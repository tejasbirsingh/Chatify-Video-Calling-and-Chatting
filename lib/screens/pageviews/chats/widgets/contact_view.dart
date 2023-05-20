import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skype_clone/models/contact.dart';

import 'package:skype_clone/models/userData.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';
import 'package:skype_clone/resources/chat_methods.dart';
import 'package:skype_clone/screens/chatscreens/chat_screen.dart';
import 'package:skype_clone/screens/chatscreens/widgets/cached_image.dart';
import 'package:skype_clone/screens/profile_screen.dart';
import 'package:skype_clone/widgets/custom_tile.dart';

import 'last_message_container.dart';
import 'online_dot_indicator.dart';

class ContactView extends StatefulWidget {
  final Contact contact;
  final String senderId;

  ContactView(this.contact, this.senderId);

  @override
  _ContactViewState createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  final AuthMethods _authMethods = AuthMethods();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserData?>(
      future: _authMethods.getUserDetailsById(widget.contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData user = snapshot.data!;

          return ViewLayout(
            contact: user,
            senderId: widget.senderId,
          );
        }
        return Center(
          child: Container(),
        );
      },
    );
  }
}

class ViewLayout extends StatefulWidget {
  final UserData? contact;
  final String? senderId;
  ViewLayout({required this.contact, this.senderId});

  @override
  _ViewLayoutState createState() => _ViewLayoutState();
}

class _ViewLayoutState extends State<ViewLayout> {
  final ChatMethods _chatMethods = ChatMethods();

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return CustomTile(
      mini: false,
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiver: widget.contact!,
            ),
          )),
      title: Row(
        children: [
          Text(
              (widget.contact != null ? widget.contact!.name! : null) != null
                  ? widget.contact!.name!
                  : "..",
              style: GoogleFonts.patuaOne(
                  textStyle: Theme.of(context).textTheme.displayLarge,
                  letterSpacing: 1.5)),
          SizedBox(
            width: 40.0,
          ),

          FutureBuilder<int>(
              initialData: 0,
              future: _chatMethods.unreadMessagesCount(
                  senderId: widget.senderId!, receiverId: widget.contact!.uid!),
              builder: (_, snapshot) {
                return snapshot.data != 0
                    ? Text(snapshot.data.toString(),
                        style: GoogleFonts.patuaOne(
                            textStyle: Theme.of(context).textTheme.bodyLarge,
                            letterSpacing: 1.5))
                    : Text("");
              }),
        ],
      ),
      subtitle: LastMessageContainer(
        stream: _chatMethods.fetchLastMessageBetween(
          senderId: userProvider.getUser.uid!,
          receiverId: widget.contact!.uid!,
        ),
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 70, maxWidth: 70),
        child: Stack(
          children: <Widget>[
            OnlineDotIndicator(
              uid: widget.contact!.uid!,
            ),
            Center(
              child: CachedImage(
                widget.contact!.profilePhoto!,
                radius: 60,
                isRound: true,
                isTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => profilePage(
                        user: widget.contact!,
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
