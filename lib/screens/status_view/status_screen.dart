import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:skype_clone/constants/strings.dart';
import 'package:skype_clone/models/contact.dart';
import 'package:skype_clone/resources/auth_methods.dart';
import 'package:skype_clone/screens/pageviews/chats/widgets/quiet_box.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';

class statusPage extends StatefulWidget {
  final Contact contact;

  const statusPage({Key key, this.contact}) : super(key: key);
  @override
  _statusPageState createState() => _statusPageState();
}

class _statusPageState extends State<statusPage> {
  final storyController = StoryController();
  final AuthMethods _authMethods = AuthMethods();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);
  List<StoryItem> stories = List();
  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  formatTime(DateTime time) {
    String date = (time.hour > 12 ? time.hour - 12 : time.hour).toString() +
        ":" +
        (time.minute.toString().length == 1
            ? "0" + time.minute.toString()
            : time.minute.toString()) +
        " " +
        (time.hour < 12 ? "am" : "pm").toString();

    return date;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
            stream: _userCollection
                .doc(widget.contact.uid)
                .collection(STATUS)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var docList = snapshot.data.docs;

                if (docList.isEmpty) {
                  return QuietBox(
                    heading: "All your contacts will be shown here",
                    subtitle:
                        "Search your friends, add them and start chatting !",
                  );
                }
                docList.reversed;
                docList.forEach((element) {
                  stories.add(StoryItem.pageImage(
                    
                    imageFit: BoxFit.scaleDown,
                    caption: (formatTime(element.data()['timestamp'].toDate()))
                        .toString(),
                    url: element.data()['url'],
                    controller: storyController,
                  )); 
                });

                return Stack(
                  children: [
                 
                    StoryView(
                      storyItems: stories,
                      onStoryShow: (s) {
                        print("Showing a story");
                      },
                      onComplete: () {
                        Navigator.pop(context);
                      },
                      progressPosition: ProgressPosition.top,
                      repeat: false,
                      controller: storyController,
                    ),
                  ],
                );
              }
            }),
      ),
    );
  }
}
