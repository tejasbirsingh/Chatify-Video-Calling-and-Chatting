import 'package:flutter/cupertino.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatify/constants/strings.dart';
import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/screens/appSettings/about_page.dart';
import 'package:chatify/screens/appSettings/accountsettings_page.dart';
import 'package:chatify/screens/appSettings/customization_page.dart';
import 'package:chatify/screens/appSettings/privacy_page.dart';

/*
  It contains the privacy, customization, etc settings
*/
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: page(context));
  }

  Widget page(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          centerTitle: true,
          title: Text('Settings',
              style: GoogleFonts.oswald(
                  textStyle: Theme.of(context).textTheme.displayLarge,
                  fontSize: 28.0)),
          iconTheme: Theme.of(context).iconTheme),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection(USERS_COLLECTION)
              .doc(userProvider.getUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    userProvider.getUser.firstColor != null
                        ? Color(userProvider.getUser.firstColor ??
                            Colors.white.value)
                        : Theme.of(context).colorScheme.background,
                    userProvider.getUser.secondColor != null
                        ? Color(userProvider.getUser.secondColor ??
                            Colors.white.value)
                        : Theme.of(context).scaffoldBackgroundColor,
                  ]),
                ),
                child: ListView(
                  children: [
                    SizedBox(
                      height: 40.0,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => AccountsSettingsPage()),
                      ),
                      child: ListTile(
                          leading: Icon(
                            CupertinoIcons.person,
                            color: Colors.green,
                            size: 30.0,
                          ),
                          title: Text(
                            'Account',
                            style: GoogleFonts.patuaOne(
                                letterSpacing: 1.0,
                                textStyle:
                                    Theme.of(context).textTheme.displayLarge),
                          ),
                          subtitle: Text(
                            'Name, Profile Photo, Email, Status',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          trailing: Icon(Icons.arrow_forward_ios)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => CustomizationPage()),
                      ),
                      child: ListTile(
                          leading: Icon(
                            Icons.dashboard_customize,
                            color: Colors.blue,
                            size: 30.0,
                          ),
                          title: Text(
                            'Customize',
                            style: GoogleFonts.patuaOne(
                                letterSpacing: 1.0,
                                textStyle:
                                    Theme.of(context).textTheme.displayLarge),
                          ),
                          subtitle: Text(
                            'Dark Mode, App Color',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          trailing: Icon(Icons.arrow_forward_ios)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => PrivacyPage()),
                      ),
                      child: ListTile(
                          leading: Icon(
                            Icons.privacy_tip,
                            color: Colors.orange,
                            size: 30.0,
                          ),
                          title: Text(
                            'Privacy',
                            style: GoogleFonts.patuaOne(
                                letterSpacing: 1.0,
                                textStyle:
                                    Theme.of(context).textTheme.displayLarge),
                          ),
                          subtitle: Text(
                            'App Locker, Blocked Contacts',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          trailing: Icon(Icons.arrow_forward_ios)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => AboutPage()),
                      ),
                      child: ListTile(
                          leading: Icon(
                            Icons.info,
                            color: Colors.red,
                            size: 30.0,
                          ),
                          title: Text(
                            'About',
                            style: GoogleFonts.patuaOne(
                                letterSpacing: 1.0,
                                textStyle:
                                    Theme.of(context).textTheme.displayLarge),
                          ),
                          subtitle: Text(
                            'Developer, version',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          trailing: Icon(Icons.arrow_forward_ios)),
                    ),

                    // ListTile(
                    //   leading: Icon(
                    //     FontAwesomeIcons.image,
                    //     color: Theme.of(context).iconTheme.color,
                    //   ),
                    //   title: Text(
                    //     "Select Chat Background",
                    //      style: GoogleFonts.patuaOne(letterSpacing: 1.0,
                    //         textStyle: Theme.of(context).textTheme.headline1),
                    //   ),
                    //   trailing: IconButton(
                    //       icon: Icon(
                    //         FontAwesomeIcons.solidEdit,
                    //         color: Theme.of(context).iconTheme.color,
                    //       ),
                    //       onPressed: () async {

                    //         PickedFile selectedImage = await ImagePicker()
                    //             .getImage(source: ImageSource.gallery);
                    //         File img = File(selectedImage.path);

                    //         savebackground(img.path);
                    //       }),
                    // )
                  ],
                ),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
