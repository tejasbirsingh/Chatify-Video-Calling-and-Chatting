import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:chatify/constants/navigation_routes_constants.dart';
import 'package:chatify/constants/strings.dart';
import 'package:chatify/models/contact.dart';
import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/resources/chat_methods.dart';
import 'package:chatify/screens/callscreens/pickup/pickup_layout.dart';
import 'package:chatify/screens/pageviews/chats/widgets/contact_view.dart';
import 'package:chatify/screens/pageviews/chats/widgets/quiet_box.dart';
import 'package:chatify/screens/pageviews/chats/widgets/user_circle.dart';
import 'package:chatify/widgets/skype_appbar.dart';

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
            title: Strings.chats,
            leading: UserCircle(),
            actions: <Widget>[
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
          body: ChatListContainer()),
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
              List<QueryDocumentSnapshot<Object?>> docList =
                  snapshot.data!.docs;

              if (docList.isEmpty) {
                return QuietBox(
                  heading: Strings.recentChatsTileHeading,
                  subtitle: Strings.recentChatsSubHeading,
                );
              }
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: docList.length,
                  itemBuilder: (context, index) {
                    Contact contact = Contact.fromMap(
                        docList[index].data() as Map<String, dynamic>);
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
