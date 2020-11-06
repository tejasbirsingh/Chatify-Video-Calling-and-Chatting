import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:skype_clone/models/userData.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';
import 'package:skype_clone/screens/callscreens/pickup/pickup_layout.dart';
import 'package:skype_clone/screens/chatscreens/chat_screen.dart';
import 'package:skype_clone/screens/chatscreens/widgets/cached_image.dart';
import 'package:skype_clone/utils/universal_variables.dart';
import 'package:skype_clone/widgets/custom_tile.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AuthMethods _authMethods = AuthMethods();

  List<UserData> userList;
  List<String> friendsList;
  String query = "";
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _authMethods.getCurrentUser().then((User user) {
      _authMethods.fetchAllUsers(user).then((List<UserData> list) {
        setState(() {
          userList = list;
        });
      });
    });
    fetchFriends();
  }

  fetchFriends() {
    _authMethods.getCurrentUser().then((User user) {
      _authMethods.fetchAllFriends(user).then((List<String> list) {
        setState(() {
          friendsList = list;
        });
      });
    });
  }

  searchAppBar(BuildContext context) {
    return GradientAppBar(
      gradient: LinearGradient(
        colors: [Colors.green, Colors.teal],
      ),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: TextField(
            controller: searchController,
            onChanged: (val) {
              setState(() {
                query = val;
              });
            },
            cursorColor: UniversalVariables.blackColor,
            autofocus: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 35,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => searchController.clear());
                },
              ),
              border: InputBorder.none,
              hintText: "Search",
              hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Color(0x88ffffff),
              ),
            ),
          ),
        ),
      ),
    );
  }

  buildSuggestions(String query, UserData user) {
    final List<UserData> suggestionList = query.isEmpty
        ? []
        : userList != null
            ? userList.where((UserData user) {
                String _getUsername = user.username.toLowerCase();
                String _query = query.toLowerCase();
                String _getName = user.name.toLowerCase();
                bool matchesUsername = _getUsername.contains(_query);
                bool matchesName = _getName.contains(_query);

                return (matchesUsername || matchesName);
              }).toList()
            : [];

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: ((context, index) {
        UserData searchedUser = UserData(
            uid: suggestionList[index].uid,
            profilePhoto: suggestionList[index].profilePhoto,
            name: suggestionList[index].name,
            username: suggestionList[index].email,
            firebaseToken: suggestionList[index].firebaseToken);

        bool isFriend;
        if (friendsList.contains(searchedUser.uid.toString())) {
          isFriend = true;
        } else {
          isFriend = false;
        }
        return CustomTile(
          mini: false,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(
                          receiver: searchedUser,
                        )));
          },
          leading: CachedImage(
            searchedUser.profilePhoto,
            radius: 60.0,
            isRound: true,
          ),
          subtitle: Text(
            searchedUser.username,
            style: GoogleFonts.patuaOne(
                textStyle: Theme.of(context).textTheme.bodyText1),
          ),
          title: Text(
            searchedUser.name,
            style: GoogleFonts.patuaOne(
                textStyle: Theme.of(context).textTheme.headline1,
                letterSpacing: 1.0),
          ),
          trailing: IconButton(
            icon: isFriend
                ? Icon(
                    Icons.check,
                    size: 40.0,
                  )
                : Icon(Icons.person_add, size: 40.0),
            color: isFriend ? Colors.green : Theme.of(context).iconTheme.color,
            onPressed: () {
              _authMethods.addFriend(user.uid, searchedUser.uid);

              final snackbar = SnackBar(
                content: Text("Friend added!"),
              );
              final snackbarFriend = SnackBar(
                content: Text("Already a friend!"),
              );
              isFriend
                  ? Scaffold.of(context).showSnackBar(snackbarFriend)
                  : Scaffold.of(context).showSnackBar(snackbar);
            },
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);

    return PickupLayout(
      scaffold: Scaffold(
        // backgroundColor: Theme.of(context).backgroundColor,
        appBar: searchAppBar(context),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Theme.of(context).backgroundColor,
              Theme.of(context).scaffoldBackgroundColor
            ]),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10.0),
          child: buildSuggestions(query, userProvider.getUser),
        ),
      ),
    );
  }
}
