import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skype_clone/Theme/theme_colors.dart';
import 'package:skype_clone/provider/theme_provider.dart';
import 'package:skype_clone/provider/image_upload_provider.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/provider/video_upload_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';
import 'package:skype_clone/screens/home_screen.dart';
import 'package:skype_clone/screens/login_screen.dart';
import 'package:skype_clone/screens/search_screen.dart';
import 'package:skype_clone/screens/settingPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //hides the status bar of the app
  // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]).then((_) {

  // });

  //transparent status bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
//  show statusbar
// SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

  SharedPreferences.getInstance().then((prefs) {
    var darkModeOn = prefs.getBool('darkTheme') ?? true;
    runApp(
      ChangeNotifierProvider<ThemeNotifier>(
        create: (_) =>
            ThemeNotifier(darkModeOn == true ? darkTheme : lightTheme),
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  final AuthMethods _authMethods = AuthMethods();
  bool _authorizedOrNot = false, _isLocked;
  static const platform = const MethodChannel('TokenChannel');
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String token;

  _getdeviceToken() async {
    await _firebaseMessaging.getToken().then((deviceToken) {
      setState(() {
        token = deviceToken.toString();
      });
    });
  }

  Future<void> _getLocker() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLocked = prefs.getBool('isLocked');
    });
    // print(_isLocked);
    if (_isLocked == true) {
      _authenticateMe();
    }
  }

  Future<void> _authenticateMe() async {
    bool authenticated = false;
    try {
      authenticated = await _localAuthentication.authenticateWithBiometrics(
        localizedReason: "Authenticate to use Chatify",
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } catch (e) {
      print(e);
    }
    if (!mounted) return;
    setState(() {
      _authorizedOrNot = authenticated ? true : false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getLocker();
    _getdeviceToken();
    sendData();
  }

  Future<void> sendData() async {
    String message;
    try {
      message = await platform.invokeMethod(token);
      // print(message);
    } on PlatformException catch (e) {
      message = "Failed to get data from native : '${e.message}'.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
// print("token is {$token}");
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
          ChangeNotifierProvider(
            create: (_) => VideoUploadProvider(),
          ),
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: MaterialApp(
            title: "Chatify",
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/search_screen': (context) => SearchScreen(),
              '/setting_page': (context) => settingPage(),
            },
            theme: themeNotifier.getTheme(),
            home: _authorizedOrNot == true || _isLocked == false
                ? FutureBuilder(
                    future: _authMethods.getCurrentUser(),
                    builder: (context, AsyncSnapshot<User> snapshot) {
                      if (snapshot.data != null) {
                        return HomeScreen();
                      } else {
                        return LoginScreen(token: token);
                      }
                    },
                  )
                : 
                // Container(child: Center(child: CircularProgressIndicator(),),)
                                 LoginScreen(token: token)
                                )
                );
  }
}
