import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:skype_clone/models/contact.dart';
import 'package:skype_clone/models/userData.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';

import 'package:skype_clone/screens/pageviews/friends/widgets/friend_view.dart';

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
        // backgroundColor: UniversalVariables.blackColor,
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: SkypeAppBar(
          
          title: Text(
            'Contacts',
            style: Theme.of(context).textTheme.headline1,
          ),
          actions: [
            IconButton(icon: Icon(Icons.list,
            color: Theme.of(context).iconTheme.color,), 
            onPressed: () {})],
        ),
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
                  return friendView(user);
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
