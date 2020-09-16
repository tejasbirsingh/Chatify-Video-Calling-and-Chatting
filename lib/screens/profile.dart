import 'package:flutter/material.dart';
import 'package:skype_clone/models/userData.dart';


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
      appBar: AppBar(
        title: Text(widget.user.name),
      ),
      body: Column(
        
        children: [
          SizedBox(height: 10.0,),
          Align(
            alignment: Alignment.center,
                      child: CircleAvatar(
              radius: 120.0,
              backgroundImage: NetworkImage(widget.user.profilePhoto
              ),
            ),
          ),
          SizedBox(height: 20.0,),
          Text('Email :    ' + widget.user.email,
          style: TextStyle(
            fontSize: 20.0
          ),)
      

      ],),
      
    );
  }
}