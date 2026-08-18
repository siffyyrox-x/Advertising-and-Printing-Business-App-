/// Matches the AI_REQUEST entity from the project schema diagram.
///
/// One row is stored for every question the customer asks the Service Helper,
/// together with the answer that was given and where the answer came from.
class AiRequest {
  final int? aiRequestId;

  /// Optional link to a quote request (FK in the schema diagram).
  /// Null when the customer was just chatting.
  final int? quoteId;

  final String customerPrompt;
  final String aiResponse;

  /// 'online' when the Gemini API answered, 'offline' when the built-in
  /// rule based bot answered. Useful for demonstrating the fallback.
  final String source;

  final DateTime createdAt;

  const AiRequest({
    this.aiRequestId,
    this.quoteId,
    required this.customerPrompt,
    required this.aiResponse,
    required this.source,
    required this.createdAt,
  });

  static const String sourceOnline = 'online';
  static const String sourceOffline = 'offline';

  Map<String, Object?> toMap() {
    return <String, Object?>{
      if (aiRequestId != null) 'ai_request_id': aiRequestId,
      'quote_id': quoteId,
      'customer_prompt': customerPrompt,
      'ai_response': aiResponse,
      'source': source,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AiRequest.fromMap(Map<String, Object?> map) {
    return AiRequest(
      aiRequestId: map['ai_request_id'] as int?,
      quoteId: map['quote_id'] as int?,
      customerPrompt: (map['customer_prompt'] as String?) ?? '',
      aiResponse: (map['ai_response'] as String?) ?? '',
      source: (map['source'] as String?) ?? sourceOffline,
      createdAt:
          DateTime.tryParse((map['created_at'] as String?) ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
