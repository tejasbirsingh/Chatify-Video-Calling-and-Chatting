import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skype_clone/encryption/encryptText.dart';

class Message {
  String senderId;
  String receiverId;
  String type;
  String message;
  String status;

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
    this.status,
  });

  Message.imageMessage({
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.photoUrl,
     this.status,
  });

  Message.videoMessage({
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.videoUrl,
     this.status,
  });
  Message.audioMessage({
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.audioUrl,
     this.status,
  });
  Message.fileMessage({
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.fileUrl,
     this.status,
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
    map['status'] = this.status;
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
    map['status'] = this.status;
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
    map['status'] = this.status;
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
    map['status'] = this.status;
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
    map['status'] = this.status;
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
    this.status = map['status'];
  }
}
