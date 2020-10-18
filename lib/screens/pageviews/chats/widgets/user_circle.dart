import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype_clone/provider/user_provider.dart';

import 'package:skype_clone/utils/utilities.dart';

import 'user_details_container.dart';

class UserCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        isScrollControlled: true,
        context: context,

        backgroundColor: Theme.of(context).backgroundColor,
        builder: (context) => UserDetailsContainer(),
      ),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          // color: UniversalVariables.separatorColor,
    // color: Theme.of(context).cardColor
    gradient: LinearGradient(colors: [Colors.green,Colors.teal])
        ),
        child: Stack(
          children: <Widget>[
 
            Align(
              alignment: Alignment.center,
              child: Text(
                Utils.getInitials(userProvider.getUser.name),
                // style: TextStyle(
                //   fontWeight: FontWeight.bold,
                //   color: UniversalVariables.lightBlueColor,
                //   fontSize: 13,
                // ),
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          
          ],
        ),
      ),
    );
  }
}
