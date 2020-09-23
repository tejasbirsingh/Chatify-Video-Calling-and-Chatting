import 'package:flutter/material.dart';
import 'package:skype_clone/screens/chatscreens/widgets/chewie_player.dart';
import 'package:video_player/video_player.dart';
import 'package:velocity_x/velocity_x.dart';

class videoPage extends StatelessWidget {
  final String url;

  const videoPage({Key key, this.url}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: "Video".text.white.extraBold.makeCentered(),),
      backgroundColor: Colors.black,
      body: ChewieListItem(videoPlayerController: VideoPlayerController.network(url))
    );
  }
}