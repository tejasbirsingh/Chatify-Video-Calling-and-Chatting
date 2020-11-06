import 'dart:convert';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as Io;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:skype_clone/screens/chatscreens/text_parsing/pdf_view_screen.dart';
import 'package:image/image.dart' as Im;
import 'package:skype_clone/utils/utilities.dart';

class imageToPdf extends StatefulWidget {
  @override
  _imageToPdfState createState() => _imageToPdfState();
}

class _imageToPdfState extends State<imageToPdf> {
  final pdf = pw.Document();
  bool _isEditing = false;
  String fileName;
  bool uploading = false;
  String ocrText = "Text will be shown here";
  TextEditingController _editingController;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: ocrText);
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  writePdf() async {
    final font = await rootBundle.load("fonts/OpenSans-Light.ttf");
    final ttf = pw.Font.ttf(font);
    pdf.addPage(
      pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return <pw.Widget>[
              pw.Header(
                  child: pw.Text('Document', style: pw.TextStyle(font: ttf))),
              pw.Paragraph(
                  text: ocrText,
                  style: pw.TextStyle(font: ttf, fontSize: 20.0)),
            ];
          }),
    );
  }

  Future savePdf() async {
    Io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    setState(() {
      fileName = Utils.generateRandomString(15);
    });
    String documentPath = documentDirectory.path;
    Io.File file = Io.File("$documentPath/$fileName.pdf");
    file.writeAsBytesSync(pdf.save());
  }

  parseText(ImageSource source) async {
    final imageFile = await ImagePicker()
        .getImage(source: source, maxHeight: 970, maxWidth: 670);
    var bytes = Io.File(imageFile.path.toString()).readAsBytesSync();
    String img64 = base64Encode(bytes);

    var url = 'https://api.ocr.space/parse/image';
    var payload = {"base64Image": "data:image/jpg;base64,${img64.toString()}"};
    var header = {"apikey": "d938f7220788957"};
    var post = await http.post(url, body: payload, headers: header);
    var result = jsonDecode(post.body);

    setState(() {
      uploading = false;
      ocrText = result['ParsedResults'][0]['ParsedText'];
    });
    _editingController.text = ocrText;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          iconTheme: Theme.of(context).iconTheme,
          title: Text(
            "Image to Pdf",
            style: GoogleFonts.staatliches(
                textStyle: TextStyle(
                    color: Theme.of(context).textTheme.headline1.color,
                    letterSpacing: 3.0,
                    fontWeight: FontWeight.bold,
                    fontSize: 28.0)),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: GestureDetector(
                  onTap: () {
                    parseText(ImageSource.camera);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 40.0, right: 40.0),
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          // color: Colors.purple,
                          gradient: LinearGradient(
                              colors: [Colors.green, Colors.teal])),
                      child: Center(
                        child: Text("Camera",
                            style: Theme.of(context).textTheme.headline1),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              GestureDetector(
                onTap: () {
                  parseText(ImageSource.gallery);
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 40.0, right: 40.0),
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width * 0.5,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        // color: Colors.purple,
                        gradient: LinearGradient(
                            colors: [Colors.green, Colors.teal])),
                    child: Center(
                      child: Text("Gallery",
                          style: Theme.of(context).textTheme.headline1),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              uploading == false ? Container() : CircularProgressIndicator(),
              SizedBox(height: 60.0),
              Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "Extracted Text:-",
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    editTextField(),
                  ],
                ),
              ),
              SizedBox(
                height: 80.0,
              ),
              Container(
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0)),
                  color: Colors.grey,
                  child: Text(
                    'Add Page to Pdf',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  onPressed: () async {
                    await writePdf();
                    _editingController.clear();
                  },
                ),
              ),
              Container(
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0)),
                  color: Colors.grey,
                  child: Text(
                    'Save and View Pdf of the text',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  onPressed: () async {
                    await savePdf();
                    Io.Directory documentDirectory =
                        await getApplicationDocumentsDirectory();

                    String documentPath = documentDirectory.path;
                    String Fpath = "$documentPath/$fileName.pdf";
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => pdfPreviewScreen(path: Fpath)));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget editTextField() {
    if (_isEditing) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: TextField(
          cursorColor: Colors.grey,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(color: Colors.green)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(color: Colors.green)),
            hintText: "Text will be shown here",
            hintStyle: Theme.of(context).textTheme.bodyText1,
            suffixIcon: IconButton(
              icon: Icon(Icons.content_copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: ocrText));
              },
            ),
          ),
          controller: _editingController,
          onSubmitted: (val) {
            setState(() {
              ocrText = val;
              _editingController.text = ocrText;

              _isEditing = false;
            });
          },
        ),
      );
    }
    return InkWell(
      onTap: () {
        setState(() {
          _isEditing = true;
        });
      },
      child: Container(
        child: Text(
          ocrText,
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
