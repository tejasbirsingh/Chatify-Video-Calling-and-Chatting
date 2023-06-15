import 'package:chatify/constants/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:chatify/models/userData.dart';
import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/resources/auth_methods.dart';
import 'package:chatify/screens/callscreens/pickup/pickup_layout.dart';
import 'package:chatify/screens/chatscreens/chat_screen.dart';
import 'package:chatify/screens/chatscreens/widgets/cached_image.dart';
import 'package:chatify/utils/universal_variables.dart';
import 'package:chatify/widgets/custom_tile.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AuthMethods _authMethods = AuthMethods();
  List<UserData> userList = [];
  List<String>? friendsList;
  String query = "";
  final TextEditingController searchController = TextEditingController();
  bool _folded = true;

  void animationVariables() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _folded = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    animationVariables();
    _authMethods.getCurrentUser().then((final User? user) {
      if (user != null) {
        _authMethods.fetchAllUsers(user).then((List<UserData> list) {
          if (mounted) {
            setState(() {
              userList = list;
            });
          }
        });
      }
    });
    fetchFriends();
  }

  void fetchFriends() {
    _authMethods.getCurrentUser().then((final User? user) {
      if (user != null) {
        _authMethods.fetchAllFriends(user).then((final List<String> list) {
          if (mounted) {
            setState(() {
              friendsList = list;
            });
          }
        });
      }
    });
  }

  Widget buildSuggestions(final String? query, final UserData? user) {
    List<UserData> suggestionList = [];
    if (query != null && userList.isNotEmpty) {
      suggestionList = userList.where((UserData user) {
        final String _getUsername = user.username?.toLowerCase() ?? '';
        final String _query = query.toLowerCase();
        final String _getName = user.name?.toLowerCase() ?? '';
        final bool matchesUsername = _getUsername.contains(_query);
        final bool matchesName = _getName.contains(_query);
        return (matchesUsername || matchesName);
      }).toList();
    }

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: ((context, index) {
        final UserData searchedUser = UserData(
          uid: suggestionList[index].uid,
          profilePhoto: suggestionList[index].profilePhoto,
          name: suggestionList[index].name,
          username: suggestionList[index].email,
          firebaseToken: suggestionList[index].firebaseToken,
        );

        bool isFriend = false;
        if (friendsList != null &&
            friendsList!.contains(searchedUser.uid.toString())) {
          isFriend = true;
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: CustomTile(
            mini: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    receiver: searchedUser,
                  ),
                ),
              );
            },
            leading: CachedImage(
              searchedUser.profilePhoto!,
              radius: 60.0,
              isRound: true,
              isTap: () => {},
            ),
            subtitle: Text(
              searchedUser.username!,
              style: GoogleFonts.patuaOne(
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 16.0),
              ),
            ),
            title: Text(
              searchedUser.name!,
              style: GoogleFonts.patuaOne(
                textStyle: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 20.0, letterSpacing: 1.0),
              ),
            ),
            trailing: IconButton(
              icon: isFriend
                  ? Icon(
                      Icons.check,
                      size: 40.0,
                    )
                  : Icon(Icons.person_add, size: 40.0),
              color:
                  isFriend ? Colors.green : Theme.of(context).iconTheme.color,
              onPressed: () {
                if (user != null) {
                  _authMethods.addFriend(user.uid, searchedUser.uid);

                  final snackbar = SnackBar(
                    content: Text(Strings.friendAdded),
                  );
                  final snackbarFriend = SnackBar(
                    content: Text(Strings.alreadyAFriend),
                  );
                  isFriend
                      ? ScaffoldMessenger.of(context)
                          .showSnackBar(snackbarFriend)
                      : ScaffoldMessenger.of(context).showSnackBar(snackbar);
                }
              },
            ),
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
      scaffold: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    userProvider.getUser.firstColor != null
                        ? Color(userProvider.getUser.firstColor!)
                        : Theme.of(context).colorScheme.background,
                    userProvider.getUser.secondColor != null
                        ? Color(userProvider.getUser.secondColor!)
                        : Theme.of(context).scaffoldBackgroundColor,
                  ]),
                ),
              ),
              Positioned(
                top: -10.0,
                right: -30.0,
                child: Container(
                  height: 160.0,
                  width: 160.0,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(80.0)),
                ),
              ),
              Positioned(
                top: -20.0,
                left: -20.0,
                child: Container(
                  height: 200.0,
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(80.0)),
                ),
              ),
              Positioned(
                  top: 10.0,
                  left: 20.0,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: 30.0,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )),
              Positioned(
                child: Container(
                    child: Center(
                  child: Text(
                    Strings.search,
                    style: GoogleFonts.oswald(
                        textStyle: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontSize: 34.0)),
                  ),
                )),
                top: 10.0,
                left: MediaQuery.of(context).size.width * 0.3,
                right: MediaQuery.of(context).size.width * 0.3,
              ),
              Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.06,
                    right: MediaQuery.of(context).size.width * 0.06,
                    top: MediaQuery.of(context).size.height * 0.1,
                  ),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    height: 60.0,
                    width: _folded ? 56 : MediaQuery.of(context).size.width,
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
                        color: Colors.black,
                        fontSize: 35,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            WidgetsBinding.instance!.addPostFrameCallback(
                                (_) => searchController.clear());
                          },
                        ),
                        border: InputBorder.none,
                        hintText: Strings.search,
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade400,
                            blurRadius: 20.0,
                            spreadRadius: 4.0,
                          )
                        ],
                        borderRadius: BorderRadius.circular(20.0)),
                  )),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.22),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      userProvider.getUser.firstColor != null
                          ? Color(userProvider.getUser.firstColor!)
                          : Theme.of(context).colorScheme.background,
                      userProvider.getUser.secondColor != null
                          ? Color(userProvider.getUser.secondColor!)
                          : Theme.of(context).scaffoldBackgroundColor,
                    ]),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10.0),
                  child: buildSuggestions(query, userProvider.getUser),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
