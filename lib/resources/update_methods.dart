import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:skype_clone/constants/strings.dart';



class UpdateMethods {
  final String? uid;
  UpdateMethods({this.uid});
  var _storageReference;
     

 static final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  Future<void> updatePhoto(String photoUrl, String uid) async {
    return await _firestore
        .collection(USERS_COLLECTION)
        .doc(uid)
        .update({'profile_photo': photoUrl});
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    try{   
        _storageReference = FirebaseStorage.instance
            .ref()
            .child('${DateTime.now().millisecondsSinceEpoch}');
        var storageUploadTask = _storageReference.putFile(imageFile);
        var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
        return url;
    }
    catch(e){
       return "error";
    }

  }
}