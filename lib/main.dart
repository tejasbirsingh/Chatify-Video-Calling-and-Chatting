import 'package:chatify/constants/navigation_routes_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatify/Theme/theme_colors.dart';
import 'package:chatify/provider/audio_upload_provider.dart';
import 'package:chatify/provider/file_provider.dart';
import 'package:chatify/provider/image_upload_provider.dart';
import 'package:chatify/provider/theme_provider.dart';
import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/provider/video_upload_provider.dart';
import 'package:chatify/resources/auth_methods.dart';
import 'package:chatify/screens/appSettings/setting_page.dart';
import 'package:chatify/screens/login_screen.dart';
import 'package:chatify/screens/search_screen.dart';
import 'package:chatify/screens/splash_screen.dart';
import 'constants/constants.dart';
import 'constants/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //transparent status bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  SharedPreferences.getInstance().then((prefs) {
    var darkModeOn = prefs.getBool(Constants.DARK_THEME) ?? true;
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
  bool _authorizedOrNot = false;
  bool? _isLocked;
  static const platform = const MethodChannel(Constants.TOKEN_CHANNEL);
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? token;

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
      _isLocked = prefs.getBool(Constants.IS_LOCKED)!;
    });
    if (_isLocked == true) {
      _authenticateMe();
    }
  }

  Future<void> _authenticateMe() async {
    bool authenticated = false;
    try {
      authenticated = await _localAuthentication.authenticate(
          localizedReason: Strings.authenticateToUse,
          options: const AuthenticationOptions(
              useErrorDialogs: false, biometricOnly: true, stickyAuth: true));
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
    _sendData();
  }

  Future<void> _sendData() async {
    String message;
    try {
      message = await platform.invokeMethod(token!);
      // print(message);
    } on PlatformException catch (e) {
      message = "Failed to get data from native : '${e.message}'.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
          ChangeNotifierProvider(
            create: (_) => VideoUploadProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => AudioUploadProvider(),
          ),
          ChangeNotifierProvider(create: (_) => FileUploadProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: MaterialApp(
            title: Strings.chatify,
            debugShowCheckedModeBanner: false,
            initialRoute: NavigationRoutesConstants.INTIAIL_ROUTE,
            routes: {
              NavigationRoutesConstants.SEARCH_SCREEN: (context) =>
                  SearchScreen(),
              NavigationRoutesConstants.SETTINGS_PAGE_ROUTE: (context) =>
                  SettingsPage(),
            },
            theme: themeNotifier.getTheme(),
            home: _authorizedOrNot == true || _isLocked == false
                ? FutureBuilder(
                    future: _authMethods.getCurrentUser(),
                    builder: (context, AsyncSnapshot<User> snapshot) {
                      if (snapshot.data != null) {
                        return SplashScreen();
                      } else {
                        return LoginScreen(token: token);
                      }
                    },
                  )
                : LoginScreen(token: token)));
  }
}
