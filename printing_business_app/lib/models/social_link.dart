import 'package:flutter/material.dart';

/// Matches the SOCIAL_LINK entity from the project schema diagram.
class SocialLink {
  final int socialId;
  final String platform;
  final String url;
  final IconData icon;

  const SocialLink({
    required this.socialId,
    required this.platform,
    required this.url,
    required this.icon,
  });
}
