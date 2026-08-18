import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/company_info.dart';
import '../data/services_data.dart';
import '../models/service.dart';
import '../utils/ai_service.dart';
import '../utils/launcher_helper.dart';
import '../widgets/app_image.dart';
import '../widgets/section_title.dart';

/// Opens the About screen.
Future<void> openAboutScreen(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => const AboutScreen(),
    ),
  );
}

/// A short "about the company and the app" page, reachable from the side menu.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: <Widget>[
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: const AppImage(
                path: 'assets/images/logo.png',
                width: 96,
                height: 96,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              CompanyInfo.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(CompanyInfo.tagline, style: AppTheme.muted),
          ),

          const SectionTitle('About Us'),
          const Text(CompanyInfo.about, style: TextStyle(fontSize: 14, height: 1.4)),

          const SectionTitle('What We Offer'),
          for (final String category in ServicesData.categories)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '$category:  '
                '${ServicesData.byCategory(category).map((Service s) => s.title).join(', ')}',
                style: const TextStyle(fontSize: 13.5),
              ),
            ),

          const SectionTitle('Business Hours'),
          const Text(CompanyInfo.businessHours, style: TextStyle(fontSize: 14)),

          const SectionTitle('About This App'),
          const _InfoRow(label: 'Version', value: appVersion),
          const _InfoRow(label: 'Built with', value: 'Flutter and Dart'),
          const _InfoRow(label: 'Platform', value: 'Android'),
          _InfoRow(
            label: 'Service Helper',
            value: AiService.isEnabled
                ? 'Online AI plus offline rules'
                : 'Offline rules only',
          ),
          const _InfoRow(
            label: 'Your data',
            value: 'Quote requests are stored on this phone only',
          ),

          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => LauncherHelper.shareApp(context),
              icon: const Icon(Icons.share_outlined, size: 18),
              label: const Text('Share this app'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(label, style: AppTheme.muted),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13.5)),
          ),
        ],
      ),
    );
  }
}
