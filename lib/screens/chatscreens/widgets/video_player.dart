import 'package:flutter/material.dart';
import 'package:skype_clone/screens/chatscreens/video_viewer.dart';

import 'package:video_player/video_player.dart';

class videoPlayer extends StatefulWidget {
  final String url;

  const videoPlayer({Key key, this.url}) : super(key: key);
  @override
  _videoPlayerState createState() => _videoPlayerState();
}

class _videoPlayerState extends State<videoPlayer> {
  VideoPlayerController _videoPlayerController;
  bool _isplaying = false;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.url);
    _videoPlayerController
      ..initialize().then((_) {
        _videoPlayerController.setLooping(false);

        setState(() {});
        _videoPlayerController..addListener(() {});
      });
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(() {});
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _videoPlayerController.value.initialized
            ? GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => videoPage(
                                url: widget.url,
                              )));
                },
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: VideoPlayer(_videoPlayerController),
                ),
              )
            : Container(),
        Container(
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.9),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0))),
          child: Center(
              child: _isplaying == true
                  ? IconButton(
                      icon: Icon(
                        Icons.pause,
                        color: Colors.white,
                        size: 30.0,
                      ),
                      onPressed: () {
                        _videoPlayerController.pause();
                        setState(() {
                          _isplaying = false;
                        });
                      })
                  : IconButton(
                      icon: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30.0,
                      ),
                      onPressed: () {
                        _videoPlayerController.play();
                        setState(() {
                          _isplaying = true;
                        });
                      })),
        ),
      ],
    );
  }
}
