import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skype_clone/models/contact.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/chat_methods.dart';
import 'package:skype_clone/screens/callscreens/pickup/pickup_layout.dart';
import 'package:skype_clone/screens/pageviews/chats/widgets/contact_view.dart';
import 'package:skype_clone/screens/pageviews/chats/widgets/quiet_box.dart';
import 'package:skype_clone/screens/pageviews/chats/widgets/user_circle.dart';

import 'package:skype_clone/widgets/skype_appbar.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
  
    return PickupLayout(
      scaffold: Scaffold(
        appBar: SkypeAppBar(
          title: 'Chats',
          leading: UserCircle(),
          actions: <Widget>[
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
        body: ChatListContainer()
      ),
    );
  }
}

class ChatListContainer extends StatefulWidget {
  @override
  _ChatListContainerState createState() => _ChatListContainerState();
}

class _ChatListContainerState extends State<ChatListContainer> {
  final ChatMethods _chatMethods = ChatMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    userProvider.refreshUser();
    return Container(
      decoration: BoxDecoration(
        
        gradient: LinearGradient(colors: [
          userProvider.getUser.firstColor != null
              ? Color(userProvider.getUser.firstColor ?? Colors.white.value)
              : Theme.of(context).colorScheme.background,
          userProvider.getUser.secondColor != null
              ? Color(userProvider.getUser.secondColor ?? Colors.white.value)
              : Theme.of(context).scaffoldBackgroundColor,
        ]),
      ),
      child: StreamBuilder<QuerySnapshot>(
          stream: _chatMethods.fetchContacts(
            userId: userProvider.getUser.uid,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<QueryDocumentSnapshot<Object?>> docList = snapshot.data!.docs;

              if (docList.isEmpty) {
                return QuietBox(
                  heading: "All recent chats with friends will be shown here",
                  subtitle:
                      "Search your friends, add them and start chatting !",
                );
              }
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: docList.length,
                  itemBuilder: (context, index) {
                    Contact contact = Contact.fromMap(docList[index].data() as Map<String, dynamic>);
                    return ContactView(contact, userProvider.getUser.uid!);
                  },
                ),
              );
            }

            return Center(
              child: Container(),
            );
          }),
    );
  }
}
