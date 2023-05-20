import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:skype_clone/models/contact.dart';
import 'package:skype_clone/models/userData.dart';
import 'package:skype_clone/provider/image_upload_provider.dart';
import 'package:skype_clone/provider/user_provider.dart';

import 'package:skype_clone/resources/auth_methods.dart';
import 'package:skype_clone/resources/chat_methods.dart';
import 'package:skype_clone/resources/storage_methods.dart';

import 'package:skype_clone/screens/chatscreens/chat_screen.dart';
import 'package:skype_clone/screens/chatscreens/push_notification.dart';
import 'package:skype_clone/screens/chatscreens/widgets/cached_image.dart';

import 'package:skype_clone/screens/pageviews/chats/widgets/online_dot_indicator.dart';
import 'package:skype_clone/screens/pageviews/friends/widgets/friend_customTile.dart';

class forwardView extends StatelessWidget {
  final Contact? contact;
  final forwardedMessage;
  final AuthMethods _authMethods = AuthMethods();
  final String? imagePath;

  forwardView({this.contact, required this.forwardedMessage, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserData?>(
      future: _authMethods.getUserDetailsById(contact!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData user = snapshot.data!;

          return ViewLayout(
            friendViewLayout: user,
            forwardedMessage: forwardedMessage,
            imagePath: imagePath!,
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final UserData friendViewLayout;
  final String forwardedMessage;
  final String? imagePath;
  final ChatMethods _chatMethods = ChatMethods();
  final AuthMethods _authMethods = AuthMethods();
  final StorageMethods _storageMethods = StorageMethods();

  ViewLayout(
      {required this.friendViewLayout,
      required this.forwardedMessage,
      this.imagePath});

  @override
  Widget build(BuildContext context) {
    final UserProvider user = Provider.of<UserProvider>(context, listen: true);
    final ImageUploadProvider _imageUploadProvider =Provider.of<ImageUploadProvider>(context);
    // Message _message = Message(
    //   receiverId: friendViewLayout.uid,
    //   senderId: user.getUser.uid,
    //   message: forwardedMessage,
    //   timestamp: Timestamp.now(),
    //   type: 'text',
    // );
    File img = File(imagePath!);
    return FriendCustomTile(
      mini: false,
      onTap: () {

        if (img != File("")) {
        
        _storageMethods.uploadImage(
          image: img,
              receiverId: friendViewLayout.uid!,
              senderId: user.getUser.uid!,
          imageUploadProvider: _imageUploadProvider);  
        // imagePath == ""
        //     ? _chatMethods.addMessageToDb(_message)
        //     : _chatMethods.setImageMsg(
        //         imagePath, friendViewLayout.uid, user.getUser.uid);
        sendNotification(forwardedMessage, user.getUser.name.toString(),
            friendViewLayout.firebaseToken.toString());
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                receiver: friendViewLayout,
              ),
            ));}
      },
      title: Text(
          (friendViewLayout != null ? friendViewLayout.name! : null) != null
              ? friendViewLayout.name!
              : "..",
          style: Theme.of(context).textTheme.bodyLarge
        
          ),
      trailing: Icon(Icons.reply, color: Colors.green,),
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
}
