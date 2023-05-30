import 'package:chatify/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatify/encryption/encryptText.dart';

class Message {
  String? senderId;
  String? receiverId;
  String? type;
  String? message;
  bool? isRead;
  bool? isLocation;
  GeoPoint? position;
  Timestamp? timestamp;
  String? photoUrl;
  String? videoUrl;
  String? audioUrl;
  String? fileUrl;
  Message? replyMessage;

  Message({
    this.senderId,
    this.receiverId,
    this.type,
    this.message,
    this.timestamp,
    this.isRead,
    this.isLocation,
    this.position,
    this.replyMessage,
  });

  Message.imageMessage({
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.photoUrl,
    this.isRead,
  });

  Message.videoMessage({
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.videoUrl,
    this.isRead,
  });

  Message.audioMessage({
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.audioUrl,
    this.isRead,
  });

  Message.fileMessage({
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.fileUrl,
    this.isRead,
  });

  Map<String, dynamic> toMap() {
    var encryptedText = encryptAESCryptoJS(this.message!, Constants.PASSWORD);
    var map = <String, dynamic>{};
    map[Constants.SENDER_ID] = this.senderId;
    map[Constants.RECEIVER_ID] = this.receiverId;
    map[Constants.TYPE] = this.type;
    map[Constants.MESSAGE] = encryptedText;
    map[Constants.TIMESTAMP] = this.timestamp;
    map[Constants.IS_READ] = this.isRead;
    map[Constants.IS_LOCATION] = this.isLocation;
    map[Constants.POSITION] = this.position;
    map[Constants.REPLY] =
        this.replyMessage == null ? null : this.replyMessage!.toMap();
    return map;
  }

  Map<String, dynamic> toImageMap() {
    var map = <String, dynamic>{};
    map[Constants.MESSAGE] = this.message;
    map[Constants.SENDER_ID] = this.senderId;
    map[Constants.RECEIVER_ID] = this.receiverId;
    map[Constants.TYPE] = this.type;
    map[Constants.TIMESTAMP] = this.timestamp;
    map[Constants.PHOTO_URL] = this.photoUrl;
    map[Constants.IS_READ] = this.isRead;
    return map;
  }

  Map<String, dynamic> toVideoMap() {
    var map = <String, dynamic>{};
    map[Constants.MESSAGE] = this.message;
    map[Constants.SENDER_ID] = this.senderId;
    map[Constants.RECEIVER_ID] = this.receiverId;
    map[Constants.TYPE] = this.type;
    map[Constants.TIMESTAMP] = this.timestamp;
    map[Constants.VIDEO_URL] = this.videoUrl;
    map[Constants.IS_READ] = this.isRead;
    return map;
  }

  Map<String, dynamic> toAudioMap() {
    var map = <String, dynamic>{};
    map[Constants.MESSAGE] = this.message;
    map[Constants.SENDER_ID] = this.senderId;
    map[Constants.RECEIVER_ID] = this.receiverId;
    map[Constants.TYPE] = this.type;
    map[Constants.TIMESTAMP] = this.timestamp;
    map[Constants.AUDIO_URL] = this.audioUrl;
    map[Constants.IS_READ] = this.isRead;
    return map;
  }

  Map<String, dynamic> tofileMap() {
    var map = <String, dynamic>{};
    map[Constants.MESSAGE] = this.message;
    map[Constants.SENDER_ID] = this.senderId;
    map[Constants.RECEIVER_ID] = this.receiverId;
    map[Constants.TYPE] = this.type;
    map[Constants.TIMESTAMP] = this.timestamp;
    map[Constants.FILE_URL] = this.fileUrl;
    map[Constants.IS_READ] = this.isRead;
    return map;
  }

  Message.fromMap(Map<String, dynamic> map) {
    var decryptedMessage;
    if (map[Constants.TYPE] == Constants.TEXT)
      decryptedMessage =
          decryptAESCryptoJS(map[Constants.MESSAGE], Constants.PASSWORD);
    else
      decryptedMessage = map[Constants.MESSAGE];
    this.senderId = map[Constants.SENDER_ID];
    this.receiverId = map[Constants.RECEIVER_ID];
    this.type = map[Constants.TYPE];
    this.message = decryptedMessage;
    this.timestamp = map[Constants.TIMESTAMP];
    this.photoUrl = map[Constants.PHOTO_URL];
    this.videoUrl = map[Constants.VIDEO_URL];
    this.audioUrl = map[Constants.AUDIO_URL];
    this.fileUrl = map[Constants.FILE_URL];
    this.isRead = map[Constants.IS_READ];
    this.isLocation = map[Constants.IS_LOCATION];
    this.position = map[Constants.POSITION];
    this.replyMessage = map[Constants.REPLY] == null
        ? null
        : Message.fromMap(map[Constants.REPLY]);
  }
}
