import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';

class ImagePage extends StatefulWidget {
  final String imageUrl;
  ImagePage({@required this.imageUrl});
  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  final String noImageAvailable =
      "https://www.esm.rochester.edu/uploads/NoPhotoAvailable.jpg";
  bool downloading = false;

  String progress = '0';

  bool isDownloaded = false;

  String fileName;
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
    setState(() {
      downloading = true;
    });
    String savePath = await getFilePath(fileName);
    Dio dio = Dio();
    dio.download(
      widget.imageUrl,
      savePath,
      onReceiveProgress: (rcv, total) {
        // print('received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');

        setState(() {
          progress = ((rcv / total) * 100).toStringAsFixed(0);
        });

        if (progress == '100') {
          setState(() {
            isDownloaded = true;
          });
        } else if (double.parse(progress) < 100) {}
      },
      deleteOnError: true,
    ).then((_) {
      setState(() {
        if (progress == '100') {
          isDownloaded = true;
        }

        downloading = false;
      });
    });
  }

  Future<String> getFilePath(uniqueFileName) async {
    String path = '';
    Directory dir = await getApplicationDocumentsDirectory();
    path = '${dir.path}/$uniqueFileName.png';
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded),
            onPressed: () async {
               downloadFile();
            },
          )
        ],
        leading: IconButton(   
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          downloading ? CircularProgressIndicator() : SizedBox(),
          SizedBox(height: 10),
          downloading ? Text(progress) : SizedBox(),
          Container(
              child: Hero(
            tag: widget.imageUrl,
            child: PhotoView(
              imageProvider: NetworkImage(
                widget.imageUrl,
              ),

              //enableRotation: true,
            ),
          )),
        ],
      ),
    );
  }
}
