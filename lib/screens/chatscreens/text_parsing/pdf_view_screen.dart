
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';

import 'dart:io' as Io;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


class pdfPreviewScreen extends StatelessWidget {
    final pdf = pw.Document();
   
   
    
  final String path;
  pdfPreviewScreen({this.path});
    addPage() async{

     final font = await rootBundle.load("fonts/OpenSans-Light.ttf");
    final ttf = pw.Font.ttf(font);
    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
 build: (pw.Context context) {
          return <pw.Widget>[
            pw.Header(
                child: pw.Text('Document', style: pw.TextStyle(font: ttf))),
            pw.Paragraph(
                text: "", style: pw.TextStyle(font: ttf, fontSize: 20.0)),
          ];
        }

    ));
  }
  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
      path: path,
      appBar: AppBar(
          actions: [
            IconButton(icon: Icon(Icons.add), onPressed: (){
              
            })
          ],
        iconTheme: Theme.of(context).iconTheme,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: ()=>Navigator.pop(context),
        ),
      
      ),
    );
  }
}