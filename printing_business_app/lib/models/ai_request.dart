
class AiRequest {
  final int? aiRequestId;

  final int? quoteId;

  final String customerPrompt;
  final String aiResponse;


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
