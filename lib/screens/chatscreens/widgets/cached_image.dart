

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';


class CachedImage extends StatelessWidget {
  final String imageUrl;
  final bool isRound;
  final double radius;
  final double height;
  final double width;
  final GestureTapCallback? isTap ;


  final BoxFit fit;


  final String NO_IMAGE_AVAILABLE_URL =
      "https://www.esm.rochester.edu/uploads/NoPhotoAvailable.jpg";

  CachedImage(
    this.imageUrl, {
    this.isRound = false,
    this.radius = 0,
    this.height = 100,
    this.width = 100,
    this.isTap,
    this.fit = BoxFit.cover,
  });


  @override
  Widget build(BuildContext context) {
    try {
 
      return SizedBox(
        height: isRound ? radius : height,
        width: isRound ? radius : width,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(isRound ? 50 : radius),
            child: GestureDetector(
                  onTap: isTap,
                  child: Hero(
                    tag: imageUrl,
                                      child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: fit,
                placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Image.network(
                    NO_IMAGE_AVAILABLE_URL,
                    height: 25,
                    width: 25,
                    fit: BoxFit.cover,
                ),
              ),
                  ),
            )),
      );
    } catch (e) {
      print(e);
      return Image.network(
        NO_IMAGE_AVAILABLE_URL,
        height: 25,
        width: 25,
        fit: BoxFit.cover,
      );
    }
  }
}
