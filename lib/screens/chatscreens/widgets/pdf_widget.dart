import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skype_clone/constants/strings.dart';
import 'package:skype_clone/utils/utilities.dart';

Future<void> downloadFile(String url, String fileName) async {
  var dir = await getExternalStorageDirectory();
  Dio dio = Dio();

  dio.download(url ?? noImageAvailable, '${dir.path}/${fileName}.pdf',
      onReceiveProgress: (actualBytes, totalBytes) {
    var percentage = actualBytes / totalBytes * 100;
  });
}

Widget pdfWidget(String url,bool isSender) {
  String fileName = Utils.generateRandomString(15);
  return Stack(
    children: [
      Container(
        child: Center(
          child: Text(
            'PDF',
            style: GoogleFonts.patuaOne(fontSize: 40.0, color: Colors.black),
          ),
        ),
        height: 100.0,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
        width: 160.0,
      ),
      SizedBox(height: 20.0),
      Positioned(
        bottom: 0.0,
        child: Container(
          height: 30.0,
          width: 160.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  icon: Icon(
                    Icons.download_rounded,
                  ),
                  onPressed: () async {
                    await downloadFile(url, fileName);
                  }),
            ],
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
              gradient: LinearGradient(colors:isSender?  [Colors.green, Colors.teal] : [Colors.blue.shade700, Colors.blue.shade900])),
        ),
      ),
    ],
  );
}
