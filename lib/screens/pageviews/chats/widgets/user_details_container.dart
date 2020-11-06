import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skype_clone/enum/user_state.dart';
import 'package:skype_clone/models/userData.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';
import 'package:skype_clone/screens/chatscreens/widgets/cached_image.dart';
import 'package:skype_clone/screens/login_screen.dart';
import 'package:skype_clone/widgets/appbar.dart';

import 'shimmering_logo.dart';

class UserDetailsContainer extends StatelessWidget {
  final AuthMethods authMethods = AuthMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    signOut() async {
      final bool isLoggedOut = await AuthMethods().signOut();
      if (isLoggedOut) {
        authMethods.setUserState(
          userId: userProvider.getUser.uid,
          userState: UserState.Offline,
        );

        var prefs = await SharedPreferences.getInstance();
        prefs.setBool('darkTheme', false);
        prefs.setString('background','');
  
  

        // move the user to login screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }

    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 25),
        child: Column(
          children: <Widget>[
            CustomAppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).iconTheme.color),
                onPressed: () => Navigator.maybePop(context),
              ),
              centerTitle: true,
              title: ShimmeringLogo(),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => signOut(),
                  child: Text("Sign Out",
                      style: GoogleFonts.cuprum(
                          textStyle: Theme.of(context).textTheme.bodyText1)),
                )
              ],
            ),
            UserDetailsBody(),
          ],
        ),
      ),
    );
  }
}

class UserDetailsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final UserData user = userProvider.getUser;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: [
          CachedImage(
            user.profilePhoto,
            isRound: true,
            radius: 65.0,
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(user.name,
                  style: GoogleFonts.patuaOne(
                      textStyle: Theme.of(context).textTheme.bodyText1,
                      fontSize: 25.0,
                      letterSpacing: 1.5)),
              SizedBox(height: 10),
              Text(user.email,
                  style: GoogleFonts.cuprum(
                      textStyle: Theme.of(context).textTheme.bodyText1)),
            ],
          ),
        ],
      ),
    );
  }
}
