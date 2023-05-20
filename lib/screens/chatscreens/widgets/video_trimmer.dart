// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:skype_clone/provider/video_upload_provider.dart';
// import 'package:skype_clone/resources/chat_methods.dart';
// import 'package:skype_clone/resources/storage_methods.dart';

// import 'package:video_trimmer/video_trimmer.dart';

// class TrimmerView extends StatefulWidget {
//   final Trimmer trimmerFile;
//   final String receiver;
//   final String sender;
//   TrimmerView({this.trimmerFile, this.receiver, this.sender});
//   @override
//   _TrimmerViewState createState() => _TrimmerViewState();
// }

// class _TrimmerViewState extends State<TrimmerView> {
//   StorageMethods _storageMethods = StorageMethods();
//   double _startValue = 0.0;
//   double _endValue = 0.0;
//   ChatMethods _chatMethods = ChatMethods();
//   bool _isPlaying = false;
//   bool _progressVisibility = false;

//   Future<String> _saveVideo() async {
//     setState(() {
//       _progressVisibility = true;
//     });

//     String _value;
//     await widget.trimmerFile
//         .saveTrimmedVideo(
//             startValue: _startValue,
//             endValue: _endValue,
//             onSave: (String outputPath) {
//               return "gh";
//             })
//         .then((value) {
//       setState(() {
//         _progressVisibility = false;
//         _value = value;
//       });
//     });

//     return _value;
//   }

//   @override
//   Widget build(BuildContext context) {
//     VideoUploadProvider _videoUploadProvider =
//         Provider.of<VideoUploadProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Video Trimmer",
//           style: Theme.of(context).textTheme.displayLarge,
//         ),
//       ),
//       body: Builder(
//         builder: (context) => Center(
//           child: Container(
//             padding: EdgeInsets.only(bottom: 30.0),
//             color: Colors.black,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.max,
//               children: <Widget>[
//                 Visibility(
//                   visible: _progressVisibility,
//                   child: LinearProgressIndicator(
//                     backgroundColor: Colors.red,
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton(
//                       onPressed: _progressVisibility
//                           ? null
//                           : () async {
//                               _saveVideo().then((outputPath) async {
//                                 // print('OUTPUT PATH: $outputPath');
//                                 final snackBar = SnackBar(
//                                     content: Text('Video Saved successfully'));
//                                 ScaffoldMessenger.of(context)
//                                     .showSnackBar(snackBar);

//                                 _storageMethods.uploadVideo(
//                                     video: File(outputPath),
//                                     receiverId: widget.receiver,
//                                     senderId: widget.sender,
//                                     videoUploadProvider: _videoUploadProvider);
//                                 Navigator.pop(context);
//                               });
//                             },
//                       child: Row(
//                         children: [
//                           Text("Send"),
//                           Icon(
//                             Icons.send,
//                             color: Colors.green,
//                           )
//                         ],
//                       ),
//                     ),
//                     // IconButton(
//                     //   icon: Icon(Icons.send),
//                     //   onPressed: () {
//                     //     _storageMethods.uploadVideo(
//                     //         video: File(widget.trimmerFile.toString()),
//                     //         receiverId: widget.receiver,
//                     //         senderId: widget.sender,
//                     //         videoUploadProvider: _videoUploadProvider);
//                     //     Navigator.pop(context);
//                     //   },
//                     // )
//                   ],
//                 ),
//                 Expanded(
//                   child: VideoViewer(
//                     trimmer: null,
//                   ),
//                 ),
//                 Center(
//                   child: TrimViewer(
//                     viewerHeight: 50.0,
//                     viewerWidth: MediaQuery.of(context).size.width,
//                     onChangeStart: (value) {
//                       _startValue = value;
//                     },
//                     onChangeEnd: (value) {
//                       _endValue = value;
//                     },
//                     onChangePlaybackState: (value) {
//                       setState(() {
//                         _isPlaying = value;
//                       });
//                     },
//                     trimmer: null,
//                   ),
//                 ),
//                 ElevatedButton(
//                   child: _isPlaying
//                       ? Icon(
//                           Icons.pause,
//                           size: 80.0,
//                           color: Colors.white,
//                         )
//                       : Icon(
//                           Icons.play_arrow,
//                           size: 80.0,
//                           color: Colors.white,
//                         ),
//                   onPressed: () async {
//                     bool playbackState =
//                         await widget.trimmerFile.videoPlaybackControl(
//                       startValue: _startValue,
//                       endValue: _endValue,
//                     );
//                     setState(() {
//                       _isPlaying = playbackState;
//                     });
//                   },
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
