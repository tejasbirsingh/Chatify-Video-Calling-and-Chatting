import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skype_clone/constants/strings.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/screens/App%20Settings/blocked_contacts.dart';

class privacyPage extends StatefulWidget {
  @override
  _privacyPageState createState() => _privacyPageState();
}

class _privacyPageState extends State<privacyPage> {
  bool _appLocked = false;

  @override
  void initState() {
    super.initState();
    getSwitchValues();
  }

  getSwitchValues() async {
    _appLocked = await getAppLocker();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
          
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context)),
              centerTitle: false,
              title: Text('Privacy',
                  style: GoogleFonts.oswald(
                      textStyle: Theme.of(context).textTheme.headline1,
                      fontSize: 26.0)),
              iconTheme: Theme.of(context).iconTheme),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                userProvider.getUser.firstColor != null
                    ? Color(
                        userProvider.getUser.firstColor ?? Colors.white.value)
                    : Theme.of(context).backgroundColor,
                userProvider.getUser.secondColor != null
                    ? Color(
                        userProvider.getUser.secondColor ?? Colors.white.value)
                    : Theme.of(context).scaffoldBackgroundColor,
              ]),
            ),
            child: ListView(
              children: [
                SizedBox(
                  height: 40.0,
                ),
                ListTile(
                  leading: Icon(
                    Icons.lock,
                    color: Colors.purple,
                    size: 32.0,
                  ),
                  title: Text(
                    'App Locker',
                    style: GoogleFonts.patuaOne(
                        letterSpacing: 1.0,
                        textStyle: Theme.of(context).textTheme.headline1),
                  ),
                  contentPadding: const EdgeInsets.only(left: 16.0),
                  trailing: Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      inactiveTrackColor: Theme.of(context).dividerColor,
                      activeColor: Colors.green,
                      value: _appLocked,
                      onChanged: (bool val) {
                        setState(() {
                          _appLocked = val;
                          setAppLocker(val);
                        });
                      },
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => blockedContacts())),
                  child: ListTile(
                    leading:
                        Icon(Icons.block_outlined, size: 32, color: Colors.red),
                    trailing: Icon(Icons.arrow_forward_ios),
                    title: Text('Blocked Contacts',
                      style: GoogleFonts.patuaOne(
                        letterSpacing: 1.0,
                        textStyle: Theme.of(context).textTheme.headline1),),
                  ),
                )
              ],
            ),
          )),
    );
  }

  Future<bool> getAppLocker() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _appLocked =
          prefs.getBool('isLocked') != null ? prefs.getBool('isLocked') : false;
    });
    return _appLocked;
  }

  Future<bool> setAppLocker(bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLocked', val);
    return val;
  }
}
