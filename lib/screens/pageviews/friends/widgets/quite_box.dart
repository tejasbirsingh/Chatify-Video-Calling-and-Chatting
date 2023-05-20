import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:skype_clone/screens/search_screen.dart';


class QuietBox extends StatelessWidget {
  final String heading;
  final String subtitle;

  QuietBox({
    required this.heading,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0),  
            gradient: LinearGradient(colors:[HexColor('a3bded'),HexColor('6991c7')]
          ),),
         
          padding: EdgeInsets.symmetric(vertical: 35, horizontal: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                heading,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              SizedBox(height: 25),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 25),
              TextButton(
                // color: UniversalVariables.lightBlueColor,
                child: Text("Search Friends",style: TextStyle(color: Colors.white,
                fontSize: 18.0),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
