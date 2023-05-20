import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:chatify/utils/universal_variables.dart';

class ShimmeringLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 80,
      child: Shimmer.fromColors(
        baseColor: UniversalVariables.blackColor,
        highlightColor: Colors.white,
        child: Image.asset("assets/logo.png"),
        period: Duration(seconds: 1),
      ),
    );
  }
}