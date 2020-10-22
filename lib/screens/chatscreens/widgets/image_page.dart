import 'package:flutter/material.dart';
import 'package:skype_clone/utils/utilities.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';

class ImagePage extends StatefulWidget {
  final String imageUrl;
  final List<String> imageUrlList ;
  ImagePage({@required this.imageUrl,this.imageUrlList});
  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  final String noImageAvailable =
      "https://www.esm.rochester.edu/uploads/NoPhotoAvailable.jpg";
  String downloadedMessage = 'Initializing...';
  bool _isDownloading = false;
  double _percentage = 0;
  String fileName;
  @override
  initState() {
    super.initState();
    fileName = Utils.generateRandomString(15);
  }

  Future<void> downloadFile() async {
    var dir = await getExternalStorageDirectory();
    Dio dio = Dio();

    dio.download(
        widget.imageUrl ?? noImageAvailable, '${dir.path}/${fileName}.jpg',
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
    print(widget.imageUrlList);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded),
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
              child: Hero(
            tag: widget.imageUrl,
            child: PhotoView(
              imageProvider: NetworkImage(
                widget.imageUrl,
              ),

              //enableRotation: true,
            ),
          )),
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
                          horizontal: MediaQuery.of(context).size.width * 0.2),
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
    );
  }
}
