import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatify/provider/video_upload_provider.dart';
import 'package:chatify/resources/chat_methods.dart';
import 'package:chatify/resources/storage_methods.dart';

import 'package:video_trimmer/video_trimmer.dart';

import '../../../constants/strings.dart';

class TrimmerView extends StatefulWidget {
  final Trimmer trimmer;
  final String receiver;
  final String sender;

  TrimmerView(
      {required this.trimmer, required this.receiver, required this.sender});

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  StorageMethods _storageMethods = StorageMethods();
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  bool _progressVisibility = false;

  Future<String> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String _value = "";
    await widget.trimmer
        .saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (String? outputFilePath) {
        _value = outputFilePath!;
      },
    )
        .then((_) {
      setState(() {
        _progressVisibility = false;
      });
    });

    return _value;
  }

  @override
  Widget build(BuildContext context) {
    VideoUploadProvider _videoUploadProvider =
        Provider.of<VideoUploadProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Strings.videoTrimmer,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _progressVisibility
                          ? null
                          : () async {
                              final String outputPath = await _saveVideo();
                              if (outputPath.isNotEmpty) {
                                File videoFile = File(outputPath);

                                if (videoFile.existsSync()) {
                                  _storageMethods.uploadVideo(
                                    video: videoFile,
                                    receiverId: widget.receiver,
                                    senderId: widget.sender,
                                    videoUploadProvider: _videoUploadProvider,
                                  );
                                }
                                final snackBar = SnackBar(
                                  content:
                                      Text(Strings.videoSavedSnackBarContent),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);

                                Navigator.pop(context);
                              }
                              Navigator.pop(context);
                            },
                      child: Row(
                        children: [
                          Text(Strings.send),
                          Icon(
                            Icons.send,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        _storageMethods.uploadVideo(
                          video: File(widget.trimmer.toString()),
                          receiverId: widget.receiver,
                          senderId: widget.sender,
                          videoUploadProvider: _videoUploadProvider,
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: VideoViewer(
                    trimmer: widget.trimmer,
                  ),
                ),
                Center(
                  child: TrimViewer(
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    onChangeStart: (value) {
                      setState(() {
                        _startValue = value;
                      });
                    },
                    onChangeEnd: (value) {
                      setState(() {
                        _endValue = value;
                      });
                    },
                    onChangePlaybackState: (value) {
                      setState(() {
                        _isPlaying = value;
                      });
                    },
                    trimmer: widget.trimmer,
                  ),
                ),
                ElevatedButton(
                  child: _isPlaying
                      ? Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Colors.white,
                        ),
                  onPressed: () async {
                    bool playbackState =
                        await widget.trimmer.videoPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
