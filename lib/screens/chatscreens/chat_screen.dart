import 'dart:async';

import 'dart:io';
import 'dart:math';

import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'package:dio/dio.dart';
import 'package:file/local.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:sensors/sensors.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:skype_clone/constants/strings.dart';
import 'package:skype_clone/enum/view_state.dart';
import 'package:skype_clone/models/message.dart';
import 'package:skype_clone/models/userData.dart';

import 'package:skype_clone/provider/audio_upload_provider.dart';
import 'package:skype_clone/provider/file_provider.dart';
import 'package:skype_clone/provider/image_upload_provider.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'dart:io' as Io;
import 'package:skype_clone/provider/video_upload_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';
import 'package:skype_clone/resources/chat_methods.dart';
import 'package:skype_clone/resources/storage_methods.dart';
import 'package:skype_clone/screens/callscreens/pickup/pickup_layout.dart';
import 'package:skype_clone/screens/chatscreens/messageForwarding/forward_list.dart';
import 'package:skype_clone/screens/chatscreens/text_parsing/firebase_api_handler.dart';

import 'package:skype_clone/screens/chatscreens/push_notification.dart';
import 'package:skype_clone/screens/chatscreens/text_parsing/widgets/text_recognition_widget.dart';
import 'package:skype_clone/screens/chatscreens/widgets/audioPlayer.dart';
import 'package:skype_clone/screens/chatscreens/widgets/cached_image.dart';
import 'package:skype_clone/screens/chatscreens/widgets/file_viewer.dart';

import 'package:skype_clone/screens/chatscreens/widgets/image_page.dart';
import 'package:skype_clone/screens/chatscreens/widgets/pdf_widget.dart';
import 'package:skype_clone/screens/chatscreens/widgets/video_player.dart';
import 'package:skype_clone/screens/chatscreens/widgets/video_trimmer.dart';
import 'package:skype_clone/screens/home_screen.dart';

import 'package:skype_clone/screens/profile_screen.dart';
import 'package:skype_clone/utils/call_utilities.dart';
import 'package:skype_clone/utils/permissions.dart';
import 'package:skype_clone/utils/universal_variables.dart';
import 'package:skype_clone/utils/utilities.dart';
import 'package:skype_clone/widgets/appbar.dart';

import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

class ChatScreen extends StatefulWidget {
  final UserData receiver;

  ChatScreen({this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  String fileName;
  bool moreMenu = false;
  AnimationController animationController;
  Animation<double> animation;
  bool isCir = false;
  ImageUploadProvider _imageUploadProvider;
  VideoUploadProvider _videoUploadProvider;
  AudioUploadProvider _audioUploadProvider;
  FileUploadProvider _fileUploadProvider;
  List<String> imageUrlList = List<String>();
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
  bool _isAppBarOptions = false;
  String messageId = "";
  String forwardMessageText = "";
  String forwardedImage = "";
  bool _darkTheme = true;
  bool uploading = false;
  String ocrText = "";
  String backgroundImage = "";
  ShakeDetector detector;

  @override
  void initState() {
    super.initState();
    detector = ShakeDetector.autoStart(onPhoneShake: () {
      CallUtils.dial(
        from: sender,
        to: widget.receiver,
        context: context,
      );
    });
    _authMethods.getCurrentUser().then((user) {
      _currentUserId = user.uid;
      getbackground();
      setState(() {
        sender = UserData(
          uid: user.uid,
          name: user.displayName,
          profilePhoto: user.photoURL,
        );
      });
    });
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInCirc,
    );
    animationController.forward();
  }

  getbackground() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      backgroundImage = prefs.getString('background');
    });
  }

  void toggleMenu() {
    setState(() {
      moreMenu = !moreMenu;
      isCir = true;
    });
    if (animationController.status == AnimationStatus.forward ||
        animationController.status == AnimationStatus.completed) {
      animationController.reset();
      animationController.forward();
    } else {
      animationController.forward();
    }
  }

  getTheme() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkTheme = prefs.getBool('darkTheme');
    });
  }

  @override
  void dispose() {
    detector.stopListening();
    super.dispose();
  }

  Future parseText() async {
    final picker = ImagePicker();
    final imageFile = await picker.getImage(
        source: ImageSource.gallery, maxHeight: 970, maxWidth: 670);

    final text = await FirebaseMLApi.recogniseText(File(imageFile.path));

    setState(() {
      uploading = false;

      ocrText = text;
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
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    // accelerometerEvents.listen((AccelerometerEvent event) {
    //   print(event);
    // });
    getTheme();
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    _videoUploadProvider = Provider.of<VideoUploadProvider>(context);
    _audioUploadProvider = Provider.of<AudioUploadProvider>(context);
    _fileUploadProvider = Provider.of<FileUploadProvider>(context);
    return PickupLayout(
      scaffold: SafeArea(
        child: Scaffold(
          appBar:
              _isAppBarOptions ? optionsAppBar(context) : customAppBar(context),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      userProvider.getUser.firstColor != null
                          ? Color(userProvider.getUser.firstColor ??
                              Colors.white.value)
                          : Theme.of(context).backgroundColor,
                      userProvider.getUser.secondColor != null
                          ? Color(userProvider.getUser.secondColor ??
                              Colors.white.value)
                          : Theme.of(context).scaffoldBackgroundColor,
                    ]),
                  ),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
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
                  _fileUploadProvider.getViewState == ViewState.LOADING
                      ? Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 15.0),
                          child: CircularProgressIndicator(),
                        )
                      : Container(),
                  Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30.0),
                              topRight: Radius.circular(30.0))),
                      child: chatControls()),
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
                  : Center(),
              moreMenu
                  ? isCir
                      ? Positioned(
                          bottom: MediaQuery.of(context).size.height * 0.1,
                          left: MediaQuery.of(context).size.width * 0.1,
                          right: MediaQuery.of(context).size.width * 0.1,
                          child: CircularRevealAnimation(
                              centerOffset: Offset(
                                (MediaQuery.of(context).size.height * 0.3) / 2,
                                (MediaQuery.of(context).size.width * 0.8) / 2,
                              ),
                              child: moreMenuOptions(),
                              animation: animation),
                        )
                      : Positioned(
                          child: moreMenuOptions(),
                          bottom: MediaQuery.of(context).size.height * 0.1,
                          left: MediaQuery.of(context).size.width * 0.1,
                          right: MediaQuery.of(context).size.width * 0.1,
                        )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget moreMenuOptions() {
    return Visibility(
      visible: moreMenu,
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.grey.shade300, Colors.grey.shade300]),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                blurRadius: 0.4,
                spreadRadius: 0.4,
                offset: Offset(1.0, 1.0),
              )
            ]),
        // height: MediaQuery.of(context).size.height * 0.3,
        height: 180.0,
        width: MediaQuery.of(context).size.width * 0.8,
        child: GridView.count(
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          crossAxisCount: 3,
          children: [
            moreMenuItem(Icons.camera, 'Image', () {
              toggleMenu();
              pickImage(source: ImageSource.gallery);
            }, Colors.green),
            moreMenuItem(Icons.video_label, 'Video', () {
              toggleMenu();
              pickVideo();
            }, Colors.yellow),
            moreMenuItem(Icons.file_upload, 'File', () {
              toggleMenu();
              pickFile();
            }, Colors.orange),
            moreMenuItem(Icons.scanner, 'Scan Text', () {
              setState(() {
                isWriting = true;
              });
              toggleMenu();
              parseText();
            }, Colors.white),
            moreMenuItem(Icons.picture_as_pdf, 'Text to Pdf', () {
              toggleMenu();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          //  imageToPdf()
                          TextRecognitionWidget(
                              receiverId: widget.receiver.uid)));
            }, Colors.red),
          ],
        ),
      ),
    );
  }

  GestureDetector moreMenuItem(
      IconData icon, String name, GestureTapCallback fun, Color color) {
    return GestureDetector(
      onTap: fun,
      child: Column(
        children: [
          Icon(
            icon,
            size: 30.0,
            color: color,
          ),
          Text(
            name,
            style: TextStyle(color: Colors.black, fontSize: 18.0),
          )
        ],
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

  _start() async {
    try {
      if (await Permissions.recordingPermission()) {
        var ran = Random().nextInt(50);
        String path = Utils.generateRandomString(ran);
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

      setState(() {
        _recording = recording;
        _isRecording = isRecording;
      });
    }
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data());

    return _message.type != "Call"
        ? GestureDetector(
            onLongPress: () {
              setState(() {
                _message.type == MESSAGE_TYPE_IMAGE
                    ? {forwardedImage = _message.photoUrl}
                    : [];
                messageId = snapshot.id;
                _isAppBarOptions = true;
                forwardMessageText = _message.message;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Container(
                alignment: _message.senderId == _currentUserId
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: _message.senderId == _currentUserId
                    ? senderLayout(_message)
                    : Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: receiverLayout(_message, snapshot.id),
                      ),
              ),
            ),
          )
        : GestureDetector(
            child: callLayout(_message),
            onLongPress: () {
              deleteDialog(context, snapshot.id);
            },
          );
  }

  Widget callLayout(Message _message) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.3, vertical: 10.0),
      child: Column(
        children: [
          Container(
            height: 30.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.call_outlined,
                  color: Colors.green,
                ),
                SizedBox(width: 5.0),
                Text(
                  "Call",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0)),
          ),
          SizedBox(height: 2.0),
          (formatTime(_message.timestamp.toDate()))
        ],
      ),
    );
  }

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

  getMessage(Message message) {
    return Text(
      message.message,
      style: TextStyle(color: Colors.white, fontSize: 16.0),
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

    return Text(date,
        style: TextStyle(
          fontSize: 10.0,
          color: Theme.of(context).textTheme.bodyText1.color,
        ));
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = Radius.circular(35.0);
    if (message.type == MESSAGE_TYPE_AUDIO) {
      return message.audioUrl != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                                colors: [Colors.green, Colors.teal])),
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: audioPlayerClass(
                          url: message.audioUrl,
                          isSender: true,
                        )),
                    SizedBox(height: 2.0),
                    formatTime(message.timestamp.toDate()),
                  ],
                ),
                Icon(message.isRead ? Icons.done_all_outlined : Icons.done,
                    size: 20.0,
                    color: message.isRead
                        ? Colors.blue
                        : Theme.of(context).splashColor)
              ],
            )
          : Icon(Icons.sync_problem);
    }
    if (message.type == MESSAGE_TYPE_VIDEO) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    gradient:
                        LinearGradient(colors: [Colors.green, Colors.teal])),
                child: Container(
                    margin: EdgeInsets.all(5.0),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.50),
                    child: message.videoUrl != null
                        ? videoPlayer(
                            url: message.videoUrl,
                          )
                        : Icon(Icons.sync_problem)),
              ),
              SizedBox(height: 2.0),
              formatTime(message.timestamp.toDate()),
            ],
          ),
          Icon(message.isRead ? Icons.done_all_outlined : Icons.done,
              size: 20.0,
              color:
                  message.isRead ? Colors.blue : Theme.of(context).splashColor)
        ],
      );
    }
    if (message.type == MESSAGE_TYPE_FILE) {
      return message.fileUrl != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  children: [
                    GestureDetector(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    fileViewPage(url: message.fileUrl))),
                        child: pdfWidget(message.fileUrl, true)),
                    SizedBox(height: 2.0),
                    formatTime(message.timestamp.toDate()),
                  ],
                ),
                Icon(message.isRead ? Icons.done_all_outlined : Icons.done,
                    size: 20.0,
                    color: message.isRead
                        ? Colors.blue
                        : Theme.of(context).splashColor)
              ],
            )
          : Icon(Icons.sync_problem);
    }
    if (message.type == MESSAGE_TYPE_IMAGE) {
      if (!imageUrlList.contains(message.photoUrl)) {
        imageUrlList.add(message.photoUrl ?? "");
      }

      return message.photoUrl != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: LinearGradient(
                              colors: [Colors.green, Colors.teal])),
                      height: MediaQuery.of(context).size.width * 0.6,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Container(
                        margin: EdgeInsets.all(5.0),
                        child: CachedImage(message.photoUrl,
                            height: 250,
                            width: 250,
                            radius: 10,
                            isTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ImagePage(
                                          imageUrl: message.photoUrl,
                                          imageUrlList: imageUrlList,
                                        )))),
                      ),
                    ),
                    SizedBox(height: 2.0),
                    formatTime(message.timestamp.toDate()),
                  ],
                ),
                SizedBox(
                  width: 2.0,
                ),
                Icon(message.isRead ? Icons.done_all_outlined : Icons.done,
                    size: 20.0,
                    color: message.isRead
                        ? Colors.blue
                        : Theme.of(context).splashColor)
              ],
            )
          : Icon(Icons.sync_problem);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.only(top: 10),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.50),
              decoration: message.type != "Call"
                  ? BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.green.shade400,
                        Colors.teal.shade600
                      ]),
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
                child: Stack(
                  children: [
                    getMessage(message),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 2.0,
            ),
            formatTime(message.timestamp.toDate()),
          ],
        ),
        SizedBox(
          width: 2.0,
        ),
        Icon(message.isRead ? Icons.done_all_outlined : Icons.done,
            size: 20.0,
            color: message.isRead ? Colors.blue : Theme.of(context).splashColor)
      ],
    );
  }

  updateStatus(String uid) async {
    await FirebaseFirestore.instance
        .collection(MESSAGES_COLLECTION)
        .doc(widget.receiver.uid)
        .collection(_currentUserId)
        .where('isRead', isEqualTo: false)
        .get()
        .then((documentSnapshot) {
      if (documentSnapshot.docs.length > 0) {
        for (DocumentSnapshot doc in documentSnapshot.docs) {
          doc.reference.update({'isRead': true});

          print('updated');
        }
      }
    });
  }

  Widget receiverLayout(Message message, String uid) {
    updateStatus(uid);
    Radius messageRadius = Radius.circular(35);
    if (message.type == MESSAGE_TYPE_AUDIO) {
      return message.audioUrl != null
          ? Column(
              children: [
                Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        gradient: LinearGradient(colors: [
                          Colors.blue.shade700,
                          Colors.blue.shade900
                        ])),
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: audioPlayerClass(
                      url: message.audioUrl,
                      isSender: false,
                    )),
                SizedBox(height: 2.0),
                formatTime(message.timestamp.toDate()),
              ],
            )
          : Icon(Icons.sync_problem);
    }
    if (message.type == MESSAGE_TYPE_VIDEO) {
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade900])),
            child: Container(
                margin: EdgeInsets.all(5.0),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.50),
                child: message.videoUrl != null
                    ? videoPlayer(
                        url: message.videoUrl,
                      )
                    : Icon(Icons.sync_problem)),
          ),
          SizedBox(height: 2.0),
          formatTime(message.timestamp.toDate()),
        ],
      );
    }
    if (message.type == MESSAGE_TYPE_FILE) {
      return message.fileUrl != null
          ? Column(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          fileViewPage(url: message.fileUrl))),
                  child: pdfWidget(message.fileUrl, false),
                ),
                SizedBox(height: 2.0),
                formatTime(message.timestamp.toDate()),
              ],
            )
          : Icon(Icons.sync_problem);
    }
    if (message.type == MESSAGE_TYPE_IMAGE) {
      if (!imageUrlList.contains(message.photoUrl)) {
        imageUrlList.add(message.photoUrl ?? "");
      }

      return message.photoUrl != null
          ? Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      gradient: LinearGradient(colors: [
                        Colors.blue.shade700,
                        Colors.blue.shade900
                      ])),
                  height: MediaQuery.of(context).size.width * 0.6,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Container(
                    margin: EdgeInsets.all(5.0),
                    child: CachedImage(message.photoUrl,
                        height: 250,
                        width: 250,
                        radius: 10,
                        isTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ImagePage(
                                      imageUrl: message.photoUrl,
                                      imageUrlList: imageUrlList,
                                    )))),
                  ),
                ),
                SizedBox(height: 2.0),
                formatTime(message.timestamp.toDate()),
              ],
            )
          : Icon(Icons.sync_problem);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 12),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.50),
          decoration: message.type != "Call"
              ? BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade900]),
                  borderRadius: BorderRadius.only(
                    bottomRight: messageRadius,
                    topRight: messageRadius,
                    bottomLeft: messageRadius,
                  ),
                )
              : BoxDecoration(
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

    sendMessage(context) {
      var text = textFieldController.text;
      Message _message = Message(
        receiverId: widget.receiver.uid,
        senderId: sender.uid,
        message: text,
        timestamp: Timestamp.now(),
        type: 'text',
        isRead: false,
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
            // onTap: () => addMediaModal(context),
            onTap: () {
              toggleMenu();
            },
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
                shape: BoxShape.circle,
              ),
              child: Icon(moreMenu ? Icons.cancel_sharp : Icons.add,
                  color: Colors.white),
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
                      border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(50.0),
                          ),
                          borderSide: BorderSide.none),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      filled: true,
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
                    onPressed: () => sendMessage(context),
                  ))
              : Container()
        ],
      ),
    );
  }

  Future pickFile() async {
    File path = await FilePicker.getFile(
        type: FileType.custom, allowedExtensions: ['pdf']);

    if (path != null) {
      _storageMethods.uploadFile(
          file: path,
          receiverId: widget.receiver.uid,
          senderId: _currentUserId,
          fileUploadProvider: _fileUploadProvider);
      sendNotification("FILE", sender.name.toString(),
          widget.receiver.firebaseToken.toString());
    }
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
            toolbarColor: Theme.of(context).backgroundColor,
            toolbarTitle: "Edit Image",
            statusBarColor: Theme.of(context).backgroundColor,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: Colors.teal,
            toolbarWidgetColor: Theme.of(context).iconTheme.color,
          ));
      _storageMethods.uploadImage(
        image: cropped,
        receiverId: widget.receiver.uid,
        senderId: _currentUserId,
        imageUploadProvider: _imageUploadProvider,
      );
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

  Future<void> downloadFile(String imagePath) async {
    Dio dio = Dio();

    dio.download(forwardedImage ?? noImageAvailable, imagePath,
        onReceiveProgress: (actualBytes, totalBytes) {});
  }

  CustomAppBar optionsAppBar(context) {
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(
          Icons.cancel_outlined,
          color: Theme.of(context).iconTheme.color,
        ),
        onPressed: () {
          setState(() {
            _isAppBarOptions = false;
          });
        },
      ),
      title: Text(""),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(
            Icons.reply,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () async {
            var dir = await getExternalStorageDirectory();

            String imageFilePath = Utils.generateRandomString(15);
            String path = '${dir.path}/${imageFilePath}.jpg';
            await downloadFile(path);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => forwardPage(
                          message: forwardMessageText,
                          imagePath: path,
                        )));
          },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            deleteDialog(context, messageId);
            setState(() {
              _isAppBarOptions = false;
            });
          },
        )
      ],
    );
  }

  CustomAppBar customAppBar(context) {
    return CustomAppBar(
      isLeadingWidth: true,
      onTap: () =>
          // Get.to(profilePage(
          //   user: widget.receiver,
          // )),
          Navigator.push(context, MaterialPageRoute(builder: (context) {
        return profilePage(
          user: widget.receiver,
        );
      })),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).iconTheme.color,
        ),
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        },
      ),
      centerTitle: false,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
              radius: 20.0,
              child: CachedImage(
                widget.receiver.profilePhoto,
                radius: 35.0,
              )),
          SizedBox(
            width: 6.0,
          ),
          Text(
            widget.receiver.name,
            style: GoogleFonts.patuaOne(
                textStyle: Theme.of(context).textTheme.bodyText1,
                fontSize: 20.0,
                letterSpacing: 1.5),
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
            color: Theme.of(context).iconTheme.color,
            icon: Icon(
              // Icons.video_call_rounded,
              FontAwesomeIcons.video,
              size: 25.0,
            ),
            onPressed: () async {
              // Message _message = Message(
              //   receiverId: widget.receiver.uid,
              //   senderId: sender.uid,
              //   message: "Call",
              //   timestamp: Timestamp.now(),
              //   type: 'Call',
              // );
              await Permissions.cameraAndMicrophonePermissionsGranted()
                  ? {
                      CallUtils.dial(
                        from: sender,
                        to: widget.receiver,
                        context: context,
                      ),
                      // _chatMethods.addMessageToDb(_message)
                    }
                  : [];
            }),
      ],
    );
  }
}
