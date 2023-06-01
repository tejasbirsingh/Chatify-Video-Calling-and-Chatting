import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chatify/models/userData.dart';
import 'package:chatify/provider/audio_upload_provider.dart';
import 'package:chatify/provider/file_provider.dart';
import 'package:chatify/provider/image_upload_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatify/provider/video_upload_provider.dart';
import 'package:chatify/resources/chat_methods.dart';

class StorageMethods {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  var _storageReference;
  UserData user = UserData();
  final ChatMethods chatMethods = ChatMethods();

  Future<String> uploadImageToStorage(final File imageFile) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      final mountainsRef = _storageReference.child("mountains.jpg");
      await mountainsRef.putFile(imageFile);
      // var storageUploadTask = _storageReference.putFile(imageFile);
      var url = await (await mountainsRef.onComplete).ref.getDownloadURL();
      return url;
    } catch (e) {
      return "error";
    }
  }

  Future<String?> uploadVideoToStorage(final File videoFile) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      var storageUploadTask = _storageReference.putFile(videoFile);
      //      var storageUploadTask = _storageReference.putFile(
      // videoFile, StorageMetadata(contentType: 'video/mp4'));
      var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();

      print('This is video url = {$url}');
      return url;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadAudioMessage(final File audioFile) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      var storageUploadTask = _storageReference.putFile(audioFile);
      var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
      print("Audio file url - " + url);
      return url;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadFileMessage(final File file) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      // var storageUploadTask = _storageReference.putFile(
      //     file, StorageMetadata(contentType: 'file/pdf'));
      var storageUploadTask = _storageReference.putFile(file);
      var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();

      return url;
    } catch (e) {
      return null;
    }
  }

  void uploadImage({
    required final File image,
    required final String receiverId,
    required final String senderId,
    required final ImageUploadProvider imageUploadProvider,
  }) async {
    imageUploadProvider.setToLoading();
    final String url = await uploadImageToStorage(image);
    imageUploadProvider.setToIdle();
    chatMethods.setImageMsg(url, receiverId, senderId);
  }

  void uploadAudio({
    required final File audio,
    required final String receiverId,
    required final String senderId,
    required final AudioUploadProvider audioUploadProvider,
  }) async {
    audioUploadProvider.setToLoading();
    final String? url = await uploadAudioMessage(audio);
    audioUploadProvider.setToIdle();
    chatMethods.setAudioMsg(url, receiverId, senderId);
  }

  void uploadFile({
    required final File file,
    required final String receiverId,
    required final String senderId,
    required final FileUploadProvider fileUploadProvider,
  }) async {
    fileUploadProvider.setToLoading();
    final String? url = await uploadFileMessage(file);
    fileUploadProvider.setToIdle();
    chatMethods.setFileMsg(url, receiverId, senderId);
  }

  void uploadVideo({
    required final File video,
    required final String receiverId,
    required final String senderId,
    required final VideoUploadProvider videoUploadProvider,
  }) async {
    videoUploadProvider.setToLoading();
    final String? url = await uploadVideoToStorage(video);
    videoUploadProvider.setToIdle();
    chatMethods.setVideoMsg(url, receiverId, senderId);
  }

  void uploadStatus({
    required final File image,
    required final String uploader,
  }) async {
    final String url = await uploadImageToStorage(image);

    chatMethods.addStatus(url, uploader);
  }
}
