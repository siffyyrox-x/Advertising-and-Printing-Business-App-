import 'package:flutter/material.dart';

import '../models/social_link.dart';


class CompanyInfo {
  CompanyInfo._();

  /// Matches the COMPANY entity from the project schema diagram.
  static const int companyId = 1;

  static const String name = 'ABC Printing & Advertising';
  static const String tagline = 'Printing made simple';

  static const String about =
      'We are a printing and advertising company. We design and print business '
      'cards, banners, logos and social media adverts for small businesses. '
      'Tell us what you need and we will prepare a quotation for you.';

  /// Used for the "Call Now" button. Digits and a leading + only, for example
  /// '+8801712345678'.
  static const String phone = '01988058487';

  /// Used for the WhatsApp button. Country code without '+' or spaces,
  /// for example '8801712345678'.
  // Bangladesh country code (880) + the number without the leading 0.
  static const String whatsappNumber = '8801988058487';

  /// Used for the Email button.
  static const String email = 'sifat.sadakin2002@gmail.com';

  /// Shown on the Contact screen and used for the "Open in Google Maps" search.
  static const String address = 'YOUR_COMPANY_ADDRESS';

  /// Optional. If you have a Google Maps share link, paste it here and it will
  /// be used instead of searching for [address]. Leave it empty otherwise.
  static const String mapUrl =
      'https://www.google.com/maps?vet=10CAAQoqAOahcKEwiIxZmLmKiWAxUAAAAAHQAAAAAQBg..i&rlz=1C5CHFA_enBD1087BD1087&sca_esv=adee44be14316a28&mstk=AUtExfBbo5paA1KMXr-YQkkv6Bp5cBLiPLmF61PuWjm0UVuAuct748zdgXtqSS17y9hk4XGtOeqCbkd8mZmcKeoc83B0D0YiE-Hl0fFspM_aJe-zRBS7pZfJtwsuzL7rP5uJjBsimea_cnK8MtTjVUdWkZ5tDVz7LQen0n7eq2WiSbsV_WbKJ-OGexvxXG7oxjvQyklH11bYO1Y1sQUd_El_gtNF7Rv_jficZ4ER3HoxV7YyQlzcxZ09iQY_qyhVrL14JTOZmP7s8maIddVzfELnrELr&pvq=Cg0vZy8xMXEyeWZ2anltgAEB&fvr=1&cs=1&um=1&ie=UTF-8&fb=1&gl=bd&sa=X&ftid=0x3755c7ed6c30ac9b:0xc99fbe966df1c503';

  static const String businessHours =
      'Saturday to Thursday, 9:00 AM to 8:00 PM. Closed on Friday.';

  /// Text used by the "Share App" button.
  static const String shareMessage =
      'Check out $name. We do business cards, banners, logo design and social '
      'media adverts. Download our app to see our work and request a quote.';

  /// Matches the SOCIAL_LINK entity from the project schema diagram.
  static const List<SocialLink> socialLinks = <SocialLink>[
    SocialLink(
      socialId: 1,
      platform: 'Facebook',
      url: 'https://www.facebook.com/CharlesLeclercOfficiel/',
      icon: Icons.facebook,
    ),
    SocialLink(
      socialId: 2,
      platform: 'Instagram',
      url: 'https://likeshop.me/etsy',
      icon: Icons.camera_alt_outlined,
    ),
    SocialLink(
      socialId: 3,
      platform: 'YouTube',
      url: 'https://www.youtube.com/Radiohead',
      icon: Icons.play_circle_outline,
    ),
  ];

  /// Returns true when [value] is still an unedited placeholder.
  static bool isPlaceholder(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty || trimmed.startsWith('YOUR_');
  }

  /// True when the location can be opened, either from a written address or
  /// from a Google Maps link.
  static bool get hasLocation =>
      !isPlaceholder(address) || !isPlaceholder(mapUrl);

  /// True while any of the main contact details are still placeholders.
  /// The Contact screen uses this to show a small setup reminder.
  static bool get hasUnconfiguredDetails =>
      isPlaceholder(phone) ||
      isPlaceholder(whatsappNumber) ||
      isPlaceholder(email) ||
      !hasLocation;
}
