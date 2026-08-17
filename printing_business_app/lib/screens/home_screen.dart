import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/company_info.dart';
import '../data/services_data.dart';
import '../models/service.dart';
import '../utils/launcher_helper.dart';
import '../widgets/app_image.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/section_title.dart';
import 'chatbot_screen.dart';
import 'quote_screen.dart';

/// The Home tab: banner, About Us, quick contact buttons, the main
/// "Request a Quote" button and a few popular services.
class HomeScreen extends StatelessWidget {
  /// Lets the Home screen switch the bottom navigation to another tab.
  final ValueChanged<int> onOpenTab;

  const HomeScreen({super.key, required this.onOpenTab});

  static const int _servicesTabIndex = 1;

  @override
  Widget build(BuildContext context) {
    final List<Service> popular = ServicesData.active.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ---- Main banner ----
          ClipRRect(
            borderRadius: AppTheme.radius,
            child: const AspectRatio(
              aspectRatio: 16 / 9,
              child: AppImage(path: 'assets/images/banner.png'),
            ),
          ),

          const SectionTitle('About Us'),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: AppTheme.radius,
              side: const BorderSide(color: AppTheme.cardBorder),
            ),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                CompanyInfo.about,
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          ),

          const SectionTitle('Quick Contact'),
          QuickActionRow(
            buttons: <QuickActionButton>[
              QuickActionButton(
                icon: Icons.call,
                label: 'Call Now',
                onPressed: () => LauncherHelper.callPhone(context),
              ),
              QuickActionButton(
                icon: Icons.chat,
                label: 'WhatsApp',
                onPressed: () => LauncherHelper.openWhatsApp(context),
              ),
              QuickActionButton(
                icon: Icons.email_outlined,
                label: 'Email',
                onPressed: () => LauncherHelper.sendEmail(context),
              ),
            ],
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => openQuoteScreen(context),
              icon: const Icon(Icons.request_quote_outlined),
              label: const Text(
                'Request a Quote',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => openChatbotScreen(context),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Ask our Service Helper'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const SectionTitle('Popular Services'),
              TextButton(
                onPressed: () => onOpenTab(_servicesTabIndex),
                child: const Text('See all'),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < popular.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _PopularServiceTile(
                    service: popular[i],
                    onTap: () => onOpenTab(_servicesTabIndex),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 20),
          Center(
            child: Text(
              CompanyInfo.businessHours,
              textAlign: TextAlign.center,
              style: AppTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// One small picture + name box under "Popular Services".
class _PopularServiceTile extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  const _PopularServiceTile({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.radius,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 1,
              child: AppImage(path: service.imagePath),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            service.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
