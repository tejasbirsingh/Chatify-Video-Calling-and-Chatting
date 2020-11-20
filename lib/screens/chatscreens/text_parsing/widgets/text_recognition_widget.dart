import 'dart:io';
import 'dart:io' as Io;
import 'package:clipboard/clipboard.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/screens/chatscreens/text_parsing/firebase_api_handler.dart';
import 'package:skype_clone/screens/chatscreens/text_parsing/pdf_view_screen.dart';
import 'package:skype_clone/screens/chatscreens/text_parsing/widgets/controls_widgets.dart';
import 'package:skype_clone/screens/chatscreens/text_parsing/widgets/text_area_widget.dart';
import 'package:skype_clone/utils/utilities.dart';

class TextRecognitionWidget extends StatefulWidget {
  final String receiverId;
  const TextRecognitionWidget({Key key, this.receiverId}) : super(key: key);

  @override
  _TextRecognitionWidgetState createState() => _TextRecognitionWidgetState();
}

class _TextRecognitionWidgetState extends State<TextRecognitionWidget> {
  String ocrText = 'No text scanned';
  File image;
  final pdf = pw.Document();
  String fileName;

  @override
  void initState() {
    super.initState();
    setState(() {
      fileName = Utils.generateRandomString(15);
    });
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Image to Pdf",
              style: GoogleFonts.oswald(
                  textStyle: TextStyle(
                      color: Theme.of(context).textTheme.headline1.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 28.0))),
          iconTheme: Theme.of(context).iconTheme,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              userProvider.getUser.firstColor != null
                  ? Color(userProvider.getUser.firstColor ?? Colors.white.value)
                  : Theme.of(context).backgroundColor,
              userProvider.getUser.secondColor != null
                  ? Color(
                      userProvider.getUser.secondColor ?? Colors.white.value)
                  : Theme.of(context).scaffoldBackgroundColor,
            ]),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              children: [
                Container(
                    height: 260.0,
                    width: 260.0,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color:
                                Theme.of(context).textTheme.headline1.color)),
                    child: buildImage()),
                SizedBox(height: 5.0),
                ControlsWidget(
                  onClickedGallery: pickImageGallery,
                  onClickedCamera: pickImageCamera,
                  onClickedScanText: scanText,
                  onClickedClear: clear,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton(
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      onPressed: () async {
                        if (ocrText != "" && ocrText != "No text scanned") {
                          await writePdf();
                          await savePdf();
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          Text(
                            "Add Page",
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    RaisedButton(
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      onPressed: () async {
                        await savePdf();
                        setState(() {
                          ocrText = "No text scanned";
                        });
                        clear();
                        Io.Directory documentDirectory =
                            await getApplicationDocumentsDirectory();

                        String documentPath = documentDirectory.path;
                        String path = "$documentPath/$fileName.pdf";
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => pdfPreviewScreen(
                                  path: path,
                                  receiverId: widget.receiverId,
                                )));
                      },
                      child: Text("View",
                          style: Theme.of(context).textTheme.headline1),
                    )
                  ],
                ),
                SizedBox(height: 5.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextAreaWidget(
                    text: ocrText,
                    onClickedCopy: copyToClipboard,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
    String documentPath = documentDirectory.path;
    Io.File file = Io.File("$documentPath/$fileName.pdf");
    file.writeAsBytesSync(pdf.save());
  }

  Widget buildImage() => Container(
        child: image != null
            ? Image.file(
                image,
                color: Theme.of(context).iconTheme.color,
              )
            : Icon(Icons.photo, size: 80, color: Colors.black),
      );

  Future pickImageGallery() async {
    final file = await ImagePicker().getImage(source: ImageSource.gallery);
    setImage(File(file.path));
  }

  Future pickImageCamera() async {
    final file = await ImagePicker().getImage(source: ImageSource.camera);
    setImage(File(file.path));
  }

  Future scanText() async {
    showDialog(
      context: context,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );

    final text = await FirebaseMLApi.recogniseText(image);
    setText(text);
    Navigator.of(context).pop();
  }

  void clear() {
    setImage(null);
    setText('');
  }

  void copyToClipboard() {
    if (ocrText.trim() != '') {
      FlutterClipboard.copy(ocrText);
    }
  }

  void setImage(File newImage) {
    setState(() {
      image = newImage;
    });
  }

  void setText(String newText) {
    setState(() {
      ocrText = newText;
    });
  }
}
