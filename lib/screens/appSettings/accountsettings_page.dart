import 'dart:io';
import 'dart:math';
import 'package:chatify/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:image/image.dart' as Im;
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:chatify/constants/strings.dart';
import 'package:chatify/models/userData.dart';
import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/resources/auth_methods.dart';
import 'package:chatify/resources/update_methods.dart';
import 'package:chatify/screens/login_screen.dart';
import 'package:chatify/utils/utilities.dart';

/*
  It contains account specific settings.
*/
class AccountsSettingsPage extends StatefulWidget {
  @override
  _AccountsSettingsPageState createState() => _AccountsSettingsPageState();
}

class _AccountsSettingsPageState extends State<AccountsSettingsPage> {
  String newName = "";
  String newStatus = "";
  final _statusKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _statusController = TextEditingController();

  final UpdateMethods _updateMethods = UpdateMethods();
  AuthMethods authUser = AuthMethods();
  bool isNameEdit = false;
  File? imageFile;
  bool _isEditing = false;
  bool isStatusEdit = false;
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
            title: Text(Strings.account,
                style: GoogleFonts.oswald(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: 26.0)),
            iconTheme: Theme.of(context).iconTheme),
        body: StreamBuilder<DocumentSnapshot?>(
            stream: FirebaseFirestore.instance
                .collection(USERS_COLLECTION)
                .doc(userProvider.getUser.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                String? url = snapshot.data![Constants.PROFILE_PHOTO];
                String? name = snapshot.data![Constants.NAME];
                String? email = snapshot.data![Constants.EMAIL];
                String? status = snapshot.data![Constants.STATUS];
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
                      isNameEdit == false
                          ? ListTile(
                              leading: Icon(
                                Icons.person,
                                color: Colors.green.shade500,
                              ),
                              title: Text(
                                Strings.name,
                                style: GoogleFonts.patuaOne(
                                    letterSpacing: 1.0,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    textStyle:
                                        Theme.of(context).textTheme.bodyLarge),
                              ),
                              subtitle: Text(name!,
                                  style:
                                      Theme.of(context).textTheme.displayLarge),
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
                                  cursorColor:
                                      Theme.of(context).iconTheme.color,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  validator: (val) {
                                    if (val!.length < 2)
                                      return "Name should be atleast of length 2 !";
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).splashColor,
                                            width: 2.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).splashColor,
                                            width: 2.0),
                                      ),
                                      hintText: Strings.nameHintText,
                                      labelText: Strings.nameLabel,
                                      hintStyle:
                                          Theme.of(context).textTheme.bodyLarge,
                                      labelStyle:
                                          Theme.of(context).textTheme.bodyLarge,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          Icons.check,
                                          size: 30.0,
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ),
                                        onPressed: () {
                                          if (_nameKey.currentState!
                                              .validate()) {
                                            FirebaseFirestore.instance
                                                .collection(USERS_COLLECTION)
                                                .doc(userProvider.getUser.uid)
                                                .update({
                                              Constants.NAME:
                                                  _nameController.text
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
                                color: Colors.deepOrange,
                              ),
                              title: Text(
                                Strings.about,
                                style: GoogleFonts.patuaOne(
                                    letterSpacing: 1.0,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    textStyle:
                                        Theme.of(context).textTheme.bodyLarge),
                              ),
                              subtitle: Text(status ?? Strings.noStatus,
                                  style:
                                      Theme.of(context).textTheme.displayLarge),
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
                                  cursorColor:
                                      Theme.of(context).iconTheme.color,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  validator: (val) {
                                    if (val!.isEmpty) return "Enter the Status";
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).splashColor,
                                            width: 2.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).splashColor,
                                            width: 2.0),
                                      ),
                                      hintText: Strings.editStatus,
                                      labelText: Strings.status,
                                      hintStyle:
                                          Theme.of(context).textTheme.bodyLarge,
                                      labelStyle:
                                          Theme.of(context).textTheme.bodyLarge,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          Icons.check,
                                          size: 30.0,
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ),
                                        onPressed: () {
                                          if (_statusKey.currentState!
                                              .validate()) {
                                            FirebaseFirestore.instance
                                                .collection(USERS_COLLECTION)
                                                .doc(userProvider.getUser.uid)
                                                .update({
                                              Constants.STATUS:
                                                  _statusController.text
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
                          color: Colors.pink,
                        ),
                        title: Text(
                          Strings.email,
                          style: GoogleFonts.patuaOne(
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              textStyle: Theme.of(context).textTheme.bodyLarge),
                        ),
                        subtitle: Text(email!,
                            style: Theme.of(context).textTheme.displayLarge),
                      ),
                      // InkWell(
                      //   onTap: deleteAccountDialog(context),
                      //   child: ListTile(
                      //     leading: Icon(
                      //       Icons.delete,
                      //       color: Colors.red,
                      //     ),
                      //     title: Text(
                      //       "Delete Account",
                      //       style: GoogleFonts.patuaOne(
                      //           letterSpacing: 1.0,
                      //           fontWeight: FontWeight.bold,
                      //           fontSize: 18.0,
                      //           textStyle:
                      //               Theme.of(context).textTheme.bodyText1),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }

  deleteAccountDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              "Delete this message ?",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            actions: [
              TextButton(
                child:
                    Text('Yes', style: Theme.of(context).textTheme.bodyLarge),
                onPressed: () async {
                  final FirebaseMessaging _firebaseMessaging =
                      FirebaseMessaging.instance;
                  String? token;
                  User user = FirebaseAuth.instance.currentUser!;
                  user.delete();
                  await _firebaseMessaging.getToken().then((deviceToken) {
                    setState(() {
                      token = deviceToken.toString();
                    });
                  });
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => LoginScreen(
                                token: token,
                              )));
                },
              ),
              TextButton(
                child: Text('No', style: Theme.of(context).textTheme.bodyLarge),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  Future<AlertDialog?> _showImageDialog(BuildContext context, UserData user) {
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
                  Strings.chooseFromGallery,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onPressed: () {
                  _pickImage(Constants.GALLERY).then((selectedImage) {
                    setState(() {
                      imageFile = selectedImage;
                    });
                    compressImage();
                    _updateMethods.uploadImageToStorage(imageFile!).then((url) {
                      _updateMethods.updatePhoto(url, user.uid!).then((v) {
                        Navigator.pop(context);
                      });
                    });
                  });
                },
              ),
              SimpleDialogOption(
                child: Text(
                  Strings.takePhoto,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onPressed: () {
                  _pickImage(Constants.CAMERA).then((selectedImage) {
                    setState(() {
                      imageFile = selectedImage;
                    });
                    compressImage();
                    _updateMethods.uploadImageToStorage(imageFile!).then((url) {
                      _updateMethods.updatePhoto(url, user.uid!).then((v) {
                        //Navigator.pop(context);
                      });
                    });
                  });
                },
              ),
              SimpleDialogOption(
                child: Text(
                  Strings.cancel,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        }));
  }

  Future<File?> _pickImage(String action) async {
    File? selectedImage;
    this.setState(() {
      _isEditing = true;
    });

    action == Constants.GALLERY
        ? selectedImage = await Utils.pickImage(source: ImageSource.gallery)
        : selectedImage = await Utils.pickImage(source: ImageSource.camera);
    if (selectedImage != null) {
      final cropped = await ImageCropper().cropImage(
        sourcePath: selectedImage.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80,
        maxHeight: 700,
        maxWidth: 700,
        uiSettings: [
          AndroidUiSettings(
            toolbarColor: Colors.black54,
            toolbarTitle: Strings.editImage,
            statusBarColor: Colors.black,
            backgroundColor: Colors.black,
            toolbarWidgetColor: Colors.white,
          )
        ],
      ) as File;
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

  void compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    Im.Image image = Im.decodeImage(imageFile!.readAsBytesSync())!;
    Im.copyResize(image, width: 500, height: 500);

    var newim2 = new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));

    setState(() {
      imageFile = newim2;
    });
  }
}
