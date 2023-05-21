import 'package:chatify/constants/strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:chatify/models/contact.dart';
import 'package:chatify/models/userData.dart';
import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/resources/auth_methods.dart';
import 'package:chatify/screens/chatscreens/messageForwarding/forward_view.dart';
import 'package:chatify/widgets/chatify_app_bar.dart';

class ForwardPage extends StatefulWidget {
  final String message;
  final String imagePath;
  ForwardPage({required this.message, required this.imagePath});
  @override
  _forwardPageState createState() => _forwardPageState();
}

class _forwardPageState extends State<ForwardPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final AuthMethods _auth = AuthMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: true);

    var chatifyAppBar = ChatifyAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (context) {
          Navigator.pop(context);
          return Container();
        })),
      ),
      title: Text(
        Strings.forwardMessage,
        style: GoogleFonts.oswald(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: 26.0),
      ),
      actions: [],
    );
    return SafeArea(
      child: Scaffold(
          appBar: chatifyAppBar,
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    userProvider.getUser.firstColor != null
                        ? Color(userProvider.getUser.firstColor ??
                            Colors.white.value)
                        : Theme.of(context).colorScheme.background,
                    userProvider.getUser.secondColor != null
                        ? Color(userProvider.getUser.secondColor ??
                            Colors.white.value)
                        : Theme.of(context).scaffoldBackgroundColor,
                  ]),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _auth.getFriends(uid: userProvider.getUser.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var docList = snapshot.data!.docs;
                    if (docList.isEmpty) return Container();

                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemCount: docList.length,
                      itemBuilder: (context, i) {
                        final Contact user = Contact.fromMap(
                            docList[i].data() as Map<String, dynamic>);
                        return ForwardView(
                          contact: user,
                          forwardedMessage: widget.message,
                          imagePath: widget.imagePath,
                        );
                      },
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ],
          )),
    );
  }

  Future<UserData> mapUserDataFromUid(String uid) async {
    UserData? user = await _auth.getUserDetailsById(uid);
    return user!;
  }
}
