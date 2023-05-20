import 'package:flutter/material.dart';


class CustomTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? icon;
  final Widget? subtitle;
  final Widget? trailing;
  final EdgeInsets margin;
  final bool mini;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;

  CustomTile({
    this.leading,
    this.title,
    this.icon,
    this.subtitle,
    this.trailing,
    this.margin = const EdgeInsets.all(0),
    this.onTap,
    this.onLongPress,
    this.mini = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Theme.of(context).canvasColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 0.5,
              spreadRadius: 0.0,
              offset: Offset(0.5, 0.5), 
            )
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: mini ? 10 : 5),
        margin: margin,
        child: Row(
          children: <Widget>[
            SizedBox(width: 5),
            leading!,
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: mini ? 10 : 15),
                padding: EdgeInsets.symmetric(vertical: mini ? 3 : 20),
                decoration:
                    BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0)
                      
                        ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        title!,
                        SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            icon ?? Container(),
                            subtitle ?? Container()
                          ],
                        )
                      ],
                    ),
                    trailing ?? Container(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
