import 'package:flutter/material.dart';
import 'dart:async';

enum Sender { user, ai }

class ChatMessage {
  final Sender sender;
  final String text;
  final DateTime timestamp;
  ChatMessage({required this.sender, required this.text, required this.timestamp});
}

class AiAssistantController extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  final ValueNotifier<bool> isTyping = ValueNotifier(false);
  final ValueNotifier<bool> hasError = ValueNotifier(false);
  final ValueNotifier<String?> lastErrorMessage = ValueNotifier(null);

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final userMessage = ChatMessage(sender: Sender.user, text: text, timestamp: DateTime.now());
    _messages.add(userMessage);
    notifyListeners();
    await _simulateAiResponse(userMessage);
  }

  Future<void> _simulateAiResponse(ChatMessage userMessage) async {
    isTyping.value = true;
    hasError.value = false;
    lastErrorMessage.value = null;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    try {
      if (userMessage.text.toLowerCase().contains('error')) throw Exception('Simulated AI error');
      final aiText = _generateDummyResponse(userMessage.text);
      final aiMessage = ChatMessage(sender: Sender.ai, text: aiText, timestamp: DateTime.now());
      _messages.add(aiMessage);
      isTyping.value = false;
      notifyListeners();
    } catch (e) {
      isTyping.value = false;
      hasError.value = true;
      lastErrorMessage.value = 'AI failed to respond. Tap to retry.';
      notifyListeners();
    }
  }

  String _generateDummyResponse(String userInput) {
  final lower = userInput.toLowerCase();

  if (lower.contains('2 bhk') || lower.contains('2 bedroom')) {
    return 'Looking for a 2 BHK under 40 lakhs? I can suggest some affordable listings in your preferred area.';
  } else if (lower.contains('budget') || lower.contains('under')) {
    return 'I can filter properties within your budget. Which city or locality are you interested in?';
  } else if (lower.contains('rent')) {
    return 'Are you looking to rent or buy the property?';
  } else if (lower.contains('buy')) {
    return 'I can show you trending properties available for purchase.';
  } else if (lower.contains('sell')) {
    return 'Are you looking to sell a property? I can help you estimate the market value.';
  } else if (lower.contains('hi') || lower.contains('hello')) {
    return 'Hello! I’m your AI real estate assistant. How can I help you find your dream property today?';
  } else {
    return 'Got it! Could you tell me more details like location, budget, or type of property?';
  }
}


  Future<void> retryLastResponse() async {
    if (!hasError.value) return;
    ChatMessage? lastUser;
    for (final m in _messages.reversed) {
      if (m.sender == Sender.user) {
        lastUser = m;
        break;
      }
    }
    if (lastUser == null) {
      hasError.value = false;
      lastErrorMessage.value = null;
      notifyListeners();
      return;
    }
    hasError.value = false;
    lastErrorMessage.value = null;
    notifyListeners();
    await _simulateAiResponse(lastUser);
  }

  void clearConversation() {
    _messages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    isTyping.dispose();
    hasError.dispose();
    lastErrorMessage.dispose();
    super.dispose();
  }
}

class AiAssistantScreen extends StatefulWidget {
  final AiAssistantController controller;
  AiAssistantScreen({super.key, AiAssistantController? controller})
      : controller = controller ?? _DefaultController().controller;
  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _DefaultController {
  final AiAssistantController controller = AiAssistantController();
  _DefaultController();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_scrollToBottom);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scrollToBottom);
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    _focusNode.requestFocus();
    await widget.controller.sendMessage(text);
  }

  void _confirmClear() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const ClearConfirmationDialog(),
    );
    if (confirm == true) widget.controller.clearConversation();
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('AI Assistant'),
      actions: [
        IconButton(
          onPressed: _confirmClear,
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Clear conversation',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: const Color(0xFFF5ECD9),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: widget.controller,
                builder: (_, __) {
                  final messages = widget.controller.messages;
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: messages.length +
                        (widget.controller.isTyping.value ? 1 : 0) +
                        (widget.controller.hasError.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < messages.length) {
                        final message = messages[index];
                        return ChatBubble(message: message);
                      } else if (widget.controller.isTyping.value && index == messages.length) {
                        return const TypingIndicator();
                      } else if (widget.controller.hasError.value && index == messages.length) {
                        return GestureDetector(
                          onTap: widget.controller.retryLastResponse,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                widget.controller.lastErrorMessage.value ?? 'Error occurred',
                                style: TextStyle(color: theme.colorScheme.onErrorContainer),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
              ),
            ),
            InputComposer(
              controller: _textController,
              focusNode: _focusNode,
              onSend: _handleSend,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == Sender.user;
    final theme = Theme.of(context);
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bgColor = isUser
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isUser
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
          ),
          child: Text(message.text, style: TextStyle(color: textColor, fontSize: 15)),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4, right: 8, left: 8),
          child: Text(
            _formatTime(message.timestamp),
            style: theme.textTheme.bodySmall?.copyWith(color: const Color.fromARGB(255, 236, 230, 192)),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class InputComposer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  const InputComposer({super.key, required this.controller, required this.focusNode, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSend = controller.text.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 5,
              onChanged: (_) => (context as Element).markNeedsBuild(),
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: canSend ? onSend : null,
            icon: const Icon(Icons.send_rounded),
            color: canSend ? theme.colorScheme.primary : Colors.grey,
            tooltip: 'Send message',
          ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});
  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late Timer _timer;
  String _dots = '';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        if (_dots.length >= 3) {
          _dots = '';
        } else {
          _dots += '.';
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const CircleAvatar(radius: 10, child: Icon(Icons.android, size: 12)),
          const SizedBox(width: 8),
          Text('AI is typing$_dots', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class ClearConfirmationDialog extends StatelessWidget {
  const ClearConfirmationDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Clear conversation?'),
      content: const Text('This will delete all chat messages.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Clear'),
        ),
      ],
    );
  }
}

void main() {
  runApp(const AiAssistantApp());
}

class AiAssistantApp extends StatelessWidget {
  const AiAssistantApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Assistant Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: AiAssistantScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
