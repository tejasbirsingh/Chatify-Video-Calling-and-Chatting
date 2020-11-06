import 'package:flutter/material.dart';
import 'package:skype_clone/widgets/custom_tile.dart';

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onTap;

  const ModalTile({
    @required this.title,
    this.subtitle,
    @required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 4.0),
      child: CustomTile(
        mini: false,
        onTap: onTap,
        leading: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          
            color: Theme.of(context).cardColor,
          ),
          padding: EdgeInsets.all(10),
          child: Icon(
            icon,
            color: Theme.of(context).iconTheme.color,
            size: 30,
          ),
        ),
     
        title: Text(title, style: Theme.of(context).textTheme.headline1),
      ),
    );
  }
}
