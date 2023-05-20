import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:chatify/provider/user_provider.dart';
import 'package:chatify/utils/utilities.dart';
import 'user_details_container.dart';

/*
Displays user circle with user initials
*/
class UserCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        backgroundColor: Theme.of(context).colorScheme.background,
        builder: (context) => UserDetailsContainer(),
      ),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0),
            gradient: LinearGradient(colors: [Colors.green, Colors.teal])),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Text(
                Utils.getInitials(userProvider.getUser.name),
                style: GoogleFonts.anton(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    letterSpacing: 2.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
