import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:chatify/widgets/appbar.dart';

class SkypeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final title;
  final List<Widget> actions;
  final Widget leading;
  

  const SkypeAppBar({
    Key? key,
    required this.title,
    required this.actions,
    required this.leading
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      
      color: Theme.of(context).colorScheme.background,
      child: CustomAppBar(
        onTap: () =>{},
        leading : leading,
      isLeadingWidth: false,
        title: (title is String)
            ? Text(
                title,
               style: GoogleFonts.oswald(
                    textStyle: Theme.of(context).textTheme.displayLarge,
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
