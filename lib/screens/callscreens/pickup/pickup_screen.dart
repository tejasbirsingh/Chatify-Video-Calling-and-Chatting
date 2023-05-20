import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:chatify/constants/strings.dart';
import 'package:chatify/models/call.dart';
import 'package:chatify/models/log.dart';
import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/resources/call_methods.dart';
import 'package:chatify/resources/local_db/repository/log_repository.dart';
import 'package:chatify/screens/callscreens/call_screen.dart';

import 'package:chatify/screens/chatscreens/widgets/cached_image.dart';

import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:chatify/utils/permissions.dart';

class PickupScreen extends StatefulWidget {
  final Call call;

  PickupScreen({
    required this.call,
  });

  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final CallMethods callMethods = CallMethods();
  // final LogRepository logRepository = LogRepository(isHive: true);
  // final LogRepository logRepository = LogRepository(isHive: false);

  bool isCallMissed = true;

  addToLocalStorage({required String callStatus}) {
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
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            userProvider.getUser.firstColor != null
                ? Color(userProvider.getUser.firstColor ?? Colors.white.value)
                : Theme.of(context).colorScheme.background,
            userProvider.getUser.secondColor != null
                ? Color(userProvider.getUser.secondColor ?? Colors.white.value)
                : Theme.of(context).scaffoldBackgroundColor,
          ]),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Incoming Call",
              style: GoogleFonts.patuaOne(
                  textStyle: TextStyle(
                      fontSize: 30,
                      color: Theme.of(context).textTheme.displayLarge!.color)),
            ),
            SizedBox(height: 30),
            CachedImage(
              widget.call.callerPic!,
              isRound: false,
              radius: 200,
              height: 200.0,
              width: 200.0,
            ),
            SizedBox(height: 15),
            Text(widget.call.callerName!,
                style: Theme.of(context).textTheme.displayLarge),
            SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(60.0),
                  ),
                 
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
                       
                          : [];
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
                
                    child: GestureDetector(
                      onTap: () async {
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
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
