import 'company_info.dart';
import 'services_data.dart';
import '../models/service.dart';

/// One rule for the chatbot: if the user's message contains any of [keywords],
/// the bot replies with [answer].
class ChatRule {
  final List<String> keywords;
  final String answer;

  const ChatRule(this.keywords, this.answer);
}

/// A simple rule based chatbot (the "AI Service Helper" in the navigation flow).
///
/// It is not a machine learning model and it does not call any online AI
/// service. It lowercases the user's message and looks for known keywords.
/// The rule with the most keyword matches wins.
class ChatBot {
  ChatBot._();

  static const String greeting =
      'Hello! I am the service helper for ${CompanyInfo.name}. '
      'You can ask me about our services, prices, location, business hours or '
      'how to request a quote.';

  /// Suggested questions shown as tappable chips in the chat screen.
  static const List<String> suggestedQuestions = <String>[
    'What services do you provide?',
    'What printing services do you offer?',
    'What advertising services do you offer?',
    'How can I contact you?',
    'Where are you located?',
    'How can I request a quote?',
    'What are your business hours?',
  ];

  static const List<ChatRule> _rules = <ChatRule>[
    ChatRule(
      <String>['hello', 'hi ', 'hey', 'salam', 'assalam', 'good morning',
          'good evening'],
      'Hello! How can I help you today? You can ask about our services, '
      'location, business hours or quotations.',
    ),
    ChatRule(
      <String>['printing service', 'printing', 'print', 'business card',
          'card', 'banner', 'poster'],
      'Our printing services are: '
      'Business Cards (card design and printing) and '
      'Banners (indoor and outdoor banners in any size). '
      'Open the Services page to see them with pictures.',
    ),
    ChatRule(
      <String>['advertising service', 'advertising', 'advert', 'ads',
          'ad ', 'marketing', 'logo', 'social media', 'facebook post'],
      'Our advertising services are: '
      'Logo Design (basic company logo design) and '
      'Social Media Ads (post and advert design). '
      'Open the Services page for more information.',
    ),
    ChatRule(
      <String>['service', 'services', 'what do you do', 'offer',
          'provide'],
      'We provide printing and advertising services: Business Cards, Banners, '
      'Logo Design and Social Media Ads. Please visit our Services page to see '
      'the available services.',
    ),
    ChatRule(
      <String>['quote', 'quotation', 'estimate', 'how much', 'cost',
          'price', 'rate', 'charge'],
      'We prepare a quotation for each order because the price depends on the '
      'size, quantity and material. Tap "Request a Quote" on the Home screen, '
      'fill in the short form and we will get back to you.',
    ),
    ChatRule(
      <String>['contact', 'call', 'phone', 'number', 'whatsapp', 'email',
          'reach', 'talk'],
      'You can reach us from the Contact page. It has Call Now, WhatsApp and '
      'Email buttons, plus our social media links.',
    ),
    ChatRule(
      <String>['where', 'location', 'address', 'map', 'find you',
          'shop', 'office', 'direction'],
      'Our address is shown on the Contact page, together with an '
      '"Open in Google Maps" button that gives you directions.',
    ),
    ChatRule(
      <String>['hour', 'open', 'close', 'timing', 'time', 'when',
          'available', 'holiday'],
      'Our business hours are: ${CompanyInfo.businessHours}',
    ),
    ChatRule(
      <String>['work', 'sample', 'portfolio', 'gallery', 'previous',
          'example', 'photo', 'picture'],
      'You can see examples of our previous work on the Gallery page. Tap any '
      'picture to view it larger.',
    ),
    ChatRule(
      <String>['delivery', 'how long', 'days', 'fast', 'urgent',
          'deadline'],
      'Delivery time depends on the job and the quantity. Please send a quote '
      'request or contact us directly and we will confirm a date for you.',
    ),
    ChatRule(
      <String>['thank', 'thanks', 'bye', 'goodbye'],
      'You are welcome. Feel free to contact us any time.',
    ),
  ];

  static const String _fallback =
      'Sorry, I did not understand that. I can help with our services, prices '
      'and quotations, our location, our business hours, or how to contact us. '
      'You can also tap one of the suggested questions below.';

  /// Returns the bot's reply for [message].
  static String reply(String message) {
    final String text = ' ${message.toLowerCase().trim()} ';
    if (text.trim().isEmpty) {
      return _fallback;
    }

    ChatRule? best;
    int bestScore = 0;

    for (final ChatRule rule in _rules) {
      int score = 0;
      for (final String keyword in rule.keywords) {
        if (text.contains(keyword)) {
          score++;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        best = rule;
      }
    }

    return best == null ? _fallback : best.answer;
  }

  /// Used by the "AI Suggest a Suitable Service" button on the quote form.
  ///
  /// Looks for service related words in the customer's description and returns
  /// the closest matching service, or null when nothing matches.
  static Service? suggestService(String description) {
    final String text = description.toLowerCase();

    const Map<int, List<String>> hints = <int, List<String>>{
      1: <String>['business card', 'visiting card', 'name card', 'card'],
      2: <String>['banner', 'poster', 'backdrop', 'signboard', 'sign',
          'flex', 'billboard'],
      3: <String>['logo', 'brand', 'branding', 'monogram', 'icon'],
      4: <String>['social media', 'facebook', 'instagram', 'advert', 'ads',
          'ad ', 'post design', 'campaign'],
    };

    int bestId = 0;
    int bestScore = 0;

    hints.forEach((int serviceId, List<String> words) {
      int score = 0;
      for (final String word in words) {
        if (text.contains(word)) {
          score++;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestId = serviceId;
      }
    });

    if (bestId == 0) {
      return null;
    }
    return ServicesData.byId(bestId);
  }
}
