import 'package:flutter/material.dart';

import 'package:skype_clone/widgets/appbar.dart';

class SkypeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final title;
  final List<Widget> actions;

  const SkypeAppBar({
    Key key,
    @required this.title,
    @required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: CustomAppBar(
        
        leading: IconButton(
          icon: Icon(
            Icons.notifications,
          color: Theme.of(context).iconTheme.color,
            // color: Colors.white,
          ),
          onPressed: () {},
        ),
        title: (title is String)
            ? Text(
                title,
                style: TextStyle(
                    color: Theme.of(context).textTheme.headline1.color,
                  // color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : title,
        centerTitle: true,
        actions: actions,
      ),
    );
  }

  final Size preferredSize = const Size.fromHeight(kToolbarHeight + 10);
}
