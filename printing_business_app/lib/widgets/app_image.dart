import 'package:flutter/material.dart';


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
