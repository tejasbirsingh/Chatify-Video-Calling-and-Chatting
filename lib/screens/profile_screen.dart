import 'package:flutter/material.dart';
import 'package:skype_clone/models/userData.dart';

import 'package:velocity_x/velocity_x.dart';

class profilePage extends StatefulWidget {
  final UserData user;

  const profilePage({Key key, @required this.user}) : super(key: key);
  @override
  _profilePageState createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.user.name,
          style: Theme.of(context).textTheme.headline1,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).iconTheme.color,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10.0,
            ),
            Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 120.0,
                backgroundImage: NetworkImage(widget.user.profilePhoto),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text('Email :    ' + widget.user.email,
                style: Theme.of(context).textTheme.headline1),
            SizedBox(
              height: 20.0,
            ),
            Text('Status :    ${widget.user.status ?? 'No status'}',
                style: Theme.of(context).textTheme.headline1),
          ],
        ),
      ),
    );
  }
}
