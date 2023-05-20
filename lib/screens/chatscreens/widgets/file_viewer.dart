import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';



class fileViewPage extends StatefulWidget {
  final String url;

  const fileViewPage({Key? key, required this.url}) : super(key: key);
  @override
  _fileViewPageState createState() => _fileViewPageState();
}

class _fileViewPageState extends State<fileViewPage> {
  bool _isLoading = true;
  late PDFDocument document;

  @override
  void initState() {
    super.initState();
    loadDocument();
    // print(widget.url);
  }

  loadDocument() async {
    document = await PDFDocument.fromURL(widget.url);
    setState(() => _isLoading = false);
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: Scaffold(
        
           appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.foregroundColor,
            iconTheme: Theme.of(context).iconTheme,
            title: Text('Pdf Document'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),

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