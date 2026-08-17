import 'package:flutter/material.dart';

import '../app_theme.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const SectionTitle(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.only(top: 16, bottom: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(text, style: AppTheme.sectionTitle),
    );
  }
}
