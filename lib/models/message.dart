import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:skype_clone/encryption/encryptText.dart';

class Message {
  String senderId;
  String receiverId;
  String type;
  String message;
  bool isRead;
  bool isLocation;
  GeoPoint position;


  Timestamp timestamp;
  String photoUrl;
  String videoUrl;
  String audioUrl;
  String fileUrl;

  Message({
    this.senderId,
    this.receiverId,
    this.type,
    this.message,
    this.timestamp,
    this.isRead,
    this.isLocation,
    this.position
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

  Map toMap() {
    var encryptedText = encryptAESCryptoJS(this.message, "password");
    // print(encryptedText);
    // var decrypted = decryptAESCryptoJS("U2FsdGVkX18kywp91Ikacgub10Cw94ZytfYUrsevhYQ=","password");
    // print(decrypted);
    var map = Map<String, dynamic>();
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['message'] = encryptedText;
    map['timestamp'] = this.timestamp;
    map['isRead'] = this.isRead;
    map["isLocation"] = this.isLocation;
    map["position"] = this.position;
    return map;
  }

  Map toImageMap() {
    var map = Map<String, dynamic>();
    map['message'] = this.message;
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['timestamp'] = this.timestamp;
    map['photoUrl'] = this.photoUrl;
    map['isRead'] = this.isRead;
    return map;
  }

  Map toVideoMap() {
    var map = Map<String, dynamic>();
    map['message'] = this.message;
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['timestamp'] = this.timestamp;
    map['videoUrl'] = this.videoUrl;
    map['isRead'] = this.isRead;
    return map;
  }

  Map toAudioMap() {
    var map = Map<String, dynamic>();
    map['message'] = this.message;
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['timestamp'] = this.timestamp;
    map['audioUrl'] = this.audioUrl;
    map['isRead'] = this.isRead;
    return map;
  }

  Map tofileMap() {
    var map = Map<String, dynamic>();
    map['message'] = this.message;
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['timestamp'] = this.timestamp;
    map['fileUrl'] = this.fileUrl;
    map['isRead'] = this.isRead;
    return map;
  }

  // named constructor
  Message.fromMap(Map<String, dynamic> map) {
    var decryptedMessage;
    // if message is of type text then only we need to enrpyt it other wise we can simply assign it to message
    if (map['message'] != 'IMAGE' &&
        map['message'] != 'VIDEO' &&
        map["message"] != 'AUDIO' &&
        map['message'] != 'FILE')
      decryptedMessage = decryptAESCryptoJS(map['message'], "password");
    else
      decryptedMessage = map['message'];
    this.senderId = map['senderId'];
    this.receiverId = map['receiverId'];
    this.type = map['type'];
    this.message = decryptedMessage;
    this.timestamp = map['timestamp'];
    this.photoUrl = map['photoUrl'];
    this.videoUrl = map['videoUrl'];
    this.audioUrl = map['audioUrl'];
    this.fileUrl = map['fileUrl'];
    this.isRead = map['isRead'];
    this.isLocation=map["isLocation"];
    this.position =map["position"];
  }
}
