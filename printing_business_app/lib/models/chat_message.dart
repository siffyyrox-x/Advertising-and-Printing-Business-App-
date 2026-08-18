/// One line of the conversation on the Service Helper screen.
class ChatMessage {
  final String text;

  /// True for the customer's own message, false for the bot's reply.
  final bool isUser;

  /// True when this reply came from the online Gemini API rather than the
  /// built-in rule based bot. Used to show a small "AI" tag on the bubble.
  final bool fromAi;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.fromAi = false,
  });
}
