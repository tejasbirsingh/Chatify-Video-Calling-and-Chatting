import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:skype_clone/models/contact.dart';
import 'package:skype_clone/models/userData.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';

import 'package:skype_clone/screens/pageviews/friends/widgets/friend_view.dart';
import 'package:skype_clone/screens/pageviews/friends/widgets/quite_box.dart';

import 'package:skype_clone/widgets/skype_appbar.dart';

class contactsPage extends StatefulWidget {
  @override
  _contactsPageState createState() => _contactsPageState();
}

class _contactsPageState extends State<contactsPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final AuthMethods _auth = AuthMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);

    return Scaffold(
        appBar: SkypeAppBar(
          leading: Text(""),
          title: 'Contacts',
          actions: [
            IconButton(
              icon: Icon(
                FontAwesomeIcons.sliders,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/setting_page");
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              userProvider.getUser.firstColor != null
                  ? Color(userProvider.getUser.firstColor ?? Colors.white.value)
                  : Theme.of(context).colorScheme.background,
              userProvider.getUser.secondColor != null
                  ? Color(
                      userProvider.getUser.secondColor ?? Colors.white.value)
                  : Theme.of(context).scaffoldBackgroundColor,
            ]),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: _auth.getFriends(uid: userProvider.getUser.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var docList = snapshot.data!.docs;

                if (docList.isEmpty) {
                  return QuietBox(
                    heading: "All your contacts will be shown here",
                    subtitle:
                        "Search your friends, add them and start chatting !",
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemCount: docList.length,
                  itemBuilder: (context, i) {
                    Contact user = Contact.fromMap(
                        docList[i].data() as Map<String, dynamic>);
                    return friendView(user);
                  },
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ));
  }

  Future<UserData> mapUserDataFromUid(String uid) async {
    UserData? user = await _auth.getUserDetailsById(uid);
    return user!;
  }
}
