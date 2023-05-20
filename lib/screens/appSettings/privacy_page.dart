import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/screens/appSettings/blocked_contacts.dart';


/*
  It contains App locker and blocked contacts settings.
*/
class PrivacyPage extends StatefulWidget {
  @override
  _PrivacyPageState createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
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
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 26.0)),
              iconTheme: Theme.of(context).iconTheme),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                userProvider.getUser.firstColor != null
                    ? Color(
                        userProvider.getUser.firstColor ?? Colors.white.value)
                    : Theme.of(context).colorScheme.background,
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
                        textStyle: Theme.of(context).textTheme.displayLarge),
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
                      builder: (context) => BlockedContacts())),
                  child: ListTile(
                    leading:
                        Icon(Icons.block_outlined, size: 32, color: Colors.red),
                    trailing: Icon(Icons.arrow_forward_ios),
                    title: Text(
                      'Blocked Contacts',
                      style: GoogleFonts.patuaOne(
                          letterSpacing: 1.0,
                          textStyle: Theme.of(context).textTheme.displayLarge),
                    ),
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
      _appLocked = prefs.getBool('isLocked') != null
          ? prefs.getBool('isLocked')!
          : false;
    });
    return _appLocked;
  }

  Future<bool> setAppLocker(bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLocked', val);
    return val;
  }
}
