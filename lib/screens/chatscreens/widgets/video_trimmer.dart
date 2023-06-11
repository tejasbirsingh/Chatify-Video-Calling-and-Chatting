import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatify/provider/video_upload_provider.dart';
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
  var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<void> _saveVideo(VideoUploadProvider _videoUploadProvider) async {
    setState(() {
      _progressVisibility = true;
    });

    await widget.trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      videoFileName: getRandomString(15),
      onSave: (String? outputFilePath) {
        if (outputFilePath != null) {
          final File videoFile = File(outputFilePath);
          _storageMethods.uploadVideo(
            video: videoFile,
            receiverId: widget.receiver,
            senderId: widget.sender,
            videoUploadProvider: _videoUploadProvider,
          );
        }
        setState(() {
          _progressVisibility = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    VideoUploadProvider _videoUploadProvider =
        Provider.of<VideoUploadProvider>(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
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
                    color: Colors.white,
                    // backgroundColor: Colors.black,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _progressVisibility
                          ? null
                          : () async {
                              await _saveVideo(_videoUploadProvider);
                              final snackBar = SnackBar(
                                content:
                                    Text(Strings.videoSavedSnackBarContent),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                              Navigator.pop(context);
                            },
                      child: Text(Strings.send),
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
                    editorProperties:
                        TrimEditorProperties(circlePaintColor: Colors.white),
                    viewerHeight: 80.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    durationTextStyle: TextStyle(color: Colors.white),
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
                          size: 40.0,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.play_arrow,
                          size: 40.0,
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
