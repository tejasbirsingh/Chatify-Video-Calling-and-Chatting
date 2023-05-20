import 'package:flutter/material.dart';
import 'package:skype_clone/screens/chatscreens/widgets/arc_class.dart';

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
          moreMenuItem(Icons.photo_album_outlined, 'Gallery', onClickedGallery,
              Colors.pink),
          moreMenuItem(Icons.camera_enhance_outlined, 'Camera', onClickedCamera,
              Colors.blue),
          moreMenuItem(Icons.scanner, 'Scan', onClickedScanText, Colors.orange),
          moreMenuItem(Icons.clear, 'Clear', onClickedClear, Colors.red),
        ],
      ),
    );
  }

  GestureDetector moreMenuItem(
      IconData icon, String name, GestureTapCallback fun, Color color) {
    return GestureDetector(
      onTap: fun,
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
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: 16.0),
          )
        ],
      ),
    );
  }
}
