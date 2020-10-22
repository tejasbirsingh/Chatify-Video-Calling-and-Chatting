import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  forwardPage({@required this.message,@required this.imagePath});
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
          
          title: Text(
            'Forward Message',
            style: Theme.of(context).textTheme.headline1,
          ),
          actions: [
          ],
        );
    return Scaffold(
 
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: skypeAppBar,
        body: StreamBuilder<QuerySnapshot>(
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
                  return forwardView(contact:user,
                  forwardedMessage: widget.message,
                  imagePath: widget.imagePath,);
                },
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }

  Future<UserData> mapUserDataFromUid(String uid) async {
    UserData user = await _auth.getUserDetailsById(uid);
    return user;
  }
}