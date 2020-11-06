import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class audioPlayerClass extends StatefulWidget {
  final String url;

  const audioPlayerClass({Key key, this.url}) : super(key: key);
  @override
  _audioPlayerClassState createState() => _audioPlayerClassState();
}

class _audioPlayerClassState extends State<audioPlayerClass> {
  bool _isPlaying = false;
  AudioPlayer audioPlayer;
  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
  }

  playAudio(path) async {
    int response = await audioPlayer.play(path);
    if (response == 1) {
      // success

    } else {
      print('Some error occured in playing from storage!');
    }
  }

  pauseAudio() async {
    int response = await audioPlayer.pause();
    if (response == 1) {
      // success

    } else {
      print('Some error occured in pausing');
    }
  }

  stopAudio() async {
    int response = await audioPlayer.stop();
    if (response == 1) {
      // success

    } else {
      print('Some error occured in stopping');
    }
  }

  resumeAudio() async {
    int response = await audioPlayer.resume();
    if (response == 1) {
      // success

    } else {
      print('Some error occured in resuming');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.mic,
          ),
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
             onPressed: () {
                if (_isPlaying == true) {
                  pauseAudio();
                  setState(() {
                    _isPlaying = false;
                  });
                } else {
                  resumeAudio();
                  setState(() {
                    _isPlaying = true;
                  });
                }
              },
          ),
        
       IconButton(icon: Icon(Icons.play_circle_fill),
        onPressed: () async {
              setState(() {
                _isPlaying = true;
              });
              playAudio(widget.url);
            },)
        ],
      ),
    );
  }
}
