import 'dart:async';

import 'dart:io';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'package:dio/dio.dart';
import 'package:file/local.dart';
// import 'package:audio_recorder/audio_recorder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:emoji_picker/emoji_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';

import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chatify/constants/strings.dart';
import 'package:chatify/enum/view_state.dart';
import 'package:chatify/models/message.dart';
import 'package:chatify/models/userData.dart';

import 'package:chatify/provider/audio_upload_provider.dart';
import 'package:chatify/provider/file_provider.dart';
import 'package:chatify/provider/image_upload_provider.dart';
import 'package:chatify/provider/user_provider.dart';
import 'dart:io' as Io;
import 'package:chatify/provider/video_upload_provider.dart';
import 'package:chatify/resources/auth_methods.dart';
import 'package:chatify/resources/chat_methods.dart';
import 'package:chatify/resources/storage_methods.dart';
import 'package:chatify/screens/callscreens/pickup/pickup_layout.dart';
import 'package:chatify/screens/chatscreens/messageForwarding/forward_list_page.dart';
import 'package:chatify/screens/chatscreens/sound_recorder.dart';
import 'package:record/record.dart';
import 'package:chatify/screens/chatscreens/push_notification.dart';
import 'package:chatify/screens/chatscreens/widgets/arc_class.dart';
import 'package:chatify/screens/chatscreens/widgets/audioPlayer.dart';
import 'package:chatify/screens/chatscreens/widgets/cached_image.dart';
import 'package:chatify/screens/chatscreens/widgets/file_viewer.dart';

import 'package:chatify/screens/chatscreens/widgets/image_page.dart';
import 'package:chatify/screens/chatscreens/widgets/location_class.dart';
import 'package:chatify/screens/chatscreens/widgets/pdf_widget.dart';
import 'package:chatify/screens/chatscreens/widgets/video_player.dart';
import 'package:chatify/screens/home_screen.dart';

import 'package:chatify/screens/profile_screen.dart';
import 'package:chatify/utils/call_utilities.dart';
import 'package:chatify/utils/permissions.dart';
import 'package:chatify/utils/universal_variables.dart';
import 'package:chatify/utils/utilities.dart';
import 'package:chatify/widgets/custom_app_bar.dart';
import 'package:chatify/widgets/gradient_icon.dart';
import 'package:swipe_to/swipe_to.dart';

import 'package:video_player/video_player.dart';

class ChatScreen extends StatefulWidget {
  final UserData receiver;

  ChatScreen({required this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  String? fileName;
  bool moreMenu = false;
  Message? replyMessage;
  AnimationController? animationController;
  Animation<double>? animation;
  bool isCir = false;
  ImageUploadProvider? _imageUploadProvider;
  VideoUploadProvider? _videoUploadProvider;
  AudioUploadProvider? _audioUploadProvider;
  FileUploadProvider? _fileUploadProvider;
  List<String> imageUrlList = [];
  final StorageMethods _storageMethods = StorageMethods();
  final ChatMethods _chatMethods = ChatMethods();
  final AuthMethods _authMethods = AuthMethods();

  // Recording _recording = new Recording();
  bool _isRecording = false;
  Random random = new Random();
  bool isRecordStart = false;
  Record record = Record();
  final recorder = SoundRecorder();

  late LocalFileSystem localFileSystem;
  TextEditingController textFieldController = TextEditingController();
  FocusNode textFieldFocus = FocusNode();
  ScrollController _listScrollController = ScrollController();
  bool _isEditing = false;
  late UserData sender;
  late String _currentUserId;
  bool isWriting = false;
  bool showEmojiPicker = false;
  late VideoPlayerController videoPlayerController;
  bool _isAppBarOptions = false;
  String messageId = "";
  String forwardMessageText = "";
  String forwardedImage = "";
  bool _darkTheme = true;
  bool uploading = false;
  String ocrText = "";
  String backgroundImage = "";
  late ShakeDetector detector;

  @override
  void initState() {
    super.initState();
    recorder.init();
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
          name: user.displayName!,
          profilePhoto: user.photoURL!,
        );
      });
    });
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    animation = CurvedAnimation(
      parent: animationController!,
      curve: Curves.easeInCirc,
    );
    animationController!.forward();
  }

  getbackground() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      backgroundImage = prefs.getString('background') ?? "";
    });
  }

  void toggleMenu() {
    setState(() {
      moreMenu = !moreMenu;
      isCir = true;
    });
    if (animationController!.status == AnimationStatus.forward ||
        animationController!.status == AnimationStatus.completed) {
      animationController!.reset();
      animationController!.forward();
    } else {
      animationController!.forward();
    }
  }

  getTheme() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkTheme = prefs.getBool('darkTheme') ?? false;
    });
  }

  @override
  void dispose() {
    recorder.dispose();
    detector.stopListening();
    record.dispose();

    super.dispose();
  }

  Future parseText() async {
    final picker = ImagePicker();
    final imageFile = await picker.getImage(
        source: ImageSource.gallery, maxHeight: 970, maxWidth: 670);

    // final text = await FirebaseMLApi.recogniseText(File(imageFile.path));
    final text = "";
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
                          : Theme.of(context).colorScheme.background,
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
                  _imageUploadProvider!.getViewState == ViewState.LOADING
                      ? Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 15),
                          child: CircularProgressIndicator(),
                        )
                      : Container(),
                  _videoUploadProvider!.getViewState == ViewState.LOADING
                      ? Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 15.0),
                          child: CircularProgressIndicator(),
                        )
                      : Container(),
                  _audioUploadProvider!.getViewState == ViewState.LOADING
                      ? Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 15.0),
                          child: CircularProgressIndicator(),
                        )
                      : Container(),
                  _fileUploadProvider!.getViewState == ViewState.LOADING
                      ? Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: 15.0),
                          child: CircularProgressIndicator(),
                        )
                      : Container(),
                  Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30.0),
                              topRight: Radius.circular(30.0))),
                      child: chatControls()),
                  // showEmojiPicker
                  //     ? Container(child: emojiContainer())
                  //     : Container(),
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
                              animation: animation!),
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
        height: 220.0,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: GridView.count(
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 0.95,
            crossAxisCount: 3,
            children: [
              moreMenuItem(Icons.camera_enhance, 'Image', () async {
                bool isBlocked = await _chatMethods.isBlocked(
                    widget.receiver.uid, _currentUserId);
                if (isBlocked) {
                  toggleMenu();
                  pickImage(source: ImageSource.gallery);
                } else {
                  blockedDialog(context);
                }
              }, Colors.green),
              moreMenuItem(Icons.video_label, 'Video', () async {
                bool isBlocked = await _chatMethods.isBlocked(
                    widget.receiver.uid, _currentUserId);
                if (isBlocked) {
                  toggleMenu();
                  // pickVideo();
                } else {
                  blockedDialog(context);
                }
              }, Colors.pink),
              moreMenuItem(Icons.file_copy, 'File', () async {
                bool isBlocked = await _chatMethods.isBlocked(
                    widget.receiver.uid, _currentUserId);
                if (isBlocked) {
                  toggleMenu();
                  pickFile();
                } else {
                  blockedDialog(context);
                }
              }, Colors.orange),
              moreMenuItem(Icons.scanner, 'Scan Text', () async {
                bool isBlocked = await _chatMethods.isBlocked(
                    widget.receiver.uid, _currentUserId);
                if (isBlocked) {
                  setState(() {
                    isWriting = true;
                  });
                  toggleMenu();
                  parseText();
                } else {
                  blockedDialog(context);
                }
              }, Colors.purple),
              moreMenuItem(Icons.picture_as_pdf, 'Text to Pdf', () async {
                bool isBlocked = await _chatMethods.isBlocked(
                    widget.receiver.uid, _currentUserId);
                if (isBlocked) {
                  toggleMenu();
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => TextRecognitionWidget(
                  //             receiverId: widget.receiver.uid)));
                } else {
                  blockedDialog(context);
                }
              }, Colors.red),
              moreMenuItem(Icons.location_on, 'Location', () async {
                bool isBlocked = await _chatMethods.isBlocked(
                    widget.receiver.uid, _currentUserId);
                if (isBlocked) {
                  setState(() {
                    isWriting = true;
                  });
                  toggleMenu();
                  Position position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high);

                  GeoPoint x = GeoPoint(position.latitude, position.longitude);
                  Message _message = Message(
                    receiverId: widget.receiver.uid,
                    senderId: sender.uid,
                    message: "location",
                    position: x,
                    timestamp: Timestamp.now(),
                    type: 'location',
                    isRead: false,
                    isLocation: true,
                  );

                  setState(() {
                    isWriting = false;
                  });

                  _chatMethods.addMessageToDb(_message);
                  sendNotification(
                      _message.message.toString(),
                      sender.name.toString(),
                      widget.receiver.firebaseToken.toString());
                } else {
                  blockedDialog(context);
                }
              }, Colors.blue),
            ],
          ),
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
          Container(
            height: 60.0,
            width: 60.0,
            decoration: BoxDecoration(
              color: color.withOpacity(0.7),
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: Stack(
              children: [
                MyArc(
                  diameter: 60.0,
                  color: color,
                ),
                Center(
                  child: Icon(
                    icon,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Text(
            name,
            style: TextStyle(color: Colors.black, fontSize: 16.0),
          )
        ],
      ),
    );
  }

  // emojiContainer() {
  //   return EmojiPicker(
  //     bgColor: UniversalVariables.separatorColor,
  //     indicatorColor: UniversalVariables.blueColor,
  //     rows: 3,
  //     columns: 7,
  //     onEmojiSelected: (emoji, category) {
  //       setState(() {
  //         isWriting = true;
  //       });
  //       textFieldController.text = textFieldController.text + emoji.emoji;
  //     },
  //     recommendKeywords: ["face", "happy", "party", "sad"],
  //     numRecommended: 50,
  //   );
  // }

  Widget messageList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(_currentUserId)
          .collection(widget.receiver.uid!)
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
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return chatMessageItem(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  _start() async {
    try {
      bool result = await record.hasPermission();
      // if (await Permissions.recordingPermission()) {
      var ran = Random().nextInt(50);
      String path = Utils.generateRandomString(ran);
      Io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
      path = appDocDirectory.path + '/' + path;

      // await record.start(
      //   path: path,
      //   encoder: AudioEncoder.AAC,
      //   bitRate: 128000,
      // );
      await recorder.record(path);
      bool isRecording = await record.isRecording();
      // bool isRecording = await recorder.toggleRecording(path);

      setState(() {
        // _recording = new Recording(duration: new Duration(), path: "");
        _isRecording = isRecording;
      });
      // } else {
      //   print("No permissions");
      // }
    } catch (e) {
      print(e);
    }
  }

  _stop() async {
    // var recording = await record.stop();
    String recording = await recorder.stop();

    bool isRecording = await record.isRecording();
    File file = File(recording);
    _storageMethods.uploadAudio(
        audio: file,
        receiverId: widget.receiver.uid!,
        senderId: _currentUserId,
        audioUploadProvider: _audioUploadProvider!);
    sendNotification("Audio", sender.name.toString(),
        widget.receiver.firebaseToken.toString());

    setState(() {
      // _recording = recording;
      _isRecording = isRecording;
    });
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data() as Map<String, dynamic>) ;

    return _message.type != "Call"
        ? GestureDetector(
            onLongPress: () {
              setState(() {
                if (_message.type == MESSAGE_TYPE_IMAGE)
                  forwardedImage = _message.photoUrl!;
                messageId = snapshot.id;
                _isAppBarOptions = true;
                forwardMessageText = _message.message!;
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
                        padding: EdgeInsets.only(left: 8.0),
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
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0)),
          ),
          SizedBox(height: 2.0),
          (formatTime(_message.timestamp!.toDate()))
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
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            actions: [
              TextButton(
                child:
                    Text('Yes', style: Theme.of(context).textTheme.bodyLarge),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection(MESSAGES_COLLECTION)
                      .doc(_currentUserId)
                      .collection(widget.receiver.uid!)
                      .doc(id)
                      .delete();
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('No', style: Theme.of(context).textTheme.bodyLarge),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  getMessage(Message message) {
    bool lineColor = message.senderId == _currentUserId;
    final replyMessage = message.replyMessage;
    final isReplying = replyMessage != null;
    final messageWidget = Text(
      message.message!,
      style: TextStyle(color: Colors.white, fontSize: 16.0),
    );
    if (message.replyMessage == null) {
      return messageWidget;
    } else {
      return Column(
        crossAxisAlignment:
            isReplying ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          !isReplying
              ? Container()
              : isReplying
                  ? Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0))),
                      child: IntrinsicHeight(
                          child: Row(
                        children: [
                          Container(
                            color: lineColor ? Colors.blue : Colors.green,
                            width: 4,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.receiver.name!,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                ],
                              ),
                              Text(
                                replyMessage!.message!,
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ))
                        ],
                      )),
                    )
                  : Container(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: messageWidget,
          )
        ],
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

    return Text(date,
        style: TextStyle(
          fontSize: 10.0,
          color: Theme.of(context).textTheme.bodyLarge!.color,
        ));
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = Radius.circular(35.0);
    if (message.isLocation = true && message.type == MESSAGE_TYPE_LOCATION) {
      return GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => showMap(
                  receiver: widget.receiver,
                  isSender: true,
                  pos: message.position!,
                ))),
        child: Container(
            height: 60.0,
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                gradient: LinearGradient(colors: [Colors.green, Colors.teal])),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 30.0,
                  color: Colors.orange,
                ),
                Text(
                  'Location',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                )
              ],
            )),
      );
    }
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
                          url: message.audioUrl!,
                          isSender: true,
                        )),
                    SizedBox(height: 2.0),
                    formatTime(message.timestamp!.toDate()),
                  ],
                ),
                Icon(message.isRead! ? Icons.done_all_outlined : Icons.done,
                    size: 20.0,
                    color: message.isRead!
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
                            url: message.videoUrl!,
                          )
                        : Icon(Icons.sync_problem)),
              ),
              SizedBox(height: 2.0),
              formatTime(message.timestamp!.toDate()),
            ],
          ),
          Icon(message.isRead!  ? Icons.done_all_outlined : Icons.done,
              size: 20.0,
              color:
                  message.isRead!  ? Colors.blue : Theme.of(context).splashColor)
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
                                    fileViewPage(url: message.fileUrl!))),
                        child: pdfWidget(message.fileUrl!, true)),
                    SizedBox(height: 2.0),
                    formatTime(message.timestamp!.toDate()),
                  ],
                ),
                Icon(message.isRead!  ? Icons.done_all_outlined : Icons.done,
                    size: 20.0,
                    color: message.isRead!
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
                        child: CachedImage(message.photoUrl!,
                            height: 250,
                            width: 250,
                            radius: 10,
                            isTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ImagePage(
                                          imageUrl: message.photoUrl!,
                                          imageUrlList: imageUrlList,
                                        )))),
                      ),
                    ),
                    SizedBox(height: 2.0),
                    formatTime(message.timestamp!.toDate()),
                  ],
                ),
                SizedBox(
                  width: 2.0,
                ),
                Icon(message.isRead! ? Icons.done_all_outlined : Icons.done,
                    size: 20.0,
                    color: message.isRead!
                        ? Colors.blue
                        : Theme.of(context).splashColor)
              ],
            )
          : Icon(Icons.sync_problem);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SwipeTo(
          iconColor: Colors.white,
          onLeftSwipe: () {
            replyToMessage(message);
            textFieldFocus.requestFocus();
          },
          child: Column(
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
                  child: getMessage(message),
                ),
              ),
              SizedBox(
                height: 2.0,
              ),
              formatTime(message.timestamp!.toDate()),
            ],
          ),
        ),
        SizedBox(
          width: 2.0,
        ),
        Icon(message.isRead! ? Icons.done_all_outlined : Icons.done,
            size: 20.0,
            color: message.isRead! ? Colors.blue : Theme.of(context).splashColor)
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
    if (message.isLocation = true && message.type == 'location') {
      return GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => showMap(
                  receiver: widget.receiver,
                  isSender: false,
                  pos: message.position!,
                ))),
        child: Container(
            height: 60.0,
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade900])),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 30.0,
                  color: Colors.orange,
                ),
                Text(
                  'Location',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                )
              ],
            )),
      );
    }
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
                      url: message.audioUrl!,
                      isSender: false,
                    )),
                SizedBox(height: 2.0),
                formatTime(message.timestamp!.toDate()),
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
                        url: message.videoUrl!,
                      )
                    : Icon(Icons.sync_problem)),
          ),
          SizedBox(height: 2.0),
          formatTime(message.timestamp!.toDate()),
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
                          fileViewPage(url: message.fileUrl!))),
                  child: pdfWidget(message.fileUrl!, false),
                ),
                SizedBox(height: 2.0),
                formatTime(message.timestamp!.toDate()),
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
                    child: CachedImage(message.photoUrl!,
                        height: 250,
                        width: 250,
                        radius: 10,
                        isTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ImagePage(
                                      imageUrl: message.photoUrl!,
                                      imageUrlList: imageUrlList,
                                    )))),
                  ),
                ),
                SizedBox(height: 2.0),
                formatTime(message.timestamp!.toDate()),
              ],
            )
          : Icon(Icons.sync_problem);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwipeTo(
          iconColor: Colors.white,
          onRightSwipe: () {
            replyToMessage(message);
            textFieldFocus.requestFocus();
          },
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
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
          ),
        ),
        SizedBox(
          height: 2.0,
        ),
        formatTime(message.timestamp!.toDate())
      ],
    );
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    sendMessage(context) async {
      var text = textFieldController.text;
      textFieldFocus.unfocus();

      Message _message = Message(
          receiverId: widget.receiver.uid,
          senderId: sender.uid,
          message: text,
          timestamp: Timestamp.now(),
          type: 'text',
          isRead: false,
          replyMessage: replyMessage);

      setState(() {
        isWriting = false;
      });

      textFieldController.text = "";

      bool isBlocked =
          await _chatMethods.isBlocked(widget.receiver.uid, _currentUserId);
      bool isMuted =
          await _chatMethods.isMuted(widget.receiver.uid!, _currentUserId);

      if (isBlocked) {
        _chatMethods.addMessageToDb(_message);

        if (!isMuted) {
          sendNotification(_message.message.toString(), sender.name.toString(),
              widget.receiver.firebaseToken.toString());
        }
      } else {
        blockedDialog(context);
      }
      cancelReply();
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () async {
              toggleMenu();
              // bool isBlocked = await _chatMethods.isBlocked(
              //     widget.receiver.uid, _currentUserId);
              // if (isBlocked) {
              //   toggleMenu();
              // } else {
              //   blockedDialog(context);
              // }
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
            child: Column(
              children: [
                replyMessage != null ? replyMessageWidget() : Container(),
                Stack(
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
                          hintStyle: Theme.of(context).textTheme.bodyMedium,
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
                      onPressed: () async {
                        bool isBlocked = await _chatMethods.isBlocked(
                            widget.receiver.uid, _currentUserId);
                        if (isBlocked) {
                          if (!showEmojiPicker) {
                            // keyboard is visible
                            hideKeyboard();
                            showEmojiContainer();
                          } else {
                            //keyboard is hidden
                            showKeyboard();
                            hideEmojiContainer();
                          }
                        } else {
                          blockedDialog(context);
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
                          onPressed: () async {
                            var ran = Random().nextInt(50);
                            String path = Utils.generateRandomString(ran);
                            Io.Directory appDocDirectory =
                                await getApplicationDocumentsDirectory();
                            path = appDocDirectory.path + '/' + path;
                            _isRecording = await recorder.toggleRecording(path);

                            _stop();
                            setState(() {
                              isRecordStart = false;
                            });
                          },
                        )
                      : IconButton(
                          icon: Icon(Icons.mic_none_outlined),
                          onPressed: () async {
                            bool isBlocked = await _chatMethods.isBlocked(
                                widget.receiver.uid, _currentUserId);

                            if (isBlocked) {
                              var ran = Random().nextInt(50);
                              String path = Utils.generateRandomString(ran);
                              Io.Directory appDocDirectory =
                                  await getApplicationDocumentsDirectory();
                              path = appDocDirectory.path + '/' + path;

                              _start();
                              setState(() {
                                isRecordStart = true;
                              });
                            } else {
                              blockedDialog(context);
                            }
                          },
                        ),
                ),
          isWriting
              ? Container()
              : GestureDetector(
                  child: Icon(Icons.camera_alt),
                  onTap: () async {
                    bool isBlocked = await _chatMethods.isBlocked(
                        widget.receiver.uid, _currentUserId);
                    if (isBlocked) {
                      pickImage(source: ImageSource.camera);
                    } else {
                      blockedDialog(context);
                    }
                  },
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
    FilePickerResult? path = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (path != null) {
      _storageMethods.uploadFile(
          file: File(path.paths[0]!),
          receiverId: widget.receiver.uid!,
          senderId: _currentUserId,
          fileUploadProvider: _fileUploadProvider!);
      sendNotification("FILE", sender.name.toString(),
          widget.receiver.firebaseToken.toString());
    }
  }

  Future<AlertDialog?> blockedDialog(BuildContext context) {
    return showDialog<AlertDialog>(
        context: context,
        barrierDismissible: false,
        builder: ((context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(5.0),
            actionsPadding: EdgeInsets.all(5.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Theme.of(context).cardColor,
            title: Text('You have been blocked!'),
            actions: [
              InkWell(
                child: Text(
                  'OK',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () => Navigator.pop(context),
              )
            ],
          );
        }));
  }

  Future pickImage({required ImageSource source}) async {
    this.setState(() {
      _isEditing = true;
    });
    File? selectedImage = await Utils.pickImage(source: source);
    if (selectedImage != null) {
      final cropped = await ImageCropper().cropImage(
          sourcePath: selectedImage.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 80,
          maxHeight: 700,
          maxWidth: 700,
          uiSettings: [AndroidUiSettings(
            toolbarColor: Theme.of(context).colorScheme.background,
            toolbarTitle: "Edit Image",
            // statusBarColor: Theme.of(context).backgroundColor,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: Colors.teal,
            toolbarWidgetColor: Theme.of(context).iconTheme.color,
          )],) as File;
      bool isBlocked =
          await _chatMethods.isBlocked(widget.receiver.uid, _currentUserId);
      if (isBlocked) {
        _storageMethods.uploadImage(
          image: cropped,
          receiverId: widget.receiver.uid!,
          senderId: _currentUserId,
          imageUploadProvider: _imageUploadProvider!,
        );
        sendNotification("IMAGE", sender.name.toString(),
            widget.receiver.firebaseToken.toString());
      } else {
        blockedDialog(context);
      }

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
  //   final Trimmer _trimmer = Trimmer();
  //   PickedFile video = await ImagePicker().getVideo(
  //       source: ImageSource.gallery, maxDuration: Duration(minutes: 5));
  //   await _trimmer.loadVideo(videoFile: File(video.path));
  //   Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  //     return TrimmerView(
  //       trimmerFile: _trimmer,
  //       receiver: widget.receiver.uid,
  //       sender: _currentUserId,
  //     );
  //   }));
  //   if (video != null) {
  //     videoPlayerController = VideoPlayerController.file(File(video.path))
  //       ..initialize().then((_) {
  //         setState(() {
  //           videoPlayerController.play();
  //         });
  //       });
  //   }
  //   sendNotification("Video", sender.name.toString(),
  //       widget.receiver.firebaseToken.toString());
  // }

  Future<void> downloadFile(String imagePath) async {
    Dio dio = Dio();

    dio.download(forwardedImage ?? noImageAvailable, imagePath,
        onReceiveProgress: (actualBytes, totalBytes) {});
  }

  CustomAppBar optionsAppBar(context) {
    return CustomAppBar(
      onTap: () {},
      isLeadingWidth: false,
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
            String path = '${dir!.path}/$imageFilePath.jpg';
            await downloadFile(path);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ForwardPage(
                          message: forwardMessageText,
                          imagePath: path,
                        )));
          },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
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
          // Get.to(ProfilePage(
          //   user: widget.receiver,
          // )),
          Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ProfilePage(
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
                widget.receiver.profilePhoto!,
                radius: 35.0,
                isTap: () => {}
              )),
          SizedBox(
            width: 6.0,
          ),
          Text(
            widget.receiver.name!,
            style: GoogleFonts.patuaOne(
                textStyle: Theme.of(context).textTheme.bodyLarge,
                fontSize: 20.0,
                letterSpacing: 1.5),
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
            color: Theme.of(context).iconTheme.color,
            icon: GradientIcon(
              FontAwesomeIcons.video,
              25.0,
              LinearGradient(
                colors: <Color>[
                  Colors.blue.shade500,
                  Colors.lightBlue.shade800
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            onPressed: () async {
              // Message _message = Message(
              //   receiverId: widget.receiver.uid,
              //   senderId: sender.uid,
              //   message: "Call",
              //   timestamp: Timestamp.now(),
              //   type: 'Call',
              // );
              bool isBlocked = await _chatMethods.isBlocked(
                  widget.receiver.uid, _currentUserId);
              if (isBlocked) {
                await Permissions.cameraAndMicrophonePermissionsGranted()
                    // ignore: unnecessary_statements
                    ? {
                        CallUtils.dial(
                          from: sender,
                          to: widget.receiver,
                          context: context,
                        ),
                        // _chatMethods.addMessageToDb(_message)
                      }
                    : [];
              } else {
                blockedDialog(context);
              }
            }),
        SizedBox(width: 2),
        PopupMenuButton(
            padding: EdgeInsets.all(4.0),
            color: Theme.of(context).canvasColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Icon(
              Icons.more_vert,
              color: Theme.of(context).iconTheme.color,
              size: 30.0,
            ),
            // child: Icon(Icons.menu),
            itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: FutureBuilder(
                      future: _chatMethods.isBlocked(
                          _currentUserId, widget.receiver.uid),
                      builder: (context, AsyncSnapshot<bool> snapshot) =>
                          GestureDetector(
                        onTap: () {
                          _chatMethods.addToBlockedList(
                              senderId: _currentUserId,
                              receiverId: widget.receiver.uid);
                        },
                        child: Text(
                          snapshot.data == true ? 'Block' : 'Unblock',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: FutureBuilder(
                      future: _chatMethods.isMuted(
                          _currentUserId, widget.receiver.uid!),
                      builder: (context, AsyncSnapshot<bool> snapshot) =>
                          GestureDetector(
                        onTap: () {
                          _chatMethods.addToMutedList(
                              senderId: _currentUserId,
                              receiverId: widget.receiver.uid);
                        },
                        child: Text(
                          snapshot.data == false ? 'Mute' : 'Unmute',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  )
                ])
      ],
    );
  }

  void replyToMessage(Message message) {
    setState(() {
      replyMessage = message;
    });
  }

  void cancelReply() {
    setState(() {
      replyMessage = null;
    });
  }

  replyMessageWidget() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
      child: IntrinsicHeight(
          child: Row(
        children: [
          Container(
            color: Colors.green,
            width: 4,
          ),
          SizedBox(width: 8),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.receiver.name!,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    child: Icon(Icons.close, color: Colors.red, size: 16.0),
                    onTap: cancelReply,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                ],
              ),
              Text(
                replyMessage!.message!,
                style: TextStyle(color: Colors.white),
              )
            ],
          ))
        ],
      )),
    );
  }
}
