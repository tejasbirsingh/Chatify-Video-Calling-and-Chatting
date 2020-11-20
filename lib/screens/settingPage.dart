import 'dart:io';
import 'dart:math';

import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as Im;
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skype_clone/Theme/theme_colors.dart';
import 'package:skype_clone/constants/strings.dart';
import 'package:skype_clone/models/userData.dart';

import 'package:skype_clone/provider/theme_provider.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';
import 'package:skype_clone/resources/update_methods.dart';
import 'package:skype_clone/screens/home_screen.dart';
import 'package:skype_clone/utils/utilities.dart';

class settingPage extends StatefulWidget {
  @override
  _settingPageState createState() => _settingPageState();
}

class _settingPageState extends State<settingPage>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  Animation<double> animation;

  bool _darkTheme = true;
  bool _appLocked = false;
  File imageFile;
  bool _isEditing = false;
  String newName = "";
  String newStatus = "";
  final _statusKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _statusController = TextEditingController();
  final picker = ImagePicker();
  final UpdateMethods _updateMethods = UpdateMethods();
  AuthMethods authUser = AuthMethods();
  bool isNameEdit = false;
  bool isStatusEdit = false;
  var dayColor = Color(0xFFd56352);
  var nightColor = Color(0xFF1e2230);
  bool cirAn = false;
  // create some values
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  void initState() {
    super.initState();
    getSwitchValues();
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

  getSwitchValues() async {
    _appLocked = await getAppLocker();
    setState(() {});
  }

  colorPickerDialog(BuildContext context, String uid, String name) {
    showDialog(
        context: context,
        child: AlertDialog(
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
              child: const Text('Select'),
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
    // print(Colors.white.value);

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
        leading:IconButton(icon: Icon(Icons.arrow_back), onPressed: ()=> Navigator.pop(context)),
          centerTitle: true,
          title: Text('Settings',
              style: GoogleFonts.oswald(
                  textStyle: Theme.of(context).textTheme.headline1,
                  fontSize: 28.0)),
          iconTheme: Theme.of(context).iconTheme),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection(USERS_COLLECTION)
              .doc(userProvider.getUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              String url = snapshot.data.data()['profile_photo'];
              String name = snapshot.data.data()['name'];
              String email = snapshot.data.data()['email'];
              String status = snapshot.data.data()['status'];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    // Theme.of(context).backgroundColor,
                    // Theme.of(context).scaffoldBackgroundColor
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
                      height: 20.0,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal:
                              MediaQuery.of(context).size.width / 2 - 100.0),
                      title: GestureDetector(
                        onTap: () =>
                            _showImageDialog(context, userProvider.getUser),
                        child: CircleAvatar(
                          radius: 100.0,
                          backgroundImage: url != null
                              ? NetworkImage(url)
                              : NetworkImage(noImageAvailable),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(
                              Icons.photo_camera,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                        ),
                      ),
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
                      leading: Icon(
                        Icons.lock,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      title: Text(
                        'App Locker',
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
                          value: _appLocked,
                          onChanged: (bool val) {
                            setState(() {
                              _appLocked = val;
                              setAppLocker(val);
                            });
                          },
                        ),
                      ),
                    ),
                    isNameEdit == false
                        ? ListTile(
                            leading: Icon(
                              Icons.person,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            title: Text(
                              "Name",
                              style: GoogleFonts.patuaOne(
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  textStyle:
                                      Theme.of(context).textTheme.bodyText1),
                            ),
                            subtitle: Text(name,
                                style: Theme.of(context).textTheme.headline1),
                            trailing: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isNameEdit = true;
                                  });
                                }),
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Form(
                              key: _nameKey,
                              child: TextFormField(
                                controller: _nameController,
                                cursorColor: Theme.of(context).iconTheme.color,
                                style: Theme.of(context).textTheme.bodyText1,
                                validator: (val) {
                                  if (val.length < 2)
                                    return "Name should be atleast of length 2 !";
                                  return null;
                                },
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).splashColor,
                                          width: 2.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).splashColor,
                                          width: 2.0),
                                    ),
                                    hintText: "Edit Name",
                                    labelText: "Name",
                                    hintStyle:
                                        Theme.of(context).textTheme.bodyText1,
                                    labelStyle:
                                        Theme.of(context).textTheme.bodyText1,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        Icons.check,
                                        size: 30.0,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                      onPressed: () {
                                        if (_nameKey.currentState.validate()) {
                                          FirebaseFirestore.instance
                                              .collection(USERS_COLLECTION)
                                              .doc(userProvider.getUser.uid)
                                              .update({
                                            "name": _nameController.text
                                          });
                                          _nameController.clear();
                                          setState(() {
                                            isNameEdit = false;
                                          });
                                        }
                                        setState(() {
                                          isNameEdit = false;
                                        });
                                      },
                                    )),
                              ),
                            ),
                          ),
                    isStatusEdit == false
                        ? ListTile(
                            leading: Icon(
                              Icons.info_outline_rounded,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            title: Text(
                              "About",
                              style: GoogleFonts.patuaOne(
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  textStyle:
                                      Theme.of(context).textTheme.bodyText1),
                            ),
                            subtitle: Text(status ?? "No Status",
                                style: Theme.of(context).textTheme.headline1),
                            trailing: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isStatusEdit = true;
                                  });
                                }),
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Form(
                              key: _statusKey,
                              child: TextFormField(
                                controller: _statusController,
                                cursorColor: Theme.of(context).iconTheme.color,
                                style: Theme.of(context).textTheme.bodyText1,
                                validator: (val) {
                                  if (val.isEmpty) return "Enter the Status";
                                  return null;
                                },
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).splashColor,
                                          width: 2.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).splashColor,
                                          width: 2.0),
                                    ),
                                    hintText: "Edit Status",
                                    labelText: "Status",
                                    hintStyle:
                                        Theme.of(context).textTheme.bodyText1,
                                    labelStyle:
                                        Theme.of(context).textTheme.bodyText1,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        Icons.check,
                                        size: 30.0,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                      onPressed: () {
                                        if (_statusKey.currentState
                                            .validate()) {
                                          FirebaseFirestore.instance
                                              .collection(USERS_COLLECTION)
                                              .doc(userProvider.getUser.uid)
                                              .update({
                                            "status": _statusController.text
                                          });
                                          _statusController.clear();
                                          setState(() {
                                            isStatusEdit = false;
                                          });
                                        }
                                        setState(() {
                                          isStatusEdit = false;
                                        });
                                      },
                                    )),
                              ),
                            ),
                          ),
                    ListTile(
                      leading: Icon(
                        Icons.email_outlined,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      title: Text(
                        "Email",
                        style: GoogleFonts.patuaOne(
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            textStyle: Theme.of(context).textTheme.bodyText1),
                      ),
                      subtitle: Text(email,
                          style: Theme.of(context).textTheme.headline1),
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
                    ListTile(
                      leading: Icon(
                        Icons.colorize_outlined,
                        color: Theme.of(context).iconTheme.color,
                      ),
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
                      leading: Icon(
                        Icons.colorize_outlined,
                        color: Theme.of(context).iconTheme.color,
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
                            color: Theme.of(context).iconTheme.color,
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

  Future<bool> getAppLocker() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _appLocked =
          prefs.getBool('isLocked') != null ? prefs.getBool('isLocked') : false;
    });
    return _appLocked;
  }

  Future<bool> setAppLocker(bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLocked', val);
    return val;
  }

  Future<File> _pickImage(String action) async {
    File selectedImage;
    this.setState(() {
      _isEditing = true;
    });

    action == 'Gallery'
        ? selectedImage = await Utils.pickImage(source: ImageSource.gallery)
        : selectedImage = await Utils.pickImage(source: ImageSource.camera);
    if (selectedImage != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: selectedImage.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 80,
          maxHeight: 700,
          maxWidth: 700,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.black54,
            toolbarTitle: "Edit Image",
            statusBarColor: Colors.black,
            backgroundColor: Colors.black,
            toolbarWidgetColor: Colors.white,
          ));
      this.setState(() {
        _isEditing = false;
      });
      return cropped;
    } else {
      this.setState(() {
        _isEditing = false;
      });
    }
    return selectedImage;
  }

  void onThemeChanged(bool value, ThemeNotifier themeNotifier) async {
    (value) == true
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkTheme', value);
  }

  Future<AlertDialog> _showImageDialog(BuildContext context, UserData user) {
    return showDialog<AlertDialog>(
        context: context,
        barrierDismissible: false,
        builder: ((context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            backgroundColor: Colors.grey,
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  'Choose from Gallery',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                onPressed: () {
                  _pickImage('Gallery').then((selectedImage) {
                    setState(() {
                      imageFile = selectedImage;
                    });
                    compressImage();
                    _updateMethods.uploadImageToStorage(imageFile).then((url) {
                      _updateMethods.updatePhoto(url, user.uid).then((v) {
                        Navigator.pop(context);
                      });
                    });
                  });
                },
              ),
              SimpleDialogOption(
                child: Text(
                  'Take Photo',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                onPressed: () {
                  _pickImage('Camera').then((selectedImage) {
                    setState(() {
                      imageFile = selectedImage;
                    });
                    compressImage();
                    _updateMethods.uploadImageToStorage(imageFile).then((url) {
                      _updateMethods.updatePhoto(url, user.uid).then((v) {
                        //Navigator.pop(context);
                      });
                    });
                  });
                },
              ),
              SimpleDialogOption(
                child: Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        }));
  }

  // void savebackground(String path) async {
  //   var prefs = await SharedPreferences.getInstance();
  //   prefs.setString('background', path);
  // }

  void compressImage() async {
    print('Compression Started');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    Im.Image image = Im.decodeImage(imageFile.readAsBytesSync());
    Im.copyResize(image, width: 500, height: 500);

    var newim2 = new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));

    setState(() {
      imageFile = newim2;
    });
  }
}
