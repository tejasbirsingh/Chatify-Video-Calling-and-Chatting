import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:skype_clone/constants/strings.dart';
import 'package:skype_clone/models/contact.dart';

import 'package:skype_clone/screens/pageviews/chats/widgets/quiet_box.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';

class StatusPage extends StatefulWidget {
  final Contact? contact;

  const StatusPage({Key? key, this.contact}) : super(key: key);
  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final storyController = StoryController();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);
  List<StoryItem> stories = [];
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
                .doc(widget.contact!.uid)
                .collection(STATUS)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var docList = snapshot.data!.docs;

                if (docList.isEmpty) {
                  return QuietBox(
                    heading: "Status will be shown here",
                    subtitle:                        "",
                  );
                }
                docList.reversed;
                docList.forEach((element) {
                  stories.add(StoryItem.pageImage(
                    
                    imageFit: BoxFit.scaleDown,
                    caption:
                        (formatTime(element['timestamp'].toDate()))
                        .toString(),
                    url: element['url'],
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
              return QuietBox(
                heading: "Status will be shown here",
                subtitle: "",
              );
           
            }
            ),
      ),
    );
  }
}
