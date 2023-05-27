import 'package:chatify/constants/constants.dart';

class Log {
  int? logId;
  String? callerName;
  String? callerPic;
  String? receiverName;
  String? receiverPic;
  String? callStatus;
  String? timestamp;

  Log({
    this.logId,
    this.callerName,
    this.callerPic,
    this.receiverName,
    this.receiverPic,
    this.callStatus,
    this.timestamp,
  });

  // to map
  Map<String, dynamic> toMap(Log log) {
    Map<String, dynamic> logMap = Map();
    logMap[Constants.LOG_ID] = log.logId;
    logMap[Constants.CALLER_NAME] = log.callerName;
    logMap[Constants.CALLER_PIC] = log.callerPic;
    logMap[Constants.RECEIVER_NAME] = log.receiverName;
    logMap[Constants.RECEIVER_PIC] = log.receiverPic;
    logMap[Constants.CALL_STATUS] = log.callStatus;
    logMap[Constants.TIMESTAMP] = log.timestamp;
    return logMap;
  }

  Log.fromMap(Map logMap) {
    this.logId = logMap[Constants.LOG_ID];
    this.callerName = logMap[Constants.CALLER_NAME];
    this.callerPic = logMap[Constants.CALLER_PIC];
    this.receiverName = logMap[Constants.RECEIVER_NAME];
    this.receiverPic = logMap[Constants.RECEIVER_PIC];
    this.callStatus = logMap[Constants.CALL_STATUS];
    this.timestamp = logMap[Constants.TIMESTAMP];
  }
}
