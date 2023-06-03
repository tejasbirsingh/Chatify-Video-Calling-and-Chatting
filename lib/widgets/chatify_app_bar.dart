import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chatify/widgets/custom_app_bar.dart';

/*
  App bar used on various screens of chatify.
*/
class ChatifyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final title;
  final List<Widget> actions;
  final Widget? leading;

  const ChatifyAppBar(
      {Key? key, required this.title, required this.actions, this.leading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomAppBar(
        leading: leading ?? Container(),
        isLeadingWidth: false,
        title: (title is String)
            ? Text(title,
                style: GoogleFonts.oswald(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: 28.0))
            : title,
        centerTitle: true,
        actions: actions,
      ),
    );
  }

  final Size preferredSize = const Size.fromHeight(kToolbarHeight + 10);
}
