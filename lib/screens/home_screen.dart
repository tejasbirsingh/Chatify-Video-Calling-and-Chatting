import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:skype_clone/BottomBar/bar_item.dart';

import 'package:skype_clone/enum/user_state.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';
import 'package:skype_clone/resources/local_db/repository/log_repository.dart';
import 'package:skype_clone/screens/callscreens/pickup/pickup_layout.dart';
import 'package:skype_clone/screens/pageviews/chats/chat_list_screen.dart';
import 'package:skype_clone/screens/pageviews/friends/contacts_page.dart';
import 'package:skype_clone/screens/pageviews/logs/log_screen.dart';
import 'package:skype_clone/screens/search_screen.dart';


class HomeScreen extends StatefulWidget {
  final List<BarItem> barItems = [
    BarItem(
      text: "Chats",
      iconData: Icons.chat,
      color: Colors.indigo,
    ),
    BarItem(text: "Search", iconData: Icons.search, color: Colors.green),
    BarItem(
      text: "Contacts",
      iconData: Icons.contacts,
      color: Colors.pinkAccent,
    ),
    BarItem(
      text: "Calls",
      iconData: Icons.call,
      color: Colors.yellow.shade900,
    ),
  ];
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  PageController pageController;
  int _page = 0;
  UserProvider userProvider;

  final AuthMethods _authMethods = AuthMethods();
  // final LogRepository _logRepository = LogRepository(isHive: true);
  // final LogRepository _logRepository = LogRepository(isHive: false);

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();

      _authMethods.setUserState(
        userId: userProvider.getUser.uid,
        userState: UserState.Online,
      );

      LogRepository.init(
        isHive: true,
        dbName: userProvider.getUser.uid,
      );
    });

    WidgetsBinding.instance.addObserver(this);

    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId =
        (userProvider != null && userProvider.getUser != null)
            ? userProvider.getUser.uid
            : "";

    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Online)
            : print("resume state");
        break;
      case AppLifecycleState.inactive:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("inactive state");
        break;
      case AppLifecycleState.paused:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Waiting)
            : print("paused state");
        break;
      case AppLifecycleState.detached:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("detached state");
        break;
    }
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
    
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    // double _labelFontSize = 10;

    return PickupLayout(
      scaffold: SafeArea(
              child: Scaffold(
          // backgroundColor: UniversalVariables.blackColor,
          backgroundColor:Theme.of(context).backgroundColor,
          body: PageView(
            children: <Widget>[
              
              ChatListScreen(),
              SearchScreen(),
              Center(child: contactsPage()),
              LogScreen(),
            ],
            controller: pageController,
            onPageChanged: onPageChanged,
            physics: NeverScrollableScrollPhysics(),
          ),
          bottomNavigationBar: AnimatedBottomBar(
              barItems: widget.barItems,
              animationDuration: const Duration(milliseconds: 150),
              barStyle: BarStyle(fontSize: 20.0, iconSize: 30.0),
              onBarTap: (index) {
                setState(() {
                  _page = index;
                });
                navigationTapped(_page);
              }),
          // bottomNavigationBar: Container(
          //   child: Padding(
          //     padding: EdgeInsets.symmetric(vertical: 10),
          //     child: CupertinoTabBar(
          //       backgroundColor: UniversalVariables.blackColor,
          //       items: <BottomNavigationBarItem>[
          //         BottomNavigationBarItem(
          //           icon: Icon(Icons.chat,
          //               color: (_page == 0)
          //                   ? UniversalVariables.lightBlueColor
          //                   : UniversalVariables.greyColor),
          //           title: Text(
          //             "Chats",
          //             style: TextStyle(
          //                 fontSize: _labelFontSize,
          //                 color: (_page == 0)
          //                     ? UniversalVariables.lightBlueColor
          //                     : Colors.grey),
          //           ),
          //         ),
          //         BottomNavigationBarItem(
          //           icon: Icon(Icons.call,
          //               color: (_page == 1)
          //                   ? UniversalVariables.lightBlueColor
          //                   : UniversalVariables.greyColor),
          //           title: Text(
          //             "Calls",
          //             style: TextStyle(
          //                 fontSize: _labelFontSize,
          //                 color: (_page == 1)
          //                     ? UniversalVariables.lightBlueColor
          //                     : Colors.grey),
          //           ),
          //         ),
          //         BottomNavigationBarItem(
          //           icon: Icon(Icons.contact_phone,
          //               color: (_page == 2)
          //                   ? UniversalVariables.lightBlueColor
          //                   : UniversalVariables.greyColor),
          //           title: Text(
          //             "Contacts",
          //             style: TextStyle(
          //                 fontSize: _labelFontSize,
          //                 color: (_page == 2)
          //                     ? UniversalVariables.lightBlueColor
          //                     : Colors.grey),
          //           ),
          //         ),
          //       ],
          //       onTap: navigationTapped,
          //       currentIndex: _page,
          //     ),
          //   ),
          // ),
        ),
      ),
    );
  }
}
