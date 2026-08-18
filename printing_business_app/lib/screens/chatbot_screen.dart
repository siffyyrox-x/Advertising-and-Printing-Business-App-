import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/chatbot_data.dart';
import '../data/database_helper.dart';
import '../models/ai_request.dart';
import '../models/chat_message.dart';
import '../utils/ai_service.dart';
import 'quote_screen.dart';

/// Opens the chatbot ("AI Service Helper" in the navigation flow diagram).
Future<void> openChatbotScreen(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => const ChatbotScreen(),
    ),
  );
}

/// The Service Helper chat screen.
///
/// It answers in two ways:
///
/// 1. ONLINE  - if an API key was supplied at build time, the question is sent
///              to Google's free Gemini API, which can answer almost anything
///              about the shop in natural language.
/// 2. OFFLINE - if there is no key, no internet, or the request fails, the
///              built-in rule based bot in chatbot_data.dart answers instead.
///
/// Every exchange is saved to the ai_requests table (the AI_REQUEST entity
/// from the schema diagram).
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

  /// True while we are waiting for the online answer.
  bool _isThinking = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String rawText) async {
    final String text = rawText.trim();
    if (text.isEmpty || _isThinking) {
      return;
    }

    // The history to send to the API, taken before the new message is added.
    final List<ChatMessage> history = List<ChatMessage>.from(_messages);

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isThinking = true;
    });
    _inputController.clear();
    _scrollToBottom();

    // Try the online AI first. It returns null if it is off or unreachable.
    final String? aiAnswer = await AiService.ask(text, history: history);

    // The user may have left the screen while we were waiting.
    if (!mounted) {
      return;
    }

    final bool usedAi = aiAnswer != null;
    final String answer = aiAnswer ?? ChatBot.reply(text);

    setState(() {
      _isThinking = false;
      _messages.add(ChatMessage(text: answer, isUser: false, fromAi: usedAi));
    });
    _scrollToBottom();

    await _saveExchange(prompt: text, answer: answer, usedAi: usedAi);
  }

  /// Stores one question and answer in the ai_requests table.
  /// Wrapped in try/catch so a database problem can never break the chat.
  Future<void> _saveExchange({
    required String prompt,
    required String answer,
    required bool usedAi,
  }) async {
    try {
      await DatabaseHelper.instance.insertAiRequest(
        AiRequest(
          customerPrompt: prompt,
          aiResponse: answer,
          source: usedAi ? AiRequest.sourceOnline : AiRequest.sourceOffline,
          createdAt: DateTime.now(),
        ),
      );
    } catch (_) {
      // Saving history is a nice-to-have, not something worth an error popup.
    }
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

  void _clearChat() {
    setState(() {
      _messages
        ..clear()
        ..add(const ChatMessage(text: ChatBot.greeting, isUser: false));
      _isThinking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Helper'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Clear chat',
            icon: const Icon(Icons.refresh),
            onPressed: _clearChat,
          ),
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
            const _ModeBanner(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                // One extra row at the end for the "typing" bubble.
                itemCount: _messages.length + (_isThinking ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index >= _messages.length) {
                    return const _TypingBubble();
                  }
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
              onPressed: _isThinking ? null : () => _send(question),
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
              enabled: !_isThinking,
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
            onPressed:
                _isThinking ? null : () => _send(_inputController.text),
            icon: const Icon(Icons.send),
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }
}

/// A thin strip telling the user whether the online AI is switched on.
class _ModeBanner extends StatelessWidget {
  const _ModeBanner();

  @override
  Widget build(BuildContext context) {
    final bool online = AiService.isEnabled;

    return Container(
      width: double.infinity,
      color: online ? const Color(0xFFE8F5E9) : const Color(0xFFEEEEEE),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Row(
        children: <Widget>[
          Icon(
            online ? Icons.auto_awesome : Icons.offline_bolt_outlined,
            size: 15,
            color: online ? const Color(0xFF2E7D32) : const Color(0xFF616161),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              online
                  ? 'Online AI assistant is on. Ask anything about our services.'
                  : 'Offline mode: answering from the built-in question list.',
              style: TextStyle(
                fontSize: 11.5,
                color:
                    online ? const Color(0xFF1B5E20) : const Color(0xFF616161),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The three dots shown while the online answer is being fetched.
class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Typing...', style: TextStyle(fontSize: 13)),
          ],
        ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: isUser ? Colors.white : const Color(0xFF212121),
                ),
              ),
              if (message.fromAi) ...<Widget>[
                const SizedBox(height: 5),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.auto_awesome,
                        size: 11, color: Color(0xFF2E7D32)),
                    SizedBox(width: 4),
                    Text(
                      'answered by AI',
                      style: TextStyle(fontSize: 10, color: Color(0xFF2E7D32)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
