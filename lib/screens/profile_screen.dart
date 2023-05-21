import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:chatify/constants/strings.dart';
import 'package:chatify/models/message.dart';
import 'package:chatify/models/userData.dart';
import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/resources/chat_methods.dart';

class ProfilePage extends StatefulWidget {
  final UserData user;
  const ProfilePage({Key? key, required this.user}) : super(key: key);
  @override
  _profilePageState createState() => _profilePageState();
}

class _profilePageState extends State<ProfilePage> {
  late String currUserId;
  bool _first = true;
  final ChatMethods _chatMethods = ChatMethods();
  double _fontSize = 60;
  Color _color = Colors.green;
  FontWeight _weight = FontWeight.normal;

  @override
  void initState() {
    super.initState();
    textAnimation();
  }

  textAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _fontSize = _first ? 30 : 50;
        _color = _first ? Colors.white : Colors.white;
        _first = !_first;
        _weight = _first ? FontWeight.normal : FontWeight.bold;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    currUserId = userProvider.getUser.uid!;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: NestedScrollView(
          dragStartBehavior: DragStartBehavior.start,
          headerSliverBuilder: (BuildContext context, bool innerBox) {
            return <Widget>[
              SliverAppBar(
                  collapsedHeight: MediaQuery.of(context).size.height * 0.15,
                  expandedHeight: MediaQuery.of(context).size.height * 0.40,
                  floating: true,
                  centerTitle: false,
                  pinned: true,
                  stretch: false,
                  title: AnimatedDefaultTextStyle(
                    curve: Curves.linear,
                    duration: Duration(milliseconds: 300),
                    style: GoogleFonts.patuaOne(
                      textStyle: TextStyle(
                          letterSpacing: 1.0,
                          fontSize: _fontSize,
                          color: _color,
                          fontWeight: _weight),
                    ),
                    child: Text(
                      widget.user.name!,
                    ),
                  ),
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                          child: Image.network(
                        widget.user.profilePhoto!,
                        fit: BoxFit.cover,
                      )),
                    ],
                  ))
            ];
          },
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                userProvider.getUser.firstColor != null
                    ? Color(
                        userProvider.getUser.firstColor ?? Colors.white.value)
                    : Theme.of(context).colorScheme.background,
                userProvider.getUser.secondColor != null
                    ? Color(
                        userProvider.getUser.secondColor ?? Colors.white.value)
                    : Theme.of(context).scaffoldBackgroundColor,
              ]),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.0),
              child: SizedBox(
                child: ListView(
                  children: [
                    SizedBox(
                      height: 10.0,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.email_outlined,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      title: Text(
                        Strings.email,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: Text(widget.user.email!,
                          style: Theme.of(context).textTheme.displayLarge),
                    ),
                    Divider(
                      thickness: 1.0,
                      color: Theme.of(context).dividerColor,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.info_outline_rounded,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      title: Text(
                        Strings.status,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: Text(widget.user.status ?? Strings.noStatus,
                          style: Theme.of(context).textTheme.displayLarge),
                    ),
                    Divider(
                      thickness: 1.0,
                      color: Theme.of(context).dividerColor,
                    ),
                    FutureBuilder(
                      future: _chatMethods.isBlocked(
                          userProvider.getUser.uid, widget.user.uid),
                      builder: (context, AsyncSnapshot<bool> snapshot) =>
                          ListTile(
                        leading: Icon(
                          Icons.info_outline_rounded,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        title: Text(
                          snapshot.data == true
                              ? Strings.block
                              : Strings.unblock,
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        trailing: IconButton(
                          iconSize: 35.0,
                          icon: snapshot.data == true
                              ? Icon(
                                  Icons.block,
                                  color: Colors.red,
                                )
                              : Icon(
                                  Icons.block_flipped,
                                  color: Colors.green,
                                ),
                          onPressed: () {
                            _chatMethods.addToBlockedList(
                                senderId: userProvider.getUser.uid,
                                receiverId: widget.user.uid);
                          },
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1.0,
                      color: Theme.of(context).dividerColor,
                    ),
                    FutureBuilder(
                      future: _chatMethods.isMuted(
                          userProvider.getUser.uid!, widget.user.uid!),
                      builder: (context, AsyncSnapshot<bool> snapshot) =>
                          ListTile(
                        leading: Icon(
                          Icons.info_outline_rounded,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        title: Text(
                          snapshot.data == false
                              ? Strings.mute
                              : Strings.unMute,
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        trailing: IconButton(
                          iconSize: 35.0,
                          icon: snapshot.data == false
                              ? Icon(
                                  Icons.volume_mute,
                                  color: Colors.red,
                                )
                              : Icon(
                                  FontAwesomeIcons.volumeHigh,
                                  color: Colors.green,
                                ),
                          onPressed: () {
                            _chatMethods.addToMutedList(
                                senderId: userProvider.getUser.uid,
                                receiverId: widget.user.uid);
                          },
                        ),
                      ),
                    ),
                    messageList()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget messageList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(currUserId)
          .collection(widget.user.uid!)
          .orderBy(TIMESTAMP_FIELD, descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: ListView.builder(
            padding: EdgeInsets.all(10),
            reverse: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Message message = Message.fromMap(
                  snapshot.data!.docs[index].data() as Map<String, dynamic>);
              return Container(child: Text(message.message!));
            },
          ),
        );
      },
    );
  }
}
