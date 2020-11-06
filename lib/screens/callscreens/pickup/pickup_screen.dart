
import 'package:flutter/material.dart';

import 'package:skype_clone/constants/strings.dart';
import 'package:skype_clone/models/call.dart';
import 'package:skype_clone/models/log.dart';
import 'package:skype_clone/resources/call_methods.dart';
import 'package:skype_clone/resources/local_db/repository/log_repository.dart';
import 'package:skype_clone/screens/callscreens/call_screen.dart';

import 'package:skype_clone/screens/chatscreens/widgets/cached_image.dart';

import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:skype_clone/utils/permissions.dart';

class PickupScreen extends StatefulWidget {
  final Call call;

  PickupScreen({
    @required this.call,
  });

  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final CallMethods callMethods = CallMethods();
  // final LogRepository logRepository = LogRepository(isHive: true);
  // final LogRepository logRepository = LogRepository(isHive: false);

  bool isCallMissed = true;

  addToLocalStorage({@required String callStatus}) {
    Log log = Log(
      callerName: widget.call.callerName,
      callerPic: widget.call.callerPic,
      receiverName: widget.call.receiverName,
      receiverPic: widget.call.receiverPic,
      timestamp: DateTime.now().toString(),
      callStatus: callStatus,
    );

    LogRepository.addLogs(log);
  }

  @override
  void initState() {
    super.initState();
    FlutterRingtonePlayer.playRingtone();
  }

  @override
  void dispose() {
    if (isCallMissed) {
      addToLocalStorage(callStatus: CALL_STATUS_MISSED);
    }
    FlutterRingtonePlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Incoming Call",
              style: TextStyle(
                  fontSize: 30,
                  color: Theme.of(context).textTheme.headline1.color),
            ),
            SizedBox(height: 50),
            CachedImage(
              widget.call.callerPic,
              isRound: true,
              radius: 200,
            ),
            SizedBox(height: 15),
            Text(widget.call.callerName,
                style: Theme.of(context).textTheme.headline1),
            SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(60.0),
                  ),
                  // child: IconButton(
                  //     icon: Icon(Icons.call),
                  //     color: Colors.white,
                  //     onPressed: () async {
                  //       FlutterRingtonePlayer.stop();
                  //       isCallMissed = false;
                  //       addToLocalStorage(callStatus: CALL_STATUS_RECEIVED);
                  //       await Permissions.cameraAndMicrophonePermissionsGranted()
                  //           ? Navigator.push(
                  //               context,
                  //               MaterialPageRoute(
                  //                 builder: (context) =>
                  //                     CallScreen(call: widget.call),
                  //               ),
                  //             )
                  //           // ignore: unnecessary_statements
                  //           : {};
                  //     }),
                  child: GestureDetector(
                      onTap: () async {
                        FlutterRingtonePlayer.stop();
                        isCallMissed = false;
                        addToLocalStorage(callStatus: CALL_STATUS_RECEIVED);
                        await Permissions.cameraAndMicrophonePermissionsGranted()
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CallScreen(call: widget.call),
                                ),
                              )
                            // ignore: unnecessary_statements
                            : {};
                      },
                    child: Container(
                      width: 70.0,
                      height: 70.0,
                      child: FlareActor(
                        "assets/call_pick.flr",
                        animation: 'Record2',
  
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 35),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(60.0),
                  ),
                  // child: IconButton(
                  //   icon: Icon(Icons.call_end),
                  //   color: Colors.white,
                  //   onPressed: () async {
                  //     FlutterRingtonePlayer.stop();
                  //     isCallMissed = false;
                  //     addToLocalStorage(callStatus: CALL_STATUS_RECEIVED);
                  //     await callMethods.endCall(call: widget.call);
                  //   },
                  // ),
                  child:GestureDetector(
                    onTap: ()async {
                      FlutterRingtonePlayer.stop();
                      isCallMissed = false;
                      addToLocalStorage(callStatus: CALL_STATUS_RECEIVED);
                      await callMethods.endCall(call: widget.call);
                    },
                    child: Container(
                      width: 70.0,
                    height: 70.0,
                    child: FlareActor(
                      "assets/call_end.flr",
                      animation: 'Record2',
                    ),
                    ),
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
