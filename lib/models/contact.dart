import 'package:chatify/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Contact  {
  String? uid;
  Timestamp? addedOn;
  

  Contact({
    this.uid,
    this.addedOn,
  });

  Map toMap(Contact contact) {
    var data = Map<String, dynamic>();
    data[Constants.CONTACT_ID] = contact.uid;
    data[Constants.ADDED_ON] = contact.addedOn;
    return data;
  }

  Contact.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData[Constants.CONTACT_ID];
    this.addedOn = mapData[Constants.ADDED_ON];
  }
}
