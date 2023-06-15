import 'package:carousel_slider/carousel_slider.dart';
import 'package:chatify/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/screens/chatscreens/widgets/cached_image.dart';
import 'package:chatify/utils/utilities.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

class ImagePage extends StatefulWidget {
  final String imageUrl;
  final List<String> imageUrlList;
  ImagePage({required this.imageUrl, required this.imageUrlList});
  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  String downloadedMessage = 'Initializing...';
  bool _isDownloading = false;
  double _percentage = 0;
  String? fileName;
  int initialPage = 0;
  String? imageDownloadUrl;
  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.imageUrlList.length; i++) {
      if (widget.imageUrlList[i] == widget.imageUrl) {
        setState(() {
          initialPage = i;
          imageDownloadUrl = widget.imageUrl;
        });
      }
    }

    fileName = Utils.generateRandomString(15);
  }

  Future<void> downloadFile() async {
    var dir = await getExternalStorageDirectory();
    Dio dio = Dio();

    try {
      await dio.download(
        imageDownloadUrl ?? Constants.NO_IMAGE_AVAILABLE_URL,
        '${dir!.path}/$fileName.jpg',
        onReceiveProgress: (actualBytes, totalBytes) {
          var percentage = actualBytes / totalBytes * 100;

          setState(() {
            _isDownloading = true;
            downloadedMessage = 'Downloading... ${percentage.floor()}%';
          });

          if (percentage == 100) {
            setState(() {
              _isDownloading = false;
              downloadedMessage = 'Download completed. Image saved to gallery.';
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        downloadedMessage = 'Failed to download the file.';
      });
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    userProvider.getUser.firstColor != null
                        ? Color(userProvider.getUser.firstColor ??
                            Colors.white.value)
                        : Theme.of(context).colorScheme.background,
                    userProvider.getUser.secondColor != null
                        ? Color(userProvider.getUser.secondColor ??
                            Colors.white.value)
                        : Theme.of(context).scaffoldBackgroundColor,
                  ]),
                ),
                padding: EdgeInsets.symmetric(vertical: 20.0),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: CarouselSlider(
                  options: CarouselOptions(
                      onPageChanged: (idx, reason) {
                        setState(() {
                          imageDownloadUrl = widget.imageUrlList[idx];
                        });
                      },
                      enlargeCenterPage: true,
                      height: MediaQuery.of(context).size.height * 0.6,
                      enableInfiniteScroll: false,
                      viewportFraction: 0.95,
                      enlargeStrategy: CenterPageEnlargeStrategy.scale,
                      initialPage: initialPage),
                  items: widget.imageUrlList
                      .map((item) => Container(
                            child: CachedImage(
                              item,
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width * 0.8,
                            ),
                          ))
                      .toList(),
                )),
            _isDownloading
                ? Center(
                    child: Column(
                    children: [
                      Text(
                        downloadedMessage,
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
          ],
        ),
      ),
    );
  }
}
