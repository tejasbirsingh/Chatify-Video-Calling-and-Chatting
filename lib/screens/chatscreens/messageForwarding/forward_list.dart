import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skype_clone/models/contact.dart';
import 'package:skype_clone/models/userData.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';
import 'package:skype_clone/screens/chatscreens/messageForwarding/forward_view.dart';

import 'package:skype_clone/widgets/skype_appbar.dart';

class forwardPage extends StatefulWidget {
  final String message;
  final String imagePath;
  forwardPage({@required this.message, @required this.imagePath});
  @override
  _forwardPageState createState() => _forwardPageState();
}

class _forwardPageState extends State<forwardPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final AuthMethods _auth = AuthMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);

    var skypeAppBar = SkypeAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (context) {
          Navigator.pop(context);
        })),
      ),
      title: Text(
        'Forward Message',
        style: GoogleFonts.oswald(
            textStyle: Theme.of(context).textTheme.headline1, fontSize: 26.0),
      ),
      actions: [],
    );
    return SafeArea(
      child: Scaffold(
          appBar: skypeAppBar,
          body: Stack(
            children: [
              Container(
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
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _auth.getFriends(uid: userProvider.getUser.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var docList = snapshot.data.docs;
                    if (docList.isEmpty) return Container();

                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemCount: docList.length,
                      itemBuilder: (context, i) {
                        Contact user = Contact.fromMap(docList[i].data());
                        return forwardView(
                          contact: user,
                          forwardedMessage: widget.message,
                          imagePath: widget.imagePath,
                        );
                      },
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ],
          )),
    );
  }

  Future<UserData> mapUserDataFromUid(String uid) async {
    UserData user = await _auth.getUserDetailsById(uid);
    return user;
  }
}
