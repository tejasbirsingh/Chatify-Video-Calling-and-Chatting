import 'package:chatify/constants/constants.dart';

class Call {
  String? callerId;
  String? callerName;
  String? callerPic;
  String? receiverId;
  String? receiverName;
  String? receiverPic;
  String? channelId;
  bool? hasDialled;

  Call({
    this.callerId,
    this.callerName,
    this.callerPic,
    this.receiverId,
    this.receiverName,
    this.receiverPic,
    this.channelId,
    this.hasDialled,
  });

  // to map
  Map<String, dynamic> toMap(Call call) {
    Map<String, dynamic> callMap = Map();
    callMap[Constants.CALLER_ID] = call.callerId;
    callMap[Constants.CALLER_NAME] = call.callerName;
    callMap[Constants.CALLER_PIC] = call.callerPic;
    callMap[Constants.CALL_RECEIVER_ID] = call.receiverId;
    callMap[Constants.RECEIVER_NAME] = call.receiverName;
    callMap[Constants.RECEIVER_PIC] = call.receiverPic;
    callMap[Constants.CHANNEL_ID] = call.channelId;
    callMap[Constants.HAS_DIALLED] = call.hasDialled;
    return callMap;
  }

  Call.fromMap(Map callMap) {
    this.callerId = callMap[Constants.CALLER_ID];
    this.callerName = callMap[Constants.CALLER_NAME];
    this.callerPic = callMap[Constants.CALLER_PIC];
    this.receiverId = callMap[Constants.CALL_RECEIVER_ID];
    this.receiverName = callMap[Constants.RECEIVER_NAME];
    this.receiverPic = callMap[Constants.RECEIVER_PIC];
    this.channelId = callMap[Constants.CHANNEL_ID];
    this.hasDialled = callMap[Constants.HAS_DIALLED];
  }
}
