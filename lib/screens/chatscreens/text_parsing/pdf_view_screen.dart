import 'dart:io';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:chatify/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:chatify/provider/file_provider.dart';
import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/resources/storage_methods.dart';

class PdfPreviewScreen extends StatefulWidget {
  final String? path;
  final String? receiverId;
  PdfPreviewScreen({this.path, this.receiverId});

  @override
  _pdfPreviewScreenState createState() => _pdfPreviewScreenState();
}

class _pdfPreviewScreenState extends State<PdfPreviewScreen> {
  bool _isLoading = true;
  var document;
  String? userId;
  FileUploadProvider? _fileUploadProvider;
  final StorageMethods _storageMethods = StorageMethods();
  File? file;

  @override
  void initState() {
    super.initState();
    loadDocument();
    file = File(widget.path!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadDocument() async {
    document = await PDFDocument.fromAsset(widget.path!);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    _fileUploadProvider = Provider.of<FileUploadProvider>(context);
    final UserProvider user = Provider.of<UserProvider>(context);
    setState(() {
      userId = user.getUser.uid;
    });
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          iconTheme: Theme.of(context).iconTheme,
          title: Text(
            Strings.pdfFile,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.reply, color: Colors.lightBlue),
              onPressed: () {
                _storageMethods.uploadFile(
                    file: file!,
                    receiverId: widget.receiverId!,
                    senderId: userId!,
                    fileUploadProvider: _fileUploadProvider!);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.share,
                color: Colors.teal,
              ),
              onPressed: () {
                Share.shareFiles([widget.path!], text: Strings.shareDocument);
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
                            animateToPage(page: page! - 2);
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
                            jumpToPage(page: totalPages! - 1);
                          },
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}
