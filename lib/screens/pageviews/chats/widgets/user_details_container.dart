import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatify/constants/constants.dart';
import 'package:chatify/constants/strings.dart';
import 'package:chatify/enum/user_state.dart';
import 'package:chatify/models/userData.dart';
import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/resources/auth_methods.dart';
import 'package:chatify/screens/chatscreens/widgets/cached_image.dart';
import 'package:chatify/screens/login_screen.dart';
import 'package:chatify/widgets/skype_appbar.dart';
import 'shimmering_logo.dart';

/*
User Details Container can be opened from user circle
*/
class UserDetailsContainer extends StatelessWidget {
  final AuthMethods authMethods = AuthMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    signOut() async {
      final bool isLoggedOut = await AuthMethods().signOut();
      if (isLoggedOut) {
        authMethods.setUserState(
          userId: userProvider.getUser.uid!,
          userState: UserState.Offline,
        );

        var prefs = await SharedPreferences.getInstance();
        prefs.setBool(Constants.DARK_THEME, false);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            userProvider.getUser.firstColor != null
                ? Color(userProvider.getUser.firstColor ?? Colors.white.value)
                : Theme.of(context).colorScheme.background,
            userProvider.getUser.secondColor != null
                ? Color(userProvider.getUser.secondColor ?? Colors.white.value)
                : Theme.of(context).scaffoldBackgroundColor,
          ]),
        ),
        margin: EdgeInsets.only(top: 25),
        child: Column(
          children: <Widget>[
            SkypeAppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).iconTheme.color),
                onPressed: () => Navigator.maybePop(context),
              ),
              title: ShimmeringLogo(),
              actions: <Widget>[
                TextButton(
                  onPressed: () => signOut(),
                  child: Text(Strings.signOut,
                      style: GoogleFonts.cuprum(
                          textStyle: Theme.of(context).textTheme.bodyLarge)),
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
            user.profilePhoto!,
            isRound: true,
            radius: 65.0,
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(user.name!,
                  style: GoogleFonts.patuaOne(
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      fontSize: 25.0,
                      letterSpacing: 1.5)),
              SizedBox(height: 10),
              Text(user.email!,
                  style: GoogleFonts.cuprum(
                      textStyle: Theme.of(context).textTheme.bodyLarge)),
            ],
          ),
        ],
      ),
    );
  }
}
