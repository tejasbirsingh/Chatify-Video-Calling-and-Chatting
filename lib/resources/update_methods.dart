import 'dart:io';
import 'package:chatify/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chatify/constants/strings.dart';

class UpdateMethods {
  final String? uid;
  UpdateMethods({this.uid});

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updatePhoto(final String photoUrl, final String uid) async {
    return await _firestore
        .collection(USERS_COLLECTION)
        .doc(uid)
        .update({Constants.PROFILE_PHOTO: photoUrl});
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      var storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      var uploadTask = storageReference.putFile(imageFile);
      var snapshot = await uploadTask;
      var url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      print(e.toString());
      return "error";
    }
  }
}
