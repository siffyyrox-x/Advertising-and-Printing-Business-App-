import 'package:flutter/material.dart';

import '../models/gallery_item.dart';
import '../widgets/app_image.dart';

/// Opens one gallery picture full screen.
Future<void> openImageViewScreen(BuildContext context, GalleryItem item) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => ImageViewScreen(item: item),
    ),
  );
}


class ImageViewScreen extends StatelessWidget {
  final GalleryItem item;

  const ImageViewScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(item.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: AppImage(path: item.imagePath, fit: BoxFit.contain),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: const Color(0xFF212121),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.description,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pinch with two fingers to zoom in.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
