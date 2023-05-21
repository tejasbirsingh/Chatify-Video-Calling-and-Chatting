// import 'dart:io';
// import 'dart:io' as Io;
// import 'package:clipboard/clipboard.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:chatify/provider/user_provider.dart';
// import 'package:chatify/screens/chatscreens/text_parsing/firebase_api_handler.dart';
// import 'package:chatify/screens/chatscreens/text_parsing/pdf_view_screen.dart';
// import 'package:chatify/screens/chatscreens/text_parsing/widgets/controls_widgets.dart';

// import 'package:chatify/screens/chatscreens/widgets/arc_class.dart';
// import 'package:chatify/utils/utilities.dart';

// class TextRecognitionWidget extends StatefulWidget {
//   final String receiverId;
//   const TextRecognitionWidget({Key? key, this.receiverId}) : super(key: key);

//   @override
//   _TextRecognitionWidgetState createState() => _TextRecognitionWidgetState();
// }

// class _TextRecognitionWidgetState extends State<TextRecognitionWidget> {
//   String ocrText = 'No text scanned';
//   File image;
//   final pdf = pw.Document();
//   String fileName;

//   @override
//   void initState() {
//     super.initState();
//     setState(() {
//       fileName = Utils.generateRandomString(15);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     UserProvider userProvider = Provider.of<UserProvider>(context);
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           elevation: 2.0,
//           title: Text("Image to Pdf",
//               style: GoogleFonts.oswald(
//                   textStyle: TextStyle(
//                       color: Theme.of(context).textTheme.headline1.color,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 26.0))),
//           iconTheme: Theme.of(context).iconTheme,
//         ),
//         body: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(colors: [
//               userProvider.getUser.firstColor != null
//                   ? Color(userProvider.getUser.firstColor ?? Colors.white.value)
//                   : Theme.of(context).backgroundColor,
//               userProvider.getUser.secondColor != null
//                   ? Color(
//                       userProvider.getUser.secondColor ?? Colors.white.value)
//                   : Theme.of(context).scaffoldBackgroundColor,
//             ]),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               SizedBox(height: 8.0),
//               Container(
//                   height: MediaQuery.of(context).size.height * 0.44,
//                   width: MediaQuery.of(context).size.width * 0.9,
//                   decoration: BoxDecoration(
//                       border: Border.all(
//                           color: Theme.of(context).textTheme.headline1.color)),
//                   child: buildImage()),
//               SizedBox(height: 5.0),
//               Container(
//                 width: MediaQuery.of(context).size.width * 0.9,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Theme.of(context).splashColor,
//                   ),
//                   gradient: LinearGradient(colors: [
//                     Theme.of(context).backgroundColor,
//                     Theme.of(context).scaffoldBackgroundColor
//                   ]),
//                 ),
//                 padding: EdgeInsets.all(8),
//                 alignment: Alignment.center,
//                 child: SelectableText(
//                   ocrText.isEmpty ? 'Scan an Image to get text' : ocrText,
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.bodyText1,
//                 ),
//               ),
//               SizedBox(height: 5.0),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   moreMenuItem(Icons.add, 'Add', () async {
//                     if (ocrText != "" && ocrText != "No text scanned" && ocrText!="No selected image") {
//                       await writePdf();
//                       await savePdf();
//                       clear();
//                     }
//                   }, Colors.teal),
//                   moreMenuItem(Icons.view_agenda, 'View', () async {
//                     // await savePdf();
//                     Io.Directory documentDirectory =
//                         await getApplicationDocumentsDirectory();
//                     String documentPath = documentDirectory.path;
//                     String path = "$documentPath/$fileName.pdf";
//                     Navigator.of(context).push(MaterialPageRoute(
//                         builder: (context) => PdfPreviewScreen(
//                               path: path,
//                               receiverId: widget.receiverId,
//                             )));
//                   }, Colors.amber),
//                   moreMenuItem(
//                       Icons.copy, 'Copy', copyToClipboard, Colors.green),
//                 ],
//               ),
//               SizedBox(height: 10.0),
//               ControlsWidget(
//                 context:context,
//                 onClickedGallery: pickImageGallery,
//                 onClickedCamera: pickImageCamera,
//                 onClickedScanText: scanText,
//                 onClickedClear: clear,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   GestureDetector moreMenuItem(
//       IconData icon, String name, GestureTapCallback fun, Color color) {
//     return GestureDetector(
//       onTap: fun,
//       child: Column(
//         children: [
//           Container(
//             height: 48.0,
//             width: 48.0,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(50.0),
//             ),
//             child: Stack(
//               children: [
//                 MyArc(
//                   diameter: 60.0,
//                   color: color,
//                 ),
//                 Center(
//                   child: Icon(
//                     icon,
//                     size: 28.0,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             name,
//             style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color, fontSize: 16.0),
//           )
//         ],
//       ),
//     );
//   }

//   writePdf() async {
//     final font = await rootBundle.load("fonts/OpenSans-Light.ttf");
//     final ttf = pw.Font.ttf(font);

//     pdf.addPage(
//       pw.MultiPage(
//           pageFormat: PdfPageFormat.a4,
//           margin: pw.EdgeInsets.all(32),
//           build: (pw.Context context) {
//             return <pw.Widget>[
//               pw.Header(
//                   child: pw.Text('Document', style: pw.TextStyle(font: ttf))),
//               pw.Paragraph(
//                   text: ocrText,
//                   style: pw.TextStyle(font: ttf, fontSize: 20.0)),
//             ];
//           }),
//     );
//   }

//   Future savePdf() async {
//     Io.Directory documentDirectory = await getApplicationDocumentsDirectory();
//     String documentPath = documentDirectory.path;
//     Io.File file = Io.File("$documentPath/$fileName.pdf");
//     file.writeAsBytes(await pdf.save());
//   }

//   Widget buildImage() => Container(
//         child: image != null
//             ? Image.file(
//                 image,
//                 // color: Theme.of(context).iconTheme.color,
//                fit:BoxFit.cover
//               )
//             : Icon(Icons.photo, size: 80, color: Colors.black),
//       );

//   Future pickImageGallery() async {
//     final file = await ImagePicker().getImage(source: ImageSource.gallery);
//     setImage(File(file.path));
//   }

//   Future pickImageCamera() async {
//     final file = await ImagePicker().getImage(source: ImageSource.camera);
//     setImage(File(file.path));
//   }

//   Future scanText() async {
//     showDialog(
//       context: context,
//      builder:(context){
//        return Center(
//         child: CircularProgressIndicator(),
//       );
//      }
//     );

//     final text = await FirebaseMLApi.recogniseText(image);
//     setText(text);
//     Navigator.of(context).pop();
//   }

//   void clear() {
//     setImage(null);
//     setText('');
//   }

//   void copyToClipboard() {
//     if (ocrText.trim() != '') {
//       FlutterClipboard.copy(ocrText);
//     }
//   }

//   void setImage(File newImage) {
//     setState(() {
//       image = newImage;
//     });
//   }

//   void setText(String newText) {
//     setState(() {
//       ocrText = newText;
//     });
//   }
// }
