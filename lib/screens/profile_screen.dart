import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skype_clone/models/userData.dart';

class profilePage extends StatefulWidget {
  final UserData user;

  const profilePage({Key key, @required this.user}) : super(key: key);
  @override
  _profilePageState createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  bool _first = true;

  double _fontSize = 60;
  Color _color = Colors.green;
  FontWeight _weight = FontWeight.normal;
  @override
  void initState() {
    super.initState();
    textAnimation();
   
  }
 textAnimation(){
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _fontSize = _first ? 30 : 50;
        _color = _first ? Colors.white : Colors.white;
        _first = !_first;
        _weight = _first ? FontWeight.normal : FontWeight.bold;
      });
    });
 }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: NestedScrollView(
          dragStartBehavior: DragStartBehavior.start,
          headerSliverBuilder: (BuildContext context, bool innerBox) {
            return <Widget>[
              SliverAppBar(
                  collapsedHeight: MediaQuery.of(context).size.height * 0.15,
                  expandedHeight: MediaQuery.of(context).size.height * 0.40,
                  floating: true,
                  centerTitle: false,
                  pinned: true,
                  stretch: false,
                  title: AnimatedDefaultTextStyle(
                    curve: Curves.linear,
                    duration: Duration(milliseconds: 300),
                    style: GoogleFonts.patuaOne(textStyle:TextStyle(
                      letterSpacing: 1.0,
                        fontSize: _fontSize,
                        color: _color,
                        fontWeight: _weight),),
                    child: Text(
                      widget.user.name,
                    ),
                  ),
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                          child: Image.network(
                        widget.user.profilePhoto,
                        fit: BoxFit.cover,
                      )),
                    ],
                  )

                
                  )
            ];
          },
          body: Container(
              decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Theme.of(context).backgroundColor,
              Theme.of(context).scaffoldBackgroundColor
            ]),
          ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.0),
              child: ListView(
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.email_outlined,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    title: Text(
                      'Email',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    subtitle: Text(widget.user.email,
                        style: Theme.of(context).textTheme.headline1),
                  ),
                  Divider(
                    thickness: 1.0,
                    color: Theme.of(context).dividerColor,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline_rounded,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    title: Text(
                      'Status',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    subtitle: Text(widget.user.status,
                        style: Theme.of(context).textTheme.headline1),
                  ),
                  Divider(
                    thickness: 1.0,
                    color: Theme.of(context).dividerColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
