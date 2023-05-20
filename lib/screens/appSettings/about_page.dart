import 'package:chatify/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:chatify/provider/user_provider.dart';

/*
  It contains app specific details.
*/
class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context)),
            centerTitle: false,
            title: Text(Strings.about,
                style: GoogleFonts.oswald(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: 26.0)),
            iconTheme: Theme.of(context).iconTheme),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  userProvider.getUser.firstColor != null
                      ? Color(
                          userProvider.getUser.firstColor ?? Colors.white.value)
                      : Theme.of(context).colorScheme.background,
                  userProvider.getUser.secondColor != null
                      ? Color(userProvider.getUser.secondColor ??
                          Colors.white.value)
                      : Theme.of(context).scaffoldBackgroundColor,
                ]),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.developer_board,
                      color: Colors.blue,
                      size: 32.0,
                    ),
                    title: Text(
                      Strings.developer,
                      style: GoogleFonts.patuaOne(
                          letterSpacing: 1.0,
                          textStyle: Theme.of(context).textTheme.displayLarge),
                    ),
                    subtitle: Text(Strings.developerName,
                        style: Theme.of(context).textTheme.bodyLarge),
                    contentPadding: const EdgeInsets.only(left: 16.0),
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.codeBranch,
                      color: Theme.of(context).iconTheme.color,
                      size: 32.0,
                    ),
                    title: Text(
                      Strings.appVersion,
                      style: GoogleFonts.patuaOne(
                          letterSpacing: 1.0,
                          textStyle: Theme.of(context).textTheme.displayLarge),
                    ),
                    subtitle: Text(Strings.appVersionNumber,
                        style: Theme.of(context).textTheme.bodyLarge),
                    contentPadding: const EdgeInsets.only(left: 16.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
