import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:skype_clone/models/userData.dart';
import 'package:skype_clone/provider/audio_upload_provider.dart';
import 'package:skype_clone/provider/file_provider.dart';
import 'package:skype_clone/provider/image_upload_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skype_clone/provider/video_upload_provider.dart';
import 'package:skype_clone/resources/chat_methods.dart';

class StorageMethods {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StorageReference _storageReference;

  //user class
  UserData user = UserData();

  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      StorageUploadTask storageUploadTask =
          _storageReference.putFile(imageFile);
      var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();

      // print(url);
      return url;
    } catch (e) {
      return null;
    }
  }

  Future<String> uploadVideoToStorage(File videoFile) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      StorageUploadTask storageUploadTask = _storageReference.putFile(
          videoFile, StorageMetadata(contentType: 'video/mp4'));
      var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();

      print('This is video url = {$url}');
      return url;
    } catch (e) {
      return null;
    }
  }

  Future<String> uploadAudioMessage(File audioFile) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      StorageUploadTask storageUploadTask = _storageReference.putFile(
          audioFile, StorageMetadata(contentType: 'audio/mp3'));
      var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();

      // print('This is audio message url = {$url}');
      return url;
    } catch (e) {
      return null;
    }
  }
  Future<String> uploadFileMessage(File file) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      StorageUploadTask storageUploadTask = _storageReference.putFile(
          file, StorageMetadata(contentType: 'file/pdf'));
      var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();

      return url;
    } catch (e) {
      return null;
    }
  }

  void uploadImage({
    @required File image,
    @required String receiverId,
    @required String senderId,
    @required ImageUploadProvider imageUploadProvider,
  }) async {
    final ChatMethods chatMethods = ChatMethods();

    imageUploadProvider.setToLoading();

    String url = await uploadImageToStorage(image);

    imageUploadProvider.setToIdle();

    chatMethods.setImageMsg(url, receiverId, senderId);
  }

  void uploadAudio({
    @required File audio,
    @required String receiverId,
    @required String senderId,
    @required AudioUploadProvider audioUploadProvider,
  }) async {
    final ChatMethods chatMethods = ChatMethods();

    audioUploadProvider.setToLoading();
    String url = await uploadAudioMessage(audio);
    audioUploadProvider.setToIdle();
    chatMethods.setAudioMsg(url, receiverId, senderId);
  }
   void uploadFile({
    @required File file,
    @required String receiverId,
    @required String senderId,
    @required FileUploadProvider fileUploadProvider,
  }) async {
    final ChatMethods chatMethods = ChatMethods();

    fileUploadProvider.setToLoading();
    String url = await uploadFileMessage(file);
    fileUploadProvider.setToIdle();
    chatMethods.setFileMsg(url, receiverId, senderId);
  }

  void uploadVideo({
    @required File video,
    @required String receiverId,
    @required String senderId,
    @required VideoUploadProvider videoUploadProvider,
  }) async {
    final ChatMethods chatMethods = ChatMethods();
    videoUploadProvider.setToLoading();
    String url = await uploadVideoToStorage(video);
    videoUploadProvider.setToIdle();
    chatMethods.setVideoMsg(url, receiverId, senderId);
  }
}
