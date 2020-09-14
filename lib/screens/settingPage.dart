import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as Im;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skype_clone/Theme/theme_colors.dart';
import 'package:skype_clone/Theme/theme_provider.dart';
import 'package:skype_clone/constants/strings.dart';
import 'package:skype_clone/models/userData.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';

import 'package:skype_clone/resources/update_methods.dart';
import 'package:skype_clone/widgets/skype_appbar.dart';



// ignore: camel_case_types
class settingPage extends StatefulWidget {
  @override
  _settingPageState createState() => _settingPageState();
}

// ignore: camel_case_types
class _settingPageState extends State<settingPage> {
 var _darkTheme = true;
  File imageFile;
  final picker =ImagePicker();
  final UpdateMethods _updateMethods = UpdateMethods();
 AuthMethods authUser = AuthMethods();
  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context,listen: true);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
final String noImageUrl = "https://www.google.com/search?q=no+image&rlz=1C1CHBF_enIN802IN802&sxsrf=ALeKk026xztGQvA9DCX0yfejmBRaP8UXTA:1599745232866&tbm=isch&source=iu&ictx=1&fir=NF-z0Y67xzPPBM%252C029W-ajBtZqZzM%252C_&vet=1&usg=AI4_-kQZgZPDLdtCSE-P_wyfcTCySoOtjw&sa=X&ved=2ahUKEwjZ5Ney297rAhUa73MBHRZWD7QQ9QF6BAgKEC4#imgrc=NF-z0Y67xzPPBM";
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    return SafeArea(
      child: Scaffold(
       
        appBar: SkypeAppBar(title: Text('Settings'), actions: [
          IconButton(icon: Icon(Icons.arrow_back_ios),
          onPressed: ()=>Navigator.of(context).pop(),)
        ]),
        body:  ListView(
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                     StreamBuilder<DocumentSnapshot>(                      
                      stream: FirebaseFirestore.instance.collection(USERS_COLLECTION).doc(userProvider.getUser.uid).snapshots(),
                      builder: (context, snapshot) {
                      if(snapshot.hasData){
                           print('this the url ${snapshot.data.data()["profile_photo"] }');
                          String url =  snapshot.data.data()['profile_photo'];
                      
                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width / 2 - 100.0),
                            title: GestureDetector(
                              onTap: () => _showImageDialog(context,userProvider.getUser),
                              child: CircleAvatar(
                                radius: 100.0,                
                               backgroundImage: url != null ?NetworkImage(url) : NetworkImage(noImageUrl),
                               
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Icon(
                                    Icons.photo_camera,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                ),
                              ),
                            ),
                        );
                      }
                 else { 
                   return ListTile(
                     leading: CircularProgressIndicator(),
                   );
                 }
                      }    
                    ),
                   
                    ListTile(
                      title: Text('Dark Mode'),
                      contentPadding: const EdgeInsets.only(left: 16.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _darkTheme,
                          onChanged: (val) {
                            setState(() {
                              _darkTheme = val;
                            });
                            onThemeChanged(val, themeNotifier);
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      
                      title: Text("Name"),
                      subtitle:    Text(userProvider.getUser.name),
                      trailing: IconButton(icon: Icon(Icons.edit), onPressed: (){
                             
                      }),
                    ),
                     ListTile(
                      
                      title: Text("Email"),
                      subtitle:    Text(userProvider.getUser.email),
                      trailing: IconButton(icon: Icon(Icons.edit), onPressed: (){
                              
                      }),
                    ),
                    
                  ],
                ),
      ),
    );
  }
  Future<File> _pickImage(String action) async {
    PickedFile selectedImage;

    action == 'Gallery'
        ? selectedImage =
            await picker.getImage(source: ImageSource.gallery)
        : await picker.getImage(source: ImageSource.camera);
    File file = File(selectedImage.path);
    return file;
  }

  void onThemeChanged(bool value, ThemeNotifier themeNotifier) async {
    (value)
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }

  Future<AlertDialog>_showImageDialog(BuildContext context,UserData user) {
    return showDialog<AlertDialog>(
        context: context,
        barrierDismissible: false,
        builder: ((context) {
          return SimpleDialog(
            
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Choose from Gallery'),
                onPressed: () {
                  _pickImage('Gallery').then((selectedImage) {
                    setState(() {
                      imageFile = selectedImage;
                    });
                    compressImage();
                    _updateMethods.uploadImageToStorage(imageFile).then((url) {
                      _updateMethods.updatePhoto(url, user.uid).then((v) {
                      //  Navigator.pop(context);

                      });
                    });
                  });
                },
              ),
              SimpleDialogOption(
                child: Text('Take Photo'),
                onPressed: () {
                  _pickImage('Camera').then((selectedImage) {
                    setState(() {
                      imageFile = selectedImage;
                    });
                    compressImage();
                    _updateMethods.uploadImageToStorage(imageFile).then((url) {
                      _updateMethods.updatePhoto(url, user.uid).then((v) {
                        //Navigator.pop(context);
             
                                });
                    });
                  });
                },
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        }));
  }

  void compressImage() async {
    print('Compression Started');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    Im.Image image = Im.decodeImage(imageFile.readAsBytesSync());
    Im.copyResize(image, width: 500, height: 500);

    var newim2 = new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));

    setState(() {
      imageFile = newim2;
    });
    print('Done');
  }
}