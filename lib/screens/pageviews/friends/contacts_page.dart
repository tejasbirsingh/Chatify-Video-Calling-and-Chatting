import 'package:chatify/constants/navigation_routes_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:chatify/models/contact.dart';
import 'package:chatify/models/userData.dart';
import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/resources/auth_methods.dart';
import 'package:chatify/screens/pageviews/friends/widgets/friend_view.dart';
import 'package:chatify/screens/pageviews/friends/widgets/quite_box.dart';
import 'package:chatify/widgets/chatify_app_bar.dart';
import '../../../constants/strings.dart';

class ContactsPage extends StatefulWidget {
  @override
  _contactsPageState createState() => _contactsPageState();
}

class _contactsPageState extends State<ContactsPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final AuthMethods _auth = AuthMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);

    return Scaffold(
        appBar: ChatifyAppBar(
          leading: Text(""),
          title: Strings.contacts,
          actions: [
            IconButton(
              icon: Icon(
                FontAwesomeIcons.sliders,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                Navigator.pushNamed(
                    context, NavigationRoutesConstants.SETTINGS_PAGE_ROUTE);
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
                    heading: Strings.allContactsShownHere,
                    subtitle: Strings.searchFriendsHere,
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemCount: docList.length,
                  itemBuilder: (context, i) {
                    Contact user = Contact.fromMap(
                        docList[i].data() as Map<String, dynamic>);
                    return FriendView(user);
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
