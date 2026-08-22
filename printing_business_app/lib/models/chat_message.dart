
class ChatMessage {
  final String text;

  /// True for the customer's own message, false for the bot's reply.
  final bool isUser;


  final bool fromAi;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.fromAi = false,
  });
}
