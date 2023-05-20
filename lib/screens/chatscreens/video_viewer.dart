import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chatify/screens/chatscreens/widgets/chewie_player.dart';
import 'package:video_player/video_player.dart';


class VideoPage extends StatefulWidget {
  final String url;

  const VideoPage({Key? key, required this.url}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  String downloadedMessage = 'Initializing...';

  bool _isDownloading = false;

  double _percentage = 0;
  String fileName = "";
  @override
  initState() {
    super.initState();
    fileName = generateRandomString(15);
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  Future<void> downloadFile() async {
    var dir = await getExternalStorageDirectory();
    Dio dio = Dio();

    dio.download(widget.url, '${dir!.path}/${fileName}.mp4',
        onReceiveProgress: (actualBytes, totalBytes) {
      var percentage = actualBytes / totalBytes * 100;
      _percentage = percentage / 100;
      if (percentage == 100) {
        setState(() {
          _isDownloading = false;
        });
      }
      setState(() {
        downloadedMessage = 'Downloading...${percentage.floor()} % ';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Video", style: Theme.of(context).textTheme.headline1),
          actions: [
            IconButton(
              icon: Icon(Icons.download_sharp),
              onPressed: () async {
                downloadFile();
                setState(() {
                  _isDownloading = true;
                });
              },
            )
          ],
        ),
        backgroundColor: Colors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isDownloading
                ? Center(
                    child: Column(
                    children: [
                      Text(
                        downloadedMessage ?? '',
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.2),
                        child: LinearProgressIndicator(
                          value: _percentage,
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ))
                : Text(""),
                  SizedBox(
                        height: 20,
                      ),
            ChewieListItem(
                videoPlayerController:
                    VideoPlayerController.network(widget.url)),
          ],
        ));
  }
}
