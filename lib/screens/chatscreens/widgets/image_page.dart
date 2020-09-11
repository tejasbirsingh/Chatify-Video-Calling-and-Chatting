
import 'package:flutter/material.dart';

import 'package:photo_view/photo_view.dart';

class ImagePage extends StatelessWidget {
  final String imageUrl;
  final String noImageAvailable =
      "https://www.esm.rochester.edu/uploads/NoPhotoAvailable.jpg";

  ImagePage({@required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back),
        onPressed: ()=>Navigator.pop(context),),
      ),
      body: Container(

        child: Hero(
          tag: imageUrl,
                  child: PhotoView(
            imageProvider: NetworkImage(
            imageUrl
          ),
 
          //enableRotation: true,
     
          ),
        )
      ),
    );
  }
}