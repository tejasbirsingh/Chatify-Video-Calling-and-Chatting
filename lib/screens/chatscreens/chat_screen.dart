import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photofilters/filters/filters.dart';
import 'package:photofilters/filters/preset_filters.dart';
import 'package:provider/provider.dart';
import 'package:skype_clone/constants/strings.dart';
import 'package:skype_clone/enum/view_state.dart';
import 'package:skype_clone/models/message.dart';
import 'package:skype_clone/models/userData.dart';
import 'package:skype_clone/provider/image_upload_provider.dart';
import 'package:skype_clone/provider/video_upload_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';
import 'package:skype_clone/resources/chat_methods.dart';
import 'package:skype_clone/resources/storage_methods.dart';
import 'package:skype_clone/screens/callscreens/pickup/pickup_layout.dart';
import 'package:skype_clone/screens/chatscreens/widgets/cached_image.dart';

import 'package:skype_clone/screens/chatscreens/widgets/image_page.dart';
import 'package:skype_clone/screens/chatscreens/widgets/video_player.dart';
import 'package:skype_clone/screens/chatscreens/widgets/video_trimmer.dart';
import 'package:skype_clone/screens/profile.dart';
import 'package:skype_clone/utils/call_utilities.dart';
import 'package:skype_clone/utils/permissions.dart';
import 'package:skype_clone/utils/universal_variables.dart';
import 'package:skype_clone/utils/utilities.dart';
import 'package:skype_clone/widgets/appbar.dart';

import 'package:skype_clone/widgets/custom_tile.dart';
import 'dart:io' as Io;

import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

class ChatScreen extends StatefulWidget {
  final UserData receiver;

  ChatScreen({this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String fileName;
  List<Filter> filters = presetFiltersList;
  File imageFilterFile;

  ImageUploadProvider _imageUploadProvider;
  VideoUploadProvider _videoUploadProvider;

  final StorageMethods _storageMethods = StorageMethods();
  final ChatMethods _chatMethods = ChatMethods();
  final AuthMethods _authMethods = AuthMethods();

  TextEditingController textFieldController = TextEditingController();
  FocusNode textFieldFocus = FocusNode();
  ScrollController _listScrollController = ScrollController();
  bool _isEditing = false;
  UserData sender;
  String _currentUserId;
  bool isWriting = false;
  bool showEmojiPicker = false;
  VideoPlayerController videoPlayerController;

  // PDF related initializations

  bool uploading = false;
  String ocrText = "";

  @override
  void initState() {
    super.initState();
    _authMethods.getCurrentUser().then((user) {
      _currentUserId = user.uid;

      setState(() {
        sender = UserData(
          uid: user.uid,
          name: user.displayName,
          profilePhoto: user.photoURL,
        );
      });
    });
  }

  Future parseText() async {
    final picker = ImagePicker();
    final imageFile = await picker.getImage(
        source: ImageSource.gallery, maxHeight: 970, maxWidth: 670);
    var bytes = Io.File(imageFile.path.toString()).readAsBytesSync();
    String img64 = base64Encode(bytes);
    // print(img64.toString());
    var url = 'https://api.ocr.space/parse/image';
    var payload = {"base64Image": "data:image/jpg;base64,${img64.toString()}"};
    var header = {"apikey": "d938f7220788957"};
    var post = await http.post(url, body: payload, headers: header);
    var result = jsonDecode(post.body);

    // print(result['ParsedResults'][0]['ParsedText']);
    setState(() {
      uploading = false;
      ocrText = result['ParsedResults'][0]['ParsedText'];
    });
    textFieldController.text = textFieldController.text + "  " + ocrText;
  }

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    _videoUploadProvider = Provider.of<VideoUploadProvider>(context);

    return PickupLayout(
      scaffold: Scaffold(
        // backgroundColor: UniversalVariables.blackColor,
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: customAppBar(context),
  
        body: Stack(
          children: [
            Column(
              children: <Widget>[
                Flexible(
                  child: messageList(),
                ),
                _imageUploadProvider.getViewState == ViewState.LOADING
                    ? Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 15),
                        child: CircularProgressIndicator(),
                      )
                    : Container(),
                _videoUploadProvider.getViewState == ViewState.LOADING
                    ? Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 15.0),
                        child: CircularProgressIndicator(),
                      )
                    : Container(),
                chatControls(),
                showEmojiPicker
                    ? Container(child: emojiContainer())
                    : Container(),
              ],
            ),
            (_isEditing)
                ? Container(
                    color: Colors.black,
                    height: MediaQuery.of(context).size.height * 0.95,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Center()
          ],
        ),
      ),
    );
  }

  emojiContainer() {
    return EmojiPicker(
      bgColor: UniversalVariables.separatorColor,
      indicatorColor: UniversalVariables.blueColor,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        setState(() {
          isWriting = true;
        });

        textFieldController.text = textFieldController.text + emoji.emoji;
      },
      recommendKeywords: ["face", "happy", "party", "sad"],
      numRecommended: 50,
    );
  }

  Widget messageList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(_currentUserId)
          .collection(widget.receiver.uid)
          .orderBy(TIMESTAMP_FIELD, descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }

        // SchedulerBinding.instance.addPostFrameCallback((_) {
        //   _listScrollController.animateTo(
        //     _listScrollController.position.minScrollExtent,
        //     duration: Duration(milliseconds: 250),
        //     curve: Curves.easeInOut,
        //   );
        // });

        return ListView.builder(
          padding: EdgeInsets.all(10),
          controller: _listScrollController,
          reverse: true,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            return chatMessageItem(snapshot.data.docs[index]);
          },
        );
      },
    );
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data());

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: _message.senderId == _currentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _message.senderId == _currentUserId
            ? senderLayout(_message)
            : receiverLayout(_message),
      ),
    );
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = Radius.circular(35.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.50),
          decoration: BoxDecoration(
            // color: UniversalVariables.senderColor,
            gradient: LinearGradient(colors: [Colors.green.shade400,Colors.teal.shade600]),
            borderRadius: BorderRadius.only(
              topLeft: messageRadius,
              topRight: messageRadius,
              bottomLeft: messageRadius,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: getMessage(message),
          ),
        ),
        SizedBox(
          height: 2.0,
        ),
        formatTime(message.timestamp.toDate()),
      ],
    );
  }

  getMessage(Message message) {
    if (message.type == MESSAGE_TYPE_IMAGE) {
      return message.photoUrl != null
          ? CachedImage(message.photoUrl,
              height: 250,
              width: 250,
              radius: 10,
              isTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ImagePage(
                            imageUrl: message.photoUrl,
                          ))))
          : Icon(Icons.sync_problem);
    } else if (message.type == MESSAGE_TYPE_VIDEO) {
      return message.videoUrl != null
          ? videoPlayer(
              url: message.videoUrl,
            )
          : Icon(Icons.sync_problem);
    } else {
      return Text(
        message.message,
        style: TextStyle(color: Colors.white, fontSize: 16.0),
      );
    }
  }

  formatTime(DateTime time) {
    String date = time.day.toString() +
        "/" +
        time.month.toString() +
        "/" +
        time.year.toString() +
        "  " +
        (time.hour > 12 ? time.hour - 12 : time.hour).toString() +
        ":" +
        (time.minute.toString().length == 1
            ? "0" + time.minute.toString()
            : time.minute.toString()) +
        " " +
        (time.hour < 12 ? "am" : "pm").toString();

    return Text(
      date,
      style: TextStyle(fontSize: 10.0),
    );
  }

  Widget receiverLayout(Message message) {
    Radius messageRadius = Radius.circular(35);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 12),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.50),
          decoration: BoxDecoration(
            // color: UniversalVariables.receiverColor,
            gradient: LinearGradient(colors: [Colors.blue.shade700,Colors.blue.shade900]),
            borderRadius: BorderRadius.only(
              bottomRight: messageRadius,
              topRight: messageRadius,
              bottomLeft: messageRadius,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: getMessage(message),
          ),
        ),
        SizedBox(
          height: 2.0,
        ),
        formatTime(message.timestamp.toDate())
      ],
    );
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    addMediaModal(context) {
      showModalBottomSheet(
          context: context,
          elevation: 0,
          backgroundColor: UniversalVariables.blackColor,
          builder: (context) {
            return Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: <Widget>[
                      FlatButton(
                        child: Icon(
                          Icons.close,
                        ),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Send",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    children: <Widget>[
                      ModalTile(
                        title: "Media",
                        subtitle: "Share Photos",
                        icon: Icons.image,
                        onTap: () => pickImage(source: ImageSource.gallery),
                      ),
                      ModalTile(
                        title: "Media",
                        subtitle: "Share Video",
                        icon: Icons.video_label,
                        onTap: () => pickVideo(),
                      ),
                      ModalTile(
                        title: "File",
                        subtitle: "Share files",
                        icon: Icons.tab,
                      ),
                      ModalTile(
                        title: "Text Extractor",
                        subtitle: "Extract the test from an image",
                        icon: Icons.scanner,
                        onTap: () {
                          parseText();
                          Navigator.pop(context);
                        },
                      ),
                      ModalTile(
                        title: "Contact",
                        subtitle: "Share contacts",
                        icon: Icons.contacts,
                      ),
                      ModalTile(
                        title: "Location",
                        subtitle: "Share a location",
                        icon: Icons.add_location,
                      ),
                      ModalTile(
                        title: "Schedule Call",
                        subtitle: "Schedule a meeting in advance",
                        icon: Icons.schedule,
                      ),
                    ],
                  ),
                ),
              ],
            );
          });
    }

    sendMessage() {
      var text = textFieldController.text;

      Message _message = Message(
        receiverId: widget.receiver.uid,
        senderId: sender.uid,
        message: text,
        timestamp: Timestamp.now(),
        type: 'text',
      );

      setState(() {
        isWriting = false;
      });

      textFieldController.text = "";

      _chatMethods.addMessageToDb(_message);
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => addMediaModal(context),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: UniversalVariables.fabGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Stack(
              
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: textFieldController,
                  focusNode: textFieldFocus,
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  // scrollPadding: EdgeInsets.all(3),
                  onTap: () => hideEmojiContainer(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  onChanged: (val) {
                    (val.length > 0 && val.trim() != "")
                        ? setWritingTo(true)
                        : setWritingTo(false);
                  },
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: Theme.of(context).textTheme.bodyText2,
                    //TextStyle(
                      // color: UniversalVariables.greyColor,                    
                    // ),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(50.0),
                        ),
                        borderSide: BorderSide.none),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    // fillColor: UniversalVariables.separatorColor,
                    fillColor: Theme.of(context).dividerColor
                  ),
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    if (!showEmojiPicker) {
                      // keyboard is visible
                      hideKeyboard();
                      showEmojiContainer();
                    } else {
                      //keyboard is hidden
                      showKeyboard();
                      hideEmojiContainer();
                    }
                  },
                  icon: Icon(Icons.face),
                ),
              ],
            ),
          ),
          isWriting
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.record_voice_over),
                ),
          isWriting
              ? Container()
              : GestureDetector(
                  child: Icon(Icons.camera_alt),
                  onTap: () => pickImage(source: ImageSource.camera),
                ),
          isWriting
              ? Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      gradient: UniversalVariables.fabGradient,
                      shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 15,
                    ),
                    onPressed: () => sendMessage(),
                  ))
              : Container()
        ],
      ),
    );
  }

  Future pickImage({@required ImageSource source}) async {
    this.setState(() {
      _isEditing = true;
    });
    File selectedImage = await Utils.pickImage(source: source);
    if (selectedImage != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: selectedImage.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 80,
          maxHeight: 700,
          maxWidth: 700,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.black54,
            toolbarTitle: "Edit Image",
            statusBarColor: Colors.black,
            backgroundColor: Colors.black,
            toolbarWidgetColor: Colors.white,
          ));
      _storageMethods.uploadImage(
          image: cropped,
          receiverId: widget.receiver.uid,
          senderId: _currentUserId,
          imageUploadProvider: _imageUploadProvider);
      this.setState(() {
        _isEditing = false;
      });
    } else {
      this.setState(() {
        _isEditing = false;
      });
    }
  }

  // Future pickVideo() async {
  //   PickedFile video = await ImagePicker().getVideo(
  //       source: ImageSource.gallery, maxDuration: Duration(minutes: 5));

  //   if (video != null) {
  //     videoPlayerController = VideoPlayerController.file(File(video.path))
  //       ..initialize().then((_) {
  //         setState(() {
  //           videoPlayerController.play();
  //         });
  //       });
  //     _storageMethods.uploadVideo(
  //         video: File(video.path),
  //         receiverId: widget.receiver.uid,
  //         senderId: _currentUserId,
  //         videoUploadProvider: _videoUploadProvider);
  //   }
  // }

  Future pickVideo() async {
    final Trimmer _trimmer = Trimmer();
    PickedFile video = await ImagePicker().getVideo(
        source: ImageSource.gallery, maxDuration: Duration(minutes: 5));
    await _trimmer.loadVideo(videoFile: File(video.path));
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return TrimmerView(
        trimmerFile: _trimmer,
        receiver: widget.receiver.uid,
        sender: _currentUserId,
      );
    }));
    if (video != null) {
      videoPlayerController = VideoPlayerController.file(File(video.path))
        ..initialize().then((_) {
          setState(() {
            videoPlayerController.play();
          });
        });
    }
  }

  CustomAppBar customAppBar(context) {
    return CustomAppBar(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => profilePage(
              user: widget.receiver,
            ),
          )),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(
        widget.receiver.name,
        style: Theme.of(context).textTheme.headline1,
      ),
      actions: <Widget>[
        IconButton(
            color: Theme.of(context).iconTheme.color,
          icon: Icon(
            
            Icons.video_call,
          ),
          onPressed: () async {
              await Permissions.cameraAndMicrophonePermissionsGranted()
                  ? CallUtils.dial(
                      from: sender,
                      to: widget.receiver,
                      context: context,
                    )
                  : {};
                 
                  }
        ),
        IconButton(
            color: Theme.of(context).iconTheme.color,
          icon: Icon(
            Icons.phone,
          ),
          onPressed: () {},
        )
      ],
    );
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onTap;

  const ModalTile({
    @required this.title,
    @required this.subtitle,
    @required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        mini: false,
        onTap: onTap,
        leading: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: UniversalVariables.receiverColor,
          ),
          padding: EdgeInsets.all(10),
          child: Icon(
            icon,
            color: UniversalVariables.greyColor,
            size: 38,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: UniversalVariables.greyColor,
            fontSize: 14,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
