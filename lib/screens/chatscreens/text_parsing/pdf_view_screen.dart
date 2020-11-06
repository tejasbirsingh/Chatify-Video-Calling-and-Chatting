import 'dart:io';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype_clone/provider/file_provider.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/chat_methods.dart';
import 'package:skype_clone/resources/storage_methods.dart';

class pdfPreviewScreen extends StatefulWidget {
  final String path;
  final String receiverId;
  pdfPreviewScreen({this.path, this.receiverId});

  @override
  _pdfPreviewScreenState createState() => _pdfPreviewScreenState();
}

class _pdfPreviewScreenState extends State<pdfPreviewScreen> {
  bool _isLoading = true;
  PDFDocument document;
  String userId;
  FileUploadProvider _fileUploadProvider;
  final StorageMethods _storageMethods = StorageMethods();
  final ChatMethods _chatMethods = ChatMethods();
  File file;
  @override
  void initState() {
    super.initState();
    loadDocument();
    file = File(widget.path);
  }

  loadDocument() async {
    document = await PDFDocument.fromAsset(widget.path);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    _fileUploadProvider = Provider.of<FileUploadProvider>(context);
    UserProvider user = Provider.of<UserProvider>(context);
    setState(() {
      userId = user.getUser.uid;
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          'Pdf File',
          style: Theme.of(context).textTheme.headline1,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.reply),
            onPressed: () {
              if (file != null && widget.receiverId != null) {
                _storageMethods.uploadFile(
                    file: file,
                    receiverId: widget.receiverId,
                    senderId: userId,
                    fileUploadProvider: _fileUploadProvider);
              }

              Navigator.pop(context);
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Center(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : PDFViewer(
                document: document,
                zoomSteps: 1,
                lazyLoad: false,
                navigationBuilder:
                    (context, page, totalPages, jumpToPage, animateToPage) {
                  return ButtonBar(
                    alignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.first_page),
                        onPressed: () {
                          jumpToPage(page: 0);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          animateToPage(page: page - 2);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: () {
                          animateToPage(page: page);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.last_page),
                        onPressed: () {
                          jumpToPage(page: totalPages - 1);
                        },
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

//   final pdf = pw.Document();

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//           child: PDFViewerScaffold(
//         path: widget.path,
// appBar: AppBar(
//   backgroundColor: Theme.of(context).backgroundColor,
//   iconTheme: Theme.of(context).iconTheme,
//   leading: IconButton(
//     icon: Icon(Icons.arrow_back),
//     onPressed: () => Navigator.pop(context),
//   ),
// ),
//       ),
//     );
//   }
