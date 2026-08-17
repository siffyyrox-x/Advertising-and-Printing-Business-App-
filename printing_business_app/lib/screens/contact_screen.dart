import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/company_info.dart';
import '../models/social_link.dart';
import '../utils/launcher_helper.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/section_title.dart';
import 'quote_screen.dart';

/// The Contact tab: company details, location, contact buttons, social media
/// links, Share App and a shortcut to the quote form.
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  /// Shows the configured value, or a short reminder when it is still a
  /// placeholder, so nothing on screen pretends to be real information.
  static String _display(String value) {
    return CompanyInfo.isPlaceholder(value) ? 'Not set yet' : value;
  }

  /// The written address, or a short note when only a map link is configured.
  static String get _addressLine {
    if (!CompanyInfo.isPlaceholder(CompanyInfo.address)) {
      return CompanyInfo.address;
    }
    return CompanyInfo.hasLocation ? 'Open in Google Maps below' : 'Not set yet';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: <Widget>[
        if (CompanyInfo.hasUnconfiguredDetails) const _SetupNotice(),

        const SectionTitle('Company Details', padding: EdgeInsets.only(bottom: 8)),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.radius,
            side: const BorderSide(color: AppTheme.cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: <Widget>[
                _DetailRow(
                  icon: Icons.business_outlined,
                  label: 'Company',
                  value: CompanyInfo.name,
                ),
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: _addressLine,
                ),
                _DetailRow(
                  icon: Icons.call_outlined,
                  label: 'Phone',
                  value: _display(CompanyInfo.phone),
                ),
                _DetailRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: _display(CompanyInfo.email),
                ),
                _DetailRow(
                  icon: Icons.schedule_outlined,
                  label: 'Business hours',
                  value: CompanyInfo.businessHours,
                ),
              ],
            ),
          ),
        ),

        const SectionTitle('Our Location'),
        Container(
          height: 170,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFECEFF1),
            borderRadius: AppTheme.radius,
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.map_outlined, size: 40, color: Color(0xFF78909C)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _addressLine,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => LauncherHelper.openMap(context),
                icon: const Icon(Icons.directions_outlined, size: 18),
                label: const Text('Open in Google Maps'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),

        const SectionTitle('Contact Us'),
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

        const SectionTitle('Social Media'),
        Row(
          children: <Widget>[
            for (int i = 0; i < CompanyInfo.socialLinks.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _SocialButton(link: CompanyInfo.socialLinks[i]),
              ),
            ],
          ],
        ),

        const SizedBox(height: 20),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => LauncherHelper.shareApp(context),
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('Share App'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => openQuoteScreen(context),
                icon: const Icon(Icons.request_quote_outlined, size: 18),
                label: const Text('Request Quote'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A single "icon + label + value" line in the company details card.
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: AppTheme.muted),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final SocialLink link;

  const _SocialButton({required this.link});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () =>
          LauncherHelper.openWebsite(context, link.url, link.platform),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(link.icon, size: 22),
          const SizedBox(height: 4),
          Text(
            link.platform,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// A small reminder shown while the placeholder business details are still in
/// lib/data/company_info.dart.
class _SetupNotice extends StatelessWidget {
  const _SetupNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: AppTheme.radius,
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline, size: 20, color: Color(0xFFF57F17)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Setup: some business details are still placeholders. Add the '
              'real values in lib/data/company_info.dart.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6D4C41)),
            ),
          ),
        ],
      ),
    );
  }
}
