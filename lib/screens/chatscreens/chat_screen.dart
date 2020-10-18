import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file/local.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';

import 'package:skype_clone/configs/firebase_config.dart';
import 'package:skype_clone/constants/strings.dart';
import 'package:skype_clone/enum/view_state.dart';
import 'package:skype_clone/models/message.dart';
import 'package:skype_clone/models/userData.dart';

import 'package:http/http.dart' as http;
import 'package:skype_clone/provider/audio_upload_provider.dart';
import 'package:skype_clone/provider/image_upload_provider.dart';
import 'dart:io' as Io;

import 'package:skype_clone/provider/video_upload_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';
import 'package:skype_clone/resources/chat_methods.dart';
import 'package:skype_clone/resources/storage_methods.dart';
import 'package:skype_clone/screens/callscreens/pickup/pickup_layout.dart';
import 'package:skype_clone/screens/chatscreens/image_to_pdf.dart';
import 'package:skype_clone/screens/chatscreens/widgets/audioPlayer.dart';
import 'package:skype_clone/screens/chatscreens/widgets/cached_image.dart';
import 'package:skype_clone/screens/chatscreens/widgets/image_page.dart';
import 'package:skype_clone/screens/chatscreens/widgets/video_player.dart';
import 'package:skype_clone/screens/chatscreens/widgets/video_trimmer.dart';
import 'package:skype_clone/screens/profile_screen.dart';
import 'package:skype_clone/utils/call_utilities.dart';
import 'package:skype_clone/utils/permissions.dart';
import 'package:skype_clone/utils/universal_variables.dart';
import 'package:skype_clone/utils/utilities.dart';
import 'package:skype_clone/widgets/appbar.dart';
import 'package:skype_clone/widgets/custom_tile.dart';
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

  File imageFilterFile;

  ImageUploadProvider _imageUploadProvider;
  VideoUploadProvider _videoUploadProvider;
  AudioUploadProvider _audioUploadProvider;

  final StorageMethods _storageMethods = StorageMethods();
  final ChatMethods _chatMethods = ChatMethods();
  final AuthMethods _authMethods = AuthMethods();

  Recording _recording = new Recording();
  bool _isRecording = false;
  Random random = new Random();
  bool isRecordStart = false;

  LocalFileSystem localFileSystem;
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

  @override
  void dispose() {
    super.dispose();
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
    _audioUploadProvider = Provider.of<AudioUploadProvider>(context);
    return PickupLayout(
      scaffold: SafeArea(
        child: Scaffold(
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
                  _audioUploadProvider.getViewState == ViewState.LOADING
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

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  _start() async {
    try {
      if (await Permissions.recordingPermission()) {
        var ran = Random().nextInt(50);
        String path = generateRandomString(ran);
        Io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        path = appDocDirectory.path + '/' + path;

        await AudioRecorder.start(
            path: path, audioOutputFormat: AudioOutputFormat.WAV);

        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _recording = new Recording(duration: new Duration(), path: "");
          _isRecording = isRecording;
        });
      } else {
        print("No permissions");
      }
    } catch (e) {
      print(e);
    }
  }

  _stop() async {
    var recording = await AudioRecorder.stop();

    bool isRecording = await AudioRecorder.isRecording;

    if (recording.path != null) {
      File file = File(recording.path);

      if (file.path != null) {
        _storageMethods.uploadAudio(
            audio: file,
            receiverId: widget.receiver.uid,
            senderId: _currentUserId,
            audioUploadProvider: _audioUploadProvider);
               sendNotification("Audio", sender.name.toString(),
          widget.receiver.firebaseToken.toString());
      }
      print(file.path);

      setState(() {
        _recording = recording;
        _isRecording = isRecording;
      });
    }
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data());

    return GestureDetector(
      onLongPress: () {
        deleteDialog(context, snapshot.id);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        child: Container(
          alignment: _message.senderId == _currentUserId
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: _message.senderId == _currentUserId
              ? senderLayout(_message)
              : receiverLayout(_message),
        ),
      ),
    );
  }

  // await FirebaseFirestore.instance
  //     .collection(MESSAGES_COLLECTION)
  //     .doc(_currentUserId)
  //     .collection(widget.receiver.uid)
  //     .doc(snapshot.id).delete();

  deleteDialog(BuildContext context, String id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              "Delete this message ?",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            actions: [
              TextButton(
                child:
                    Text('Yes', style: Theme.of(context).textTheme.bodyText1),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection(MESSAGES_COLLECTION)
                      .doc(_currentUserId)
                      .collection(widget.receiver.uid)
                      .doc(id)
                      .delete();
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('No', style: Theme.of(context).textTheme.bodyText1),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
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
          decoration: message.type != "Call"
              ? BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.teal.shade600]),
                  borderRadius: BorderRadius.only(
                    topLeft: messageRadius,
                    topRight: messageRadius,
                    bottomLeft: messageRadius,
                  ),
                )
              : BoxDecoration(
                  color: Colors.grey.withOpacity(0.7),
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
    } else if (message.type == "Call") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.call),
          SizedBox(width: 10.0),
          Text(
            "Call",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else if (message.type == MESSAGE_TYPE_AUDIO) {
      print("Chat screen URL:-${message.audioUrl}");
      return message.audioUrl != null
          ? audioPlayerClass(url: message.audioUrl)
          : Icon(Icons.sync_problem);
    } else {
      return Text(
        message.message,
        style: TextStyle(color: Colors.white, fontSize: 16.0),
      );
    }
  }

  Future<http.Response> sendNotification(
      String message, String sender, String receiver) async {
    //      await firebaseMessaging.requestNotificationPermissions(
    // const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
    // );
    // print("Firebase Token: " + receiver);
    return await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Authorization': 'key=$SERVER_KEY',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        // "message": {
        "to": "$receiver",
        "collapse_key": "type_a",
        "priority": "high",
        "alert": "true",
        "id": '1',
        "notification": {
          "title": "$sender",
          "body": "$message",
        },
        "data": {
          "title": "$sender",
          "body": "$message",
          "sound": "default",
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
        }
        // }
      }),
    );
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
          decoration: message.type != "Call"
              ? BoxDecoration(
                  // color: UniversalVariables.receiverColor,
                  gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade900]),
                  borderRadius: BorderRadius.only(
                    bottomRight: messageRadius,
                    topRight: messageRadius,
                    bottomLeft: messageRadius,
                  ),
                )
              : BoxDecoration(
                  // color: UniversalVariables.receiverColor,
                  color: Colors.grey.withOpacity(0.7),
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
          backgroundColor: Theme.of(context).backgroundColor,
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
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Send",
                              style: Theme.of(context).textTheme.headline1),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    children: <Widget>[
                      ModalTile(
                        title: "Share Photos",
                        // subtitle: "Share Photos",
                        icon: Icons.image,
                        onTap: () => pickImage(source: ImageSource.gallery),
                      ),
                      ModalTile(
                        title: "Share Video",
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
                        title: "Image Text to Pdf",
                        subtitle: "Share contacts",
                        icon: Icons.text_fields_outlined,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => imageToPdf()));
                        },
                      ),
                      // ModalTile(
                      //   title: "Location",
                      //   subtitle: "Share a location",
                      //   icon: Icons.add_location,
                      // ),
                      // ModalTile(
                      //   title: "Schedule Call",
                      //   subtitle: "Schedule a meeting in advance",
                      //   icon: Icons.schedule,
                      // ),
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
      sendNotification(_message.message.toString(), sender.name.toString(),
          widget.receiver.firebaseToken.toString());
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
                gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: Colors.white),
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
                      fillColor: Theme.of(context).dividerColor),
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
                  icon: Icon(
                    Icons.emoji_emotions_sharp,
                    size: 30.0,
                    color: Colors.yellow,
                  ),
                ),
              ],
            ),
          ),
          isWriting
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: isRecordStart == true
                      ? IconButton(
                          icon: Icon(Icons.mic_off_outlined),
                          onPressed: () {
                            _stop();
                            setState(() {
                              isRecordStart = false;
                            });
                          },
                        )
                      : IconButton(
                          icon: Icon(Icons.mic_none_outlined),
                          onPressed: () {
                            _start();
                            setState(() {
                              isRecordStart = true;
                            });
                          },
                        ),
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
             sendNotification("IMAGE", sender.name.toString(),
          widget.receiver.firebaseToken.toString());
      this.setState(() {
        _isEditing = false;
      });
    } else {
      this.setState(() {
        _isEditing = false;
      });
    }
  }

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
       sendNotification("Video", sender.name.toString(),
          widget.receiver.firebaseToken.toString());
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
              Icons.video_call_outlined,
              size: 30.0,
            ),
            onPressed: () async {
              Message _message = Message(
                receiverId: widget.receiver.uid,
                senderId: sender.uid,
                message: "Call",
                timestamp: Timestamp.now(),
                type: 'Call',
              );
              await Permissions.cameraAndMicrophonePermissionsGranted()
                  ? {
                      CallUtils.dial(
                        from: sender,
                        to: widget.receiver,
                        context: context,
                      ),
                      _chatMethods.addMessageToDb(_message)
                    }
                  : [];
            }),
        // IconButton(
        //   color: Theme.of(context).iconTheme.color,
        //   icon: Icon(
        //     Icons.phone,
        //   ),
        //   onPressed: () {},
        // )
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
    this.subtitle,
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
            // color: UniversalVariables.receiverColor,
            color: Theme.of(context).cardColor,
          ),
          padding: EdgeInsets.all(10),
          child: Icon(
            icon,
            color: Theme.of(context).iconTheme.color,
            size: 38,
          ),
        ),
        // subtitle: Text(
        //   subtitle,
        //   style: TextStyle(
        //     color: UniversalVariables.greyColor,
        //     fontSize: 14,
        //   ),
        // ),
        title: Text(title, style: Theme.of(context).textTheme.headline1),
      ),
    );
  }
}
