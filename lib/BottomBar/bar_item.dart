import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:chatify/provider/user_provider.dart';

class AnimatedBottomBar extends StatefulWidget {
  final List<BarItem>? barItems;
  final Duration animationDuration;
  final Function? onBarTap;
  final BarStyle? barStyle;

  AnimatedBottomBar(
      {this.barItems,
      this.animationDuration = const Duration(milliseconds: 500),
      this.onBarTap,
      this.barStyle});

  @override
  _AnimatedBottomBarState createState() => _AnimatedBottomBarState();
}

class _AnimatedBottomBarState extends State<AnimatedBottomBar>
    with TickerProviderStateMixin {
  int selectedBarIndex = 0;

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Container(
        decoration: BoxDecoration(
          
            gradient: LinearGradient(colors: [
                  
                userProvider.getUser.firstColor != null
              ? Color(userProvider.getUser.firstColor ?? Colors.white.value)
              : Theme.of(context).colorScheme.background,
          userProvider.getUser.secondColor != null
              ? Color(userProvider.getUser.secondColor ?? Colors.white.value)
              : Theme.of(context).scaffoldBackgroundColor,
              
            ]),
          ),
      child: Material(
  
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0)),
     
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 10.0,
            top: 10.0,
            left: 16.0,
            right: 16.0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildBarItems(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBarItems() {
    List<Widget> _barItems = [];
    for (int i = 0; i < widget.barItems!.length; i++) {
      BarItem item = widget.barItems![i];
      bool isSelected = selectedBarIndex == i;
      _barItems.add(InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          setState(() {
            selectedBarIndex = i;
            widget.onBarTap!(selectedBarIndex);
          });
        },
        child: AnimatedContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          duration: widget.animationDuration,
          decoration: BoxDecoration(
              color: isSelected
                  ? item.color.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: Row(
            children: <Widget>[
              Icon(
                item.iconData,
                color:
                    isSelected ? item.color : Theme.of(context).iconTheme.color,
                size: widget.barStyle!.iconSize,
              ),
              SizedBox(
                width: 10.0,
              ),
              AnimatedSize(
                duration: widget.animationDuration,
                curve: Curves.easeInOut,
                child: Text(
                  isSelected ? item.text : "",
                  style:GoogleFonts.paytoneOne(
                    textStyle: TextStyle(
                      color: item.color,
                      
                      fontWeight: widget.barStyle!.fontWeight,
                      fontSize: widget.barStyle!.fontSize),
                  )
                ),
              )
            ],
          ),
        ),
      ));
    }
    return _barItems;
  }
}

class BarStyle {
  final double fontSize, iconSize;
  final FontWeight fontWeight;

  BarStyle(
      {this.fontSize = 16.0,
      this.iconSize = 25.0,
      this.fontWeight = FontWeight.w600});
}

class BarItem {
  String text;
  IconData iconData;
  Color color;

  BarItem({required this.text, required this.iconData, required this.color});
}
