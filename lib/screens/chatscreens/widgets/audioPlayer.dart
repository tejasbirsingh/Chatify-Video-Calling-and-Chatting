import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class audioPlayerClass extends StatefulWidget {
  final String url;
  final bool isSender;

  const audioPlayerClass({Key key, this.url, this.isSender}) : super(key: key);
  @override
  _audioPlayerClassState createState() => _audioPlayerClassState();
}

class _audioPlayerClassState extends State<audioPlayerClass> {
  AudioPlayer audioPlayer = AudioPlayer();
  Duration totalDuration;
  Duration position;
  String audioState;
  @override
  void initState() {
    super.initState();
    initAudio();
  }

  initAudio() {
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        totalDuration = newDuration;
      });
    });
    audioPlayer.onAudioPositionChanged.listen((updatesPosition) {
      setState(() {
        position = updatesPosition;
      });
    });
    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        position = Duration(milliseconds: 0);
        audioState = "stopped";
      });
    });

    audioPlayer.onPlayerStateChanged.listen((playerState) {
      setState(() {
        if (playerState == AudioPlayerState.STOPPED) {
          audioState = 'stopped';
        } else if (playerState == AudioPlayerState.PLAYING) {
          audioState = 'playing';
        } else if (playerState == AudioPlayerState.PAUSED) {
          audioState = 'paused';
        }
      });
    });
  }

  playAudio() async {
    await audioPlayer.play(widget.url);
  }

  pauseAudio() async {
    await audioPlayer.pause();
  }

  seekAudio(Duration dur) async {
    await audioPlayer.seek(dur);
  }

  @override
  Widget build(BuildContext context) {
    String curr = position.toString().split('.').first;
    if (curr == "null") curr = "0:0";

    String total = totalDuration.toString().split('.').first;
    if (total == "null") total = "0:0";
    return Stack(
      children: [
        Center(
          child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                        disabledThumbColor: Colors.yellow,
                        thumbColor: Colors.yellow,
                        trackHeight: 10,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        )),
                    child: Slider(
                      value: position == null ? 0 : position.inMilliseconds.toDouble(),
                      activeColor: widget.isSender ? Colors.blue : Colors.green,
                      inactiveColor: Colors.white,
                      onChanged: (val) {
                        seekAudio(Duration(milliseconds: val.toInt()));
                      },
                      min: 0,
                      max: totalDuration == null
                          ? 20
                          : totalDuration.inMilliseconds.toDouble(),
                    ),
                  ),
                  Text("${curr} / ${total} "),
                  IconButton(
                    color: Colors.white,
                    iconSize: 35.0,
                    icon:
                        Icon(audioState == "playing" ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      audioState == "playing" ? pauseAudio() : playAudio();
                    },
                  ),
                ],
              ),
            
        ),
          Positioned(child:   Icon(Icons.mic,
          size: 20.0,
          color: Colors.white,),
          left: 5.0,
          bottom: 5.0,)
      ],
    );
  }
}
