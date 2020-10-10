import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as Im;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skype_clone/Theme/theme_colors.dart';
import 'package:skype_clone/provider/theme_provider.dart';
import 'package:skype_clone/constants/strings.dart';
import 'package:skype_clone/models/userData.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';

import 'package:skype_clone/resources/update_methods.dart';
import 'package:skype_clone/utils/utilities.dart';
import 'package:skype_clone/widgets/skype_appbar.dart';

// ignore: camel_case_types
class settingPage extends StatefulWidget {
  @override
  _settingPageState createState() => _settingPageState();
}

// ignore: camel_case_types
class _settingPageState extends State<settingPage> {
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
  @override
  void initState() {
    super.initState();
    getSwitchValues();
  }

  getSwitchValues() async {
    _appLocked = await getAppLocker();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final String noImageUrl =
        "https://www.google.com/search?q=no+image&rlz=1C1CHBF_enIN802IN802&sxsrf=ALeKk026xztGQvA9DCX0yfejmBRaP8UXTA:1599745232866&tbm=isch&source=iu&ictx=1&fir=NF-z0Y67xzPPBM%252C029W-ajBtZqZzM%252C_&vet=1&usg=AI4_-kQZgZPDLdtCSE-P_wyfcTCySoOtjw&sa=X&ved=2ahUKEwjZ5Ney297rAhUa73MBHRZWD7QQ9QF6BAgKEC4#imgrc=NF-z0Y67xzPPBM";
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Settings', style: Theme.of(context).textTheme.headline1),
          iconTheme:Theme.of(context).iconTheme
         
        ),
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
                return ListView(
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
                              : NetworkImage(noImageUrl),
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
                      title: Text(
                        'Dark Mode',
                        style: Theme.of(context).textTheme.headline1,
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
                            });
                            onThemeChanged(val, themeNotifier);
                          },
                        ),
                      ),
                    ),
                    isNameEdit == false
                        ? ListTile(
                            title: Text(
                              "Name",
                              style: Theme.of(context).textTheme.headline1,
                            ),
                            subtitle: Text(name,
                                style: Theme.of(context).textTheme.bodyText1),
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
                                     focusedBorder:OutlineInputBorder(
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
                            title: Text(
                              "Status",
                              style: Theme.of(context).textTheme.headline1,
                            ),
                            subtitle: Text(status ?? "No Status",
                                style: Theme.of(context).textTheme.bodyText1),
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
                                    focusedBorder:OutlineInputBorder(
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
                      title: Text(
                        "Email",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      subtitle: Text(email,
                          style: Theme.of(context).textTheme.bodyText1),
                      trailing:
                          IconButton(icon: Icon(Icons.edit), onPressed: () {}),
                    ),
                    ListTile(
                      title: Text(
                        'App Locker',
                        style: Theme.of(context).textTheme.headline1,
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
                  ],
                );
              }
            }),
      ),
    );
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
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        }));
  }

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
    print('Done');
  }
}
