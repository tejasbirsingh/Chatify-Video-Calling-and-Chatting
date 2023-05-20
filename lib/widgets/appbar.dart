import 'package:flutter/material.dart';
import 'package:skype_clone/utils/universal_variables.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{

  final Widget title;
  final List<Widget> actions;
  final Widget leading;
  final bool centerTitle;
  final GestureTapCallback onTap;
  final bool isLeadingWidth;
  

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.actions,
    required this.leading, 
    required this.centerTitle,
    required this.onTap,
    required this.isLeadingWidth
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(

        
        color: Theme.of(context).appBarTheme.foregroundColor,
       
        border: Border(
          
          bottom: BorderSide(
            color: UniversalVariables.separatorColor,
            width: 1.4,
            style: BorderStyle.solid,
          ),
        ),
      ),
      child: AppBar(
    
        backgroundColor: Theme.of(context).appBarTheme.foregroundColor,
        iconTheme:Theme.of(context).appBarTheme.iconTheme,
        elevation: 0.0,
        leadingWidth : isLeadingWidth ? 20.0 : 50.0,
        
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