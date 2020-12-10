import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skype_clone/Theme/theme_colors.dart';
import 'package:skype_clone/constants/strings.dart';
import 'package:skype_clone/provider/theme_provider.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';
import 'package:skype_clone/widgets/gradient_icon.dart';

class customizationPage extends StatefulWidget {
  @override
  _customizationPageState createState() => _customizationPageState();
}

class _customizationPageState extends State<customizationPage>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  Animation<double> animation;

  bool _darkTheme = true;

  AuthMethods authUser = AuthMethods();
  bool isNameEdit = false;
  bool isStatusEdit = false;
  var dayColor = Color(0xFFd56352);
  var nightColor = Color(0xFF1e2230);
  bool cirAn = false;

  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    );
    animationController.forward();
  }

  colorPickerDialog(BuildContext context, String uid, String name) {
    showDialog(
        context: context,
        child: AlertDialog(
          actionsPadding: EdgeInsets.all(10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          backgroundColor: Colors.white,
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Select',
                style: TextStyle(fontSize: 18.0),
              ),
              onPressed: () {
                setState(() => currentColor = pickerColor);
                FirebaseFirestore.instance
                    .collection(USERS_COLLECTION)
                    .doc(uid)
                    .update({name: currentColor.value});

                Navigator.of(context).pop();
              },
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SafeArea(
        child: cirAn
            ? CircularRevealAnimation(
                animation: animation,
                centerOffset: Offset(size.height / 15, size.width / 3.5),
                child: page(context))
            : page(context));
  }

  Widget page(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          centerTitle: false,
          title: Text('Customize',
              style: GoogleFonts.oswald(
                  textStyle: Theme.of(context).textTheme.headline1,
                  fontSize: 26.0)),
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
                        : Theme.of(context).backgroundColor,
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
                    ListTile(
                      leading: Icon(
                        Icons.color_lens,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      title: Text(
                        'Dark Mode',
                        style: GoogleFonts.patuaOne(
                            letterSpacing: 1.0,
                            textStyle: Theme.of(context).textTheme.headline1),
                      ),
                      contentPadding: const EdgeInsets.only(left: 16.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          inactiveTrackColor: Theme.of(context).dividerColor,
                          activeColor: Colors.green,
                          value: _darkTheme,
                          onChanged: (val) {
                            setState(() {
                              _darkTheme = val;
                              cirAn = true;
                            });
                            onThemeChanged(val, themeNotifier);
                            if (animationController.status ==
                                    AnimationStatus.forward ||
                                animationController.status ==
                                    AnimationStatus.completed) {
                              animationController.reset();
                              animationController.forward();
                            } else {
                              animationController.forward();
                            }
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      leading: GradientIcon(
                        FontAwesomeIcons.tint,
                        32.0,
                        LinearGradient(
                          colors: <Color>[
                            Colors.green,
                            Colors.orange,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      // leading: Icon(
                      //   FontAwesomeIcons.tint,
                      //   color: Theme.of(context).iconTheme.color,
                      // ),
                      title: Text(
                        "Pick First Color",
                        style: GoogleFonts.patuaOne(
                            letterSpacing: 1.0,
                            textStyle: Theme.of(context).textTheme.headline1),
                      ),
                      trailing: IconButton(
                          icon: Icon(
                            FontAwesomeIcons.handPointer,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () async {
                            colorPickerDialog(context, userProvider.getUser.uid,
                                'first_color');
                            print(currentColor);
                          }),
                    ),
                    ListTile(
                      leading: GradientIcon(
                        FontAwesomeIcons.tint,
                        32.0,
                        LinearGradient(
                          colors: <Color>[
                            Colors.blue,
                            Colors.red,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      title: Text(
                        "Pick Second Color",
                        style: GoogleFonts.patuaOne(
                            letterSpacing: 1.0,
                            textStyle: Theme.of(context).textTheme.headline1),
                      ),
                      trailing: IconButton(
                          icon: Icon(
                            FontAwesomeIcons.handPointer,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () async {
                            await colorPickerDialog(context,
                                userProvider.getUser.uid, 'second_color');
                            userProvider.refreshUser();
                          }),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.restore,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      title: Text(
                        "Reset Custom Color",
                        style: GoogleFonts.patuaOne(
                            letterSpacing: 1.0,
                            textStyle: Theme.of(context).textTheme.headline1),
                      ),
                      trailing: IconButton(
                          icon: Icon(
                            Icons.delete_forever_sharp,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            FirebaseFirestore.instance
                                .collection(USERS_COLLECTION)
                                .doc(userProvider.getUser.uid)
                                .update({'first_color': null});
                            FirebaseFirestore.instance
                                .collection(USERS_COLLECTION)
                                .doc(userProvider.getUser.uid)
                                .update({'second_color': null});
                            userProvider.refreshUser();
                            // backgroundColor("secondcolor", secondColor);
                          }),
                    ),
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

  void backgroundColor(String name, Color color) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt(name, color.value);
  }

  void onThemeChanged(bool value, ThemeNotifier themeNotifier) async {
    (value) == true
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkTheme', value);
  }
}
