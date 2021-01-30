import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:skype_clone/models/userData.dart';
import 'package:skype_clone/widgets/skype_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:skype_clone/screens/status_view/status_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:skype_clone/constants/strings.dart';
import 'package:skype_clone/models/contact.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';
import 'package:skype_clone/resources/storage_methods.dart';
import 'package:skype_clone/screens/pageviews/chats/widgets/quiet_box.dart';
import 'package:skype_clone/screens/status_view/status_view.dart';
import 'package:skype_clone/utils/utilities.dart';

class allStatusPage extends StatefulWidget {
  @override
  _allStatusPageState createState() => _allStatusPageState();
}

class _allStatusPageState extends State<allStatusPage> {
  StorageMethods _storageMethods = StorageMethods();
  AuthMethods _authMethods = AuthMethods();
  UserProvider userProvider;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);
  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: SkypeAppBar(
          leading: Text(""),
          title: 'Status',
          actions: [
            IconButton(
              icon: Icon(
                FontAwesomeIcons.slidersH,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/setting_page");
              },
            ),
          ],
        ),
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
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: InkWell(
                        onTap: () {
                          pickImage(
                              source: ImageSource.gallery,
                              userId: userProvider.getUser.uid);
                        },
                        child: ListTile(
                          leading: Stack(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(
                                    userProvider.getUser.profilePhoto),
                              ),
                              Positioned(
                                bottom: 0.0,
                                right: 1.0,
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle),
                                ),
                              ),
                            ],
                          ),
                          title: Text("My Status",
                              style: Theme.of(context).textTheme.headline1),
                          subtitle: Text("Tap to add status",
                              style: Theme.of(context).textTheme.bodyText1),
                        ),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(USERS_COLLECTION)
                          .doc(userProvider.getUser.uid??"")
                          .collection(STATUS)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var docList = snapshot.data.docs;
                        if(docList.isNotEmpty){
                            return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            color: Theme.of(context).cardColor,
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: InkWell(
                                onTap: () {
                                  Contact contact = Contact(
                                      uid: userProvider.getUser.uid,
                                      addedOn: Timestamp.now());
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => statusPage(
                                                contact: contact,
                                              )));
                                },
                                child: ListTile(
                                  leading: Stack(
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(
                                            userProvider.getUser.profilePhoto),
                                      ),
                                    ],
                                  ),
                                  title: Text("Your Status",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline1),
                                  trailing: IconButton(
                                    onPressed: () async {
                                      UserData newUser = userProvider.getUser;
                                      newUser.hasStatus = false;
                                      if (docList.length == 1)
                                        _userCollection
                                            .doc(userProvider.getUser.uid)
                                            .set(newUser.toMap(newUser));
                                      String url = docList[0]['url'];
                                      docList[0].reference.delete();
                                      if (url != null) {
                                        StorageReference storageReference =
                                            await FirebaseStorage.instance
                                                .getReferenceFromUrl(url);
                                        // print(url);

                                        await storageReference
                                            .delete()
                                            .then((value) => print('deleted'));
                                      }
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                ),
                              ),
                            ),
                          );
                          
                        }
                        }
                        return Container();
                      }),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Status",
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        _authMethods.getFriends(uid: userProvider.getUser.uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var docList = snapshot.data.docs;

                        if (docList.isEmpty) {
                          return QuietBox(
                            heading: "Friends status will be shown here",
                            subtitle: "",
                          );
                        }
                        return Expanded(
                          child: Container(
                            padding: EdgeInsets.all(2.0),
                            child: ListView.builder(
                              padding: EdgeInsets.all(4.0),
                              itemCount: docList.length,
                              itemBuilder: (context, i) {
                                Contact user =
                                    Contact.fromMap(docList[i].data());
                                                         
                                return statusView(user);
                              },
                            ),
                          ),
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<UserData> hasStatus(String uid) async {
    // DocumentSnapshot s = await _userCollection.doc(uid).get();
    // UserData u = UserData.fromMap(s.data());
    // return u.hasStatus;
    UserData user = await _authMethods.getUserDetailsById(uid);
    return user;
  }

  Future<QuerySnapshot> getStatus(String uid) async {
    return await _userCollection.doc(uid).collection(STATUS).get();
  }

  Future pickImage({@required ImageSource source, String userId}) async {
    File selectedImage = await Utils.pickImage(source: source);
    if (selectedImage != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: selectedImage.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 80,
          maxHeight: 700,
          maxWidth: 700,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Theme.of(context).backgroundColor,
            toolbarTitle: "Edit Image",
            // statusBarColor: Theme.of(context).backgroundColor,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: Colors.teal,
            toolbarWidgetColor: Theme.of(context).iconTheme.color,
          ));
      _storageMethods.uploadStatus(
        image: cropped,
        uploader: userId,
      );
    }
    UserData newUser = userProvider.getUser;
    newUser.hasStatus = true;
    _userCollection.doc(userProvider.getUser.uid).set(newUser.toMap(newUser));
  }
}
