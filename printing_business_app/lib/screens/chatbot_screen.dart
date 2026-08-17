import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/chatbot_data.dart';
import 'quote_screen.dart';

/// Opens the chatbot ("AI Service Helper" in the navigation flow diagram).
Future<void> openChatbotScreen(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => const ChatbotScreen(),
    ),
  );
}

/// One line of the conversation.
class ChatMessage {
  final String text;
  final bool isUser;

  const ChatMessage({required this.text, required this.isUser});
}

/// A simple rule based chat screen.
///
/// The reply comes from [ChatBot.reply], which matches keywords in the user's
/// message against a small list of rules. Nothing is sent over the internet and
/// no API key is used.
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = <ChatMessage>[
    const ChatMessage(text: ChatBot.greeting, isUser: false),
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(String rawText) {
    final String text = rawText.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _messages.add(ChatMessage(text: ChatBot.reply(text), isUser: false));
    });

    _inputController.clear();
    _scrollToBottom();
  }

  /// Scrolls to the newest message after the list has been rebuilt.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Helper'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Request a Quote',
            icon: const Icon(Icons.request_quote_outlined),
            onPressed: () => openQuoteScreen(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return _MessageBubble(message: _messages[index]);
                },
              ),
            ),
            _buildSuggestions(),
            const Divider(height: 1),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: ChatBot.suggestedQuestions.length,
        itemBuilder: (BuildContext context, int index) {
          final String question = ChatBot.suggestedQuestions[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: ActionChip(
              label: Text(question, style: const TextStyle(fontSize: 12)),
              onPressed: () => _send(question),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _inputController,
              textInputAction: TextInputAction.send,
              onSubmitted: _send,
              decoration: const InputDecoration(
                hintText: 'Type your question...',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () => _send(_inputController.text),
            icon: const Icon(Icons.send),
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }
}

/// One chat bubble. User messages are on the right, bot messages on the left.
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isUser ? AppTheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUser ? AppTheme.primary : AppTheme.cardBorder,
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              color: isUser ? Colors.white : const Color(0xFF212121),
            ),
          ),
        ),
      ),
    );
  }
}
