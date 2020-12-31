import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skype_clone/provider/user_provider.dart';

class aboutPage extends StatefulWidget {
  @override
  _aboutPageState createState() => _aboutPageState();
}

class _aboutPageState extends State<aboutPage> {
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
            title: Text('About',
                style: GoogleFonts.oswald(
                    textStyle: Theme.of(context).textTheme.headline1,
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
                      : Theme.of(context).backgroundColor,
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
                      'Developer',
                      style: GoogleFonts.patuaOne(
                          letterSpacing: 1.0,
                          textStyle: Theme.of(context).textTheme.headline1),
                    ),
                    subtitle: Text('Tejas Bir Singh',
                        style: Theme.of(context).textTheme.bodyText1),
                    contentPadding: const EdgeInsets.only(left: 16.0),
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.codeBranch,
                      color: Theme.of(context).iconTheme.color,
                      size: 32.0,
                    ),
                    title: Text(
                      'App Version',
                      style: GoogleFonts.patuaOne(
                          letterSpacing: 1.0,
                          textStyle: Theme.of(context).textTheme.headline1),
                    ),
                    subtitle: Text('v 0.2.0',
                        style: Theme.of(context).textTheme.bodyText1),
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
