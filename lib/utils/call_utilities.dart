import 'dart:math';
import 'package:chatify/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatify/constants/strings.dart';
import 'package:chatify/models/call.dart';
import 'package:chatify/models/log.dart';
import 'package:chatify/models/message.dart';
import 'package:chatify/models/userData.dart';
import 'package:chatify/resources/call_methods.dart';
import 'package:chatify/resources/chat_methods.dart';
import 'package:chatify/resources/local_db/repository/log_repository.dart';
import 'package:chatify/screens/callscreens/call_screen.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({UserData? from, UserData? to, context}) async {
    final ChatMethods _chatMethods = ChatMethods();
    final Call call = Call(
      callerId: from!.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to!.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
    );

    final Message _message = Message(
      receiverId: to.uid,
      senderId: from.uid,
      message: Strings.dialled,
      timestamp: Timestamp.now(),
      type: Constants.MESSAGE_TYPE_CALL,
      isRead: true
    );

    final Log log = Log(
      callerName: from.name,
      callerPic: from.profilePhoto,
      callStatus: CALL_STATUS_DIALLED,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      timestamp: DateTime.now().toString(),
    );

    final bool callMade = await callMethods.makeCall(call: call);

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
