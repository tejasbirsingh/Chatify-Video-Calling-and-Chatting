import 'package:flutter/material.dart';
import 'package:chatify/utils/universal_variables.dart';

/*
  Custom App bar with customizable size.
*/
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool? centerTitle;
  final GestureTapCallback? onTap;
  final bool isLeadingWidth;

  const CustomAppBar(
      {Key? key,
      this.title,
      this.actions,
      this.leading,
      this.centerTitle,
      this.onTap,
      this.isLeadingWidth = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: UniversalVariables.separatorColor,
            width: 1.4,
            style: BorderStyle.solid,
          ),
        ),
      ),
      child: AppBar(
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        elevation: 0.0,
        leadingWidth: isLeadingWidth ? 20.0 : 50.0,
        leading: leading,
        actions: actions,
        centerTitle: centerTitle,
        title: GestureDetector(
          child: title,
          onTap: onTap,
        ),
      ),
    );
  }

  final Size preferredSize = const Size.fromHeight(kToolbarHeight + 10);
}
