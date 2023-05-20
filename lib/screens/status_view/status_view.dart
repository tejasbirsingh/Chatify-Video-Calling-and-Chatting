import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



import 'package:chatify/models/contact.dart';
import 'package:chatify/models/userData.dart';


import 'package:chatify/resources/auth_methods.dart';


import 'package:chatify/screens/chatscreens/widgets/cached_image.dart';


import 'package:chatify/screens/status_view/status_screen.dart';

class StatusView extends StatelessWidget {
  final Contact contact;
  final AuthMethods _authMethods = AuthMethods();

  StatusView(this.contact);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserData?>(
      future: _authMethods.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData user = snapshot.data!;

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
  final Contact? contact;


  StatusViewLayout({required this.friendViewLayout, this.contact});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StatusPage(
                    contact: contact!,
                  ))),
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        color: Theme.of(context).cardColor,
        child: ListTile(
          contentPadding: EdgeInsets.all(10.0),

          title: Text(
              (friendViewLayout != null ? friendViewLayout.name! : null) != null
                  ? friendViewLayout.name!
                  : "..",
              style: GoogleFonts.patuaOne(
                  textStyle: Theme.of(context).textTheme.displayLarge,
                  letterSpacing: 1.0) // style:

              ),
          // subtitle: Text(),
          leading: CachedImage(
            friendViewLayout.profilePhoto!,
            radius: 60,
            isRound: true,
          ),
        ),
      ),
    );
  }
}
