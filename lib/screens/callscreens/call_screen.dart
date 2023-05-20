import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:chatify/configs/agora_configs.dart';
import 'package:chatify/models/call.dart';
import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/resources/call_methods.dart';

class CallScreen extends StatefulWidget {
  final Call call;

  CallScreen({
    required this.call,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallMethods callMethods = CallMethods();
  int? _remoteUid;
  UserProvider? userProvider;
  StreamSubscription? callStreamSubscription;
  RtcEngine? _engine;
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;

  @override
  void initState() {
    super.initState();
    addPostFrameCallback();
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    // await _engine!.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration(dimensions: VideoDimensions(width: 1920, height: 1080));
    await _engine!.setVideoEncoderConfiguration(configuration);

    await _engine!.joinChannel(
        token: widget.call.callerId!,
        channelId: widget.call.channelId!,
        options: const ChannelMediaOptions(),
        uid: 0);
    // print(widget.call.channelId);
  }

  addPostFrameCallback() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);

      callStreamSubscription = callMethods
          .callStream(uid: userProvider!.getUser.uid)
          .listen((DocumentSnapshot ds) {
        // defining the logic
        switch (ds.data()) {
          case null:
            // snapshot is null which means that call is hanged and documents are deleted
            Navigator.pop(context);
            break;

          default:
            break;
        }
      });
    });
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: APP_ID,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
    await _engine!.enableVideo();
    await _engine!.startPreview();
    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine!.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
      debugPrint("local user ${connection.localUid} joined");
      setState(() {
        final info = 'onJoinChannel: ${connection.channelId}, uid: ${connection.localUid}';
        _infoStrings.add(info);
      });
    }, onLeaveChannel: (RtcConnection connection, RtcStats rtcStats) {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    }, onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
      debugPrint("remote user $remoteUid joined");
      setState(() {
        final info = 'userJoined: ${connection.localUid}';
        _remoteUid = remoteUid;
        _infoStrings.add(info);
        _users.add(connection.localUid!);
      });
    }, onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
      setState(() {
        final info = 'userOffline: ${connection.localUid}';
         _remoteUid = null;
        _infoStrings.add(info);
        _users.remove(connection.localUid);
      });
    }, onFirstRemoteVideoFrame: (RtcConnection connection, uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

List<Widget> _remoteVideo() {
  List<StatefulWidget> list = [];
    if (_remoteUid != null) {
      return [AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.call.channelId),
        ),
      )];
    } else {
      return [const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      )];
    }

  }

  // List<Widget> _getRenderViews() {
  //   final List<StatefulWidget> list = [];
  //   // if (widget.call.callerId == ClientRole.Broadcaster) {
  //   //   list.add(RtcLocalView.SurfaceView());
  //   // }
  //     list.add(SurfaceView());
  //   _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
  //   return list;
  // }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _remoteVideo();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine!.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine!.switchCamera();
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic : Icons.mic_off,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () {
              callMethods.endCall(
                call: widget.call,
              );
              Navigator.pop(context);
            },
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine!.leaveChannel();
    // _engine!.destroy();
    callStreamSubscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            // _panel(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}
