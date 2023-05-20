import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skype_clone/constants/strings.dart';
import 'package:skype_clone/models/call.dart';
import 'package:skype_clone/models/log.dart';
import 'package:skype_clone/models/message.dart';
import 'package:skype_clone/models/userData.dart';
import 'package:skype_clone/resources/call_methods.dart';
import 'package:skype_clone/resources/chat_methods.dart';
import 'package:skype_clone/resources/local_db/repository/log_repository.dart';
import 'package:skype_clone/screens/callscreens/call_screen.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({UserData? from, UserData? to, context}) async {
    ChatMethods _chatMethods = ChatMethods();
    Call call = Call(
      callerId: from!.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to!.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
    );
    
    Message _message = Message(
      receiverId: to.uid,
      senderId: from.uid,
      message: "DIALLED",
      timestamp: Timestamp.now(),
      type: 'Call',
    );

    Log log = Log(
      callerName: from.name,
      callerPic: from.profilePhoto,
      callStatus: CALL_STATUS_DIALLED,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      timestamp: DateTime.now().toString(),
    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      // enter log
      LogRepository.addLogs(log);
      _chatMethods.addMessageToDb(_message);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(call: call),
        ),
      );
    }
  }
}
