import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatify/enum/user_state.dart';
import 'package:chatify/models/userData.dart';
import 'package:chatify/resources/auth_methods.dart';
import 'package:chatify/utils/utilities.dart';

/*
  It displays the status of user.
*/
class OnlineDotIndicator extends StatelessWidget {
  final String uid;
  final AuthMethods _authMethods = AuthMethods();

  OnlineDotIndicator({
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    getColor(int state) {
      switch (Utils.numToState(state)) {
        case UserState.Offline:
          return Colors.red;
        case UserState.Online:
          return Colors.green;
        default:
          return Colors.orange;
      }
    }

    return Align(
      alignment: Alignment.center,
      child: StreamBuilder<DocumentSnapshot>(
        stream: _authMethods.getUserStream(
          uid: uid,
        ),
        builder: (context, snapshot) {
          UserData? user;

          if (snapshot.hasData) {
            user =
                UserData.fromMap(snapshot.data!.data() as Map<String, dynamic>);
            return CircleAvatar(
              radius: 300.0,
              backgroundColor: getColor(user.state!),
            );
          }
          return CircleAvatar(
            radius: 300.0,
            backgroundColor: getColor(0),
          );
        },
      ),
    );
  }
}
