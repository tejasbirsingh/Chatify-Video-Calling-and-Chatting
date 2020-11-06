import 'package:flutter/material.dart';

class ControlsWidget extends StatelessWidget {
  final VoidCallback onClickedCamera;
  final VoidCallback onClickedGallery;
  final VoidCallback onClickedScanText;
  final VoidCallback onClickedClear;

  const ControlsWidget({
    @required this.onClickedCamera,
    @required this.onClickedGallery,
    @required this.onClickedScanText,
    @required this.onClickedClear,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) { 
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
            RaisedButton(
              color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
            onPressed: onClickedGallery,
            child: Icon(Icons.photo_album_outlined,
             color: Theme.of(context).iconTheme.color)
          ),
         
           SizedBox(width: 8.0),
          RaisedButton(
               color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
            onPressed: onClickedCamera,
            child: Icon(Icons.camera_enhance_outlined,
            color: Theme.of(context).iconTheme.color,)
          ),
                     SizedBox(width: 8.0),
            RaisedButton(
              
               color: Theme.of(context).cardColor,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
            onPressed: onClickedClear,
            child:Icon(Icons.clear,
             color: Theme.of(context).iconTheme.color),
          )
         ],),
           SizedBox(width: 8.0),
         RaisedButton(
           
              color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
         onPressed: onClickedScanText,
         child: Text('Scan',
           style: Theme.of(context).textTheme.headline1),
          ),
         
        ]
      );}
}