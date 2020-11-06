import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:skype_clone/widgets/appbar.dart';

class SkypeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final title;
  final List<Widget> actions;
  final Widget leading;
  

  const SkypeAppBar({
    Key key,
    @required this.title,
    @required this.actions,
    this.leading
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: CustomAppBar(
        leading : leading,
      
        title: (title is String)
            ? Text(
                title,
               style: GoogleFonts.oswald(
                    textStyle: Theme.of(context).textTheme.headline1,
                    fontSize: 28.0)
              )
            : title,
        centerTitle: true,
        actions: actions,
      ),
    );
  }

  final Size preferredSize = const Size.fromHeight(kToolbarHeight + 10);
}
