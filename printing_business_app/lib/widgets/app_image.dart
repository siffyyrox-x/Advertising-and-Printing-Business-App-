import 'package:flutter/material.dart';

/// Shows an image from the assets folder.
///
/// If the file is missing (for example while the placeholder pictures are being
/// replaced with real photos) a grey box with an icon is shown instead of
/// crashing the screen.
class AppImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        return Container(
          width: width,
          height: height,
          color: const Color(0xFFE0E0E0),
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFF9E9E9E),
          ),
        );
      },
    );
  }
}
