import 'package:flutter/material.dart';
import 'package:skype_clone/utils/universal_variables.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{

  final Widget title;
  final List<Widget> actions;
  final Widget leading;
  final bool centerTitle;
  final GestureTapCallback onTap;
  

  const CustomAppBar({
    Key key,
    @required this.title,
    @required this.actions,
     this.leading, 
    @required this.centerTitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(

        
        color: Theme.of(context).appBarTheme.color,
       
        border: Border(
          
          bottom: BorderSide(
            color: UniversalVariables.separatorColor,
            width: 1.4,
            style: BorderStyle.solid,
          ),
        ),
      ),
      child: AppBar(
    
        backgroundColor: Theme.of(context).appBarTheme.color,
        iconTheme:Theme.of(context).appBarTheme.iconTheme,
        elevation: 0,
        
        leading: leading,
        actions: actions,
        centerTitle: centerTitle,
        title: GestureDetector(child: title,
        onTap: onTap,),
      ),
    );
  }

  final Size preferredSize = const Size.fromHeight(kToolbarHeight+10);
}