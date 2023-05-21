import 'package:chatify/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:chatify/screens/chatscreens/widgets/arc_class.dart';

class ControlsWidget extends StatelessWidget {
  final VoidCallback onClickedCamera;
  final VoidCallback onClickedGallery;
  final VoidCallback onClickedScanText;
  final VoidCallback onClickedClear;
  final BuildContext context;

  const ControlsWidget({
    required this.onClickedCamera,
    required this.onClickedGallery,
    required this.onClickedScanText,
    required this.onClickedClear,
    required this.context,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          moreMenuItem(Icons.photo_album_outlined, Strings.gallery,
              onClickedGallery, Colors.pink),
          moreMenuItem(Icons.camera_enhance_outlined, Strings.camera,
              onClickedCamera, Colors.blue),
          moreMenuItem(
              Icons.scanner, Strings.scan, onClickedScanText, Colors.orange),
          moreMenuItem(Icons.clear, Strings.clear, onClickedClear, Colors.red),
        ],
      ),
    );
  }

  GestureDetector moreMenuItem(
      IconData icon, String name, GestureTapCallback func, Color color) {
    return GestureDetector(
      onTap: func,
      child: Column(
        children: [
          Container(
            height: 48.0,
            width: 48.0,
            decoration: BoxDecoration(
              color: color.withOpacity(0.7),
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: Stack(
              children: [
                MyArc(
                  diameter: 60.0,
                  color: color,
                ),
                Center(
                  child: Icon(
                    icon,
                    size: 28.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Text(
            name,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: 16.0),
          )
        ],
      ),
    );
  }
}
