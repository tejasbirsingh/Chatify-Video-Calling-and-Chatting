import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatify/models/contact.dart';
import 'package:chatify/models/userData.dart';
import 'package:chatify/provider/image_upload_provider.dart';
import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/resources/auth_methods.dart';
import 'package:chatify/resources/chat_methods.dart';
import 'package:chatify/resources/storage_methods.dart';
import 'package:chatify/screens/chatscreens/chat_screen.dart';
import 'package:chatify/screens/chatscreens/push_notification.dart';
import 'package:chatify/screens/chatscreens/widgets/cached_image.dart';
import 'package:chatify/screens/pageviews/chats/widgets/online_dot_indicator.dart';
import 'package:chatify/screens/pageviews/friends/widgets/friend_custom_tile.dart';
import '../../../constants/constants.dart';
import '../../../models/message.dart';

/*
  It handles forward message view.
*/
class ForwardView extends StatelessWidget {
  final Contact? contact;
  final forwardedMessage;
  final AuthMethods _authMethods = AuthMethods();
  final String? imagePath;

  ForwardView({this.contact, required this.forwardedMessage, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserData?>(
      future: _authMethods.getUserDetailsById(contact!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final UserData user = snapshot.data!;
          return ViewLayout(
            friendViewLayout: user,
            forwardedMessage: forwardedMessage,
            imagePath: imagePath,
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

/*
  It has the logic to forward a message.
*/
class ViewLayout extends StatelessWidget {
  final UserData friendViewLayout;
  final String forwardedMessage;
  final String? imagePath;
  final ChatMethods _chatMethods = ChatMethods();
  final StorageMethods _storageMethods = StorageMethods();

  ViewLayout(
      {required this.friendViewLayout,
      required this.forwardedMessage,
      this.imagePath});

  @override
  Widget build(BuildContext context) {
    final UserProvider user = Provider.of<UserProvider>(context, listen: true);
    final ImageUploadProvider _imageUploadProvider =
        Provider.of<ImageUploadProvider>(context);

    File? img;
    if (imagePath != null && imagePath != "") {
      img = File(imagePath!);
    }

    return FriendCustomTile(
      mini: false,
      onTap: () => _forwardMessage(img, user, _imageUploadProvider, context),
      title: Text(friendViewLayout.name ?? "..",
          style: Theme.of(context).textTheme.bodyLarge),
      trailing: Icon(
        Icons.reply,
        color: Colors.green,
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 80, maxWidth: 70),
        child: Stack(
          children: <Widget>[
            OnlineDotIndicator(
              uid: friendViewLayout.uid!,
            ),
            Center(
              child: CachedImage(
                friendViewLayout.profilePhoto!,
                radius: 60,
                isRound: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _forwardMessage(
      final File? img,
      final UserProvider user,
      final ImageUploadProvider _imageUploadProvider,
      final BuildContext context) {
    final Message _message = Message(
      receiverId: friendViewLayout.uid,
      senderId: user.getUser.uid,
      message: forwardedMessage,
      timestamp: Timestamp.now(),
      type: Constants.MESSAGE_TYPE_IMAGE,
    );
    if (img != null) {
      print("Image condition triggered -" + img.path);
      _storageMethods.uploadImage(
          image: img,
          receiverId: friendViewLayout.uid!,
          senderId: user.getUser.uid!,
          imageUploadProvider: _imageUploadProvider);
      _chatMethods.setImageMsg(
          imagePath!, friendViewLayout.uid!, user.getUser.uid!);
    } else {
      print("Message condition triggered -" + _message.toString());
      _chatMethods.addMessageToDb(_message);
    }
    sendNotification(forwardedMessage, user.getUser.name.toString(),
        friendViewLayout.firebaseToken.toString());
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            receiver: friendViewLayout,
          ),
        ));
  }
}
