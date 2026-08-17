import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/company_info.dart';

class LauncherHelper {
  LauncherHelper._();

  /// Shows a short message at the bottom of the screen.
  static void _showMessage(ScaffoldMessengerState messenger, String text) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 3)),
    );
  }

  static Future<void> _open(
    BuildContext context,
    Uri uri,
    String errorMessage,
  ) async {

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final bool opened =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        _showMessage(messenger, errorMessage);
      }
    } catch (_) {
      _showMessage(messenger, errorMessage);
    }
  }

  static void _showNotConfigured(BuildContext context, String field) {
    _showMessage(
      ScaffoldMessenger.of(context),
      'The $field is not set yet. Add it in lib/data/company_info.dart.',
    );
  }

  /// Removes spaces, dashes and brackets so the value is safe for a tel: URI.
  static String _digitsOnly(String value) =>
      value.replaceAll(RegExp(r'[^0-9+]'), '');

  // ---------------------------------------------------------------------------
  // Call Now
  // ---------------------------------------------------------------------------
  static Future<void> callPhone(BuildContext context) async {
    if (CompanyInfo.isPlaceholder(CompanyInfo.phone)) {
      _showNotConfigured(context, 'phone number');
      return;
    }
    final Uri uri = Uri(scheme: 'tel', path: _digitsOnly(CompanyInfo.phone));
    await _open(context, uri, 'Could not open the phone dialer.');
  }

  // ---------------------------------------------------------------------------
  // WhatsApp
  // ---------------------------------------------------------------------------
  static Future<void> openWhatsApp(
    BuildContext context, {
    String message = 'Hello, I would like to ask about your services.',
  }) async {
    if (CompanyInfo.isPlaceholder(CompanyInfo.whatsappNumber)) {
      _showNotConfigured(context, 'WhatsApp number');
      return;
    }

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String number =
        _digitsOnly(CompanyInfo.whatsappNumber).replaceAll('+', '');

    // Try the WhatsApp app first.
    final Uri appUri = Uri.parse(
      'whatsapp://send?phone=$number&text=${Uri.encodeComponent(message)}',
    );
    // If WhatsApp is not installed, wa.me opens in the browser instead.
    final Uri webUri = Uri.parse(
      'https://wa.me/$number?text=${Uri.encodeComponent(message)}',
    );

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
        return;
      }
      final bool opened =
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
      if (!opened) {
        _showMessage(messenger,
            'WhatsApp is not available on this device. Please use Call or Email.');
      }
    } catch (_) {
      _showMessage(messenger,
          'WhatsApp is not available on this device. Please use Call or Email.');
    }
  }

  // ---------------------------------------------------------------------------
  // Email
  // ---------------------------------------------------------------------------
  static Future<void> sendEmail(
    BuildContext context, {
    String subject = 'Enquiry from the app',
    String body = '',
  }) async {
    if (CompanyInfo.isPlaceholder(CompanyInfo.email)) {
      _showNotConfigured(context, 'email address');
      return;
    }

    final Uri uri = Uri(
      scheme: 'mailto',
      path: CompanyInfo.email,
      query: _encodeQuery(<String, String>{
        'subject': subject,
        if (body.isNotEmpty) 'body': body,
      }),
    );
    await _open(context, uri, 'No email app was found on this device.');
  }

  static String _encodeQuery(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  // ---------------------------------------------------------------------------
  // Google Maps
  // ---------------------------------------------------------------------------
  static Future<void> openMap(BuildContext context) async {
    final bool hasMapUrl = !CompanyInfo.isPlaceholder(CompanyInfo.mapUrl);

    if (!hasMapUrl && CompanyInfo.isPlaceholder(CompanyInfo.address)) {
      _showNotConfigured(context, 'company address');
      return;
    }

    // A direct map link is used when one has been configured, otherwise the
    // address is searched for on Google Maps.
    final Uri uri = hasMapUrl
        ? Uri.parse(CompanyInfo.mapUrl)
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1'
            '&query=${Uri.encodeComponent(CompanyInfo.address)}',
          );

    await _open(context, uri, 'Could not open the maps app.');
  }

  // ---------------------------------------------------------------------------
  // Social media
  // ---------------------------------------------------------------------------
  static Future<void> openWebsite(
    BuildContext context,
    String url,
    String platform,
  ) async {
    if (CompanyInfo.isPlaceholder(url)) {
      _showNotConfigured(context, '$platform link');
      return;
    }
    await _open(context, Uri.parse(url), 'Could not open $platform.');
  }

  // ---------------------------------------------------------------------------
  // Share App
  // ---------------------------------------------------------------------------
  static Future<void> shareApp(BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await Share.share(
        CompanyInfo.shareMessage,
        subject: CompanyInfo.name,
      );
    } catch (_) {
      _showMessage(messenger, 'Could not open the share menu.');
    }
  }
}
