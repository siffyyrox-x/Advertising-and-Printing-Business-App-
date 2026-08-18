import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/company_info.dart';
import '../data/services_data.dart';
import '../models/chat_message.dart';
import '../models/service.dart';

/// Talks to Google's free Gemini API so the Service Helper can answer questions
/// that the built-in rule based bot does not have a rule for.
///
/// SECURITY: the API key is NOT stored in this file and is NOT committed to
/// GitHub. It is passed in at build time:
///
///   flutter run --dart-define=GEMINI_API_KEY=your_key_here
///
/// If no key is supplied, [isEnabled] is false, every call returns null, and
/// the app silently uses the offline rule based bot instead. The app works
/// perfectly well with no key at all.
class AiService {
  AiService._();

  /// Read at compile time from --dart-define. Empty when not supplied.
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  /// Free tier model. Change this one line if Google renames the model.
  static const String modelName = 'gemini-3.5-flash-lite';

  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// How many earlier messages are sent along so the bot remembers the
  /// conversation. Kept small to stay fast and inside the free quota.
  static const int _historyLimit = 8;

  static const Duration _timeout = Duration(seconds: 25);

  /// True when an API key was supplied at build time.
  static bool get isEnabled => _apiKey.trim().isNotEmpty;

  // ---------------------------------------------------------------------------
  // The instructions that turn a general model into "our shop's assistant"
  // ---------------------------------------------------------------------------
  static String get _systemInstruction {
    final StringBuffer services = StringBuffer();
    for (final Service service in ServicesData.active) {
      services.writeln(
        '- ${service.title} (${service.category}): ${service.description} '
        '${service.priceNote}',
      );
    }

    return '''
You are the friendly customer assistant for ${CompanyInfo.name}, a printing and
advertising shop. Answer only as this shop's assistant.

Services we offer:
${services.toString().trim()}

Business hours: ${CompanyInfo.businessHours}
Phone: ${CompanyInfo.phone}
WhatsApp: ${CompanyInfo.whatsappNumber}
Email: ${CompanyInfo.email}

Rules you must follow:
- Keep replies short and friendly, 2 to 4 sentences, plain text only.
- Do not use markdown, bullet symbols, asterisks or emoji.
- Never invent an exact price. Prices depend on size, quantity and material,
  so ask the customer to send a quote request from the Request Quote screen.
- If someone asks about something we do not offer, say so politely and suggest
  the closest service we do offer.
- If a question is not about this shop, politely bring the topic back to our
  printing and advertising services.
''';
  }

  // ---------------------------------------------------------------------------
  // The API call
  // ---------------------------------------------------------------------------

  /// Sends [question] to Gemini and returns the answer.
  ///
  /// Returns null when there is no API key, no internet, the request times out,
  /// or the response cannot be read. The caller should fall back to the offline
  /// rule based bot whenever null comes back.
  static Future<String?> ask(
    String question, {
    List<ChatMessage> history = const <ChatMessage>[],
  }) async {
    if (!isEnabled || question.trim().isEmpty) {
      return null;
    }

    final Uri uri = Uri.parse('$_endpoint/$modelName:generateContent?key=$_apiKey');

    final Map<String, Object?> requestBody = <String, Object?>{
      'systemInstruction': <String, Object?>{
        'parts': <Map<String, Object?>>[
          <String, Object?>{'text': _systemInstruction},
        ],
      },
      'contents': _buildContents(history, question),
      'generationConfig': <String, Object?>{
        'temperature': 0.4,
        'maxOutputTokens': 512,
      },
    };

    try {
      final http.Response response = await http
          .post(
            uri,
            headers: <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        return null;
      }
      return _readAnswer(response.body);
    } catch (_) {
      // No internet, DNS failure, timeout, bad JSON: fall back to offline mode.
      return null;
    }
  }

  /// Builds the conversation array the API expects.
  static List<Map<String, Object?>> _buildContents(
    List<ChatMessage> history,
    String question,
  ) {
    final List<ChatMessage> recent = history.length > _historyLimit
        ? history.sublist(history.length - _historyLimit)
        : List<ChatMessage>.from(history);

    // The conversation must start with a user turn, so drop any bot messages
    // at the front (the opening greeting, for example).
    while (recent.isNotEmpty && !recent.first.isUser) {
      recent.removeAt(0);
    }

    final List<Map<String, Object?>> contents = <Map<String, Object?>>[];
    for (final ChatMessage message in recent) {
      contents.add(<String, Object?>{
        'role': message.isUser ? 'user' : 'model',
        'parts': <Map<String, Object?>>[
          <String, Object?>{'text': message.text},
        ],
      });
    }

    contents.add(<String, Object?>{
      'role': 'user',
      'parts': <Map<String, Object?>>[
        <String, Object?>{'text': question.trim()},
      ],
    });

    return contents;
  }

  /// Digs the reply text out of the JSON response, checking every step so a
  /// missing field returns null instead of throwing.
  static String? _readAnswer(String responseBody) {
    final Object? decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final Object? candidates = decoded['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      return null;
    }

    final Object? candidate = candidates.first;
    if (candidate is! Map<String, dynamic>) {
      return null;
    }

    final Object? content = candidate['content'];
    if (content is! Map<String, dynamic>) {
      return null;
    }

    final Object? parts = content['parts'];
    if (parts is! List) {
      return null;
    }

    final StringBuffer answer = StringBuffer();
    for (final Object? part in parts) {
      if (part is Map<String, dynamic> && part['text'] is String) {
        answer.write(part['text'] as String);
      }
    }

    final String text = answer.toString().trim();
    return text.isEmpty ? null : text;
  }
}
