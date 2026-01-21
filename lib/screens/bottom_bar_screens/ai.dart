import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

enum Sender { user, ai }

class ChatMessage {
  final Sender sender;
  final String text;
  final DateTime timestamp;
  final bool showAvatar;
  ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.showAvatar = false,
  });
}

class AiAssistantController extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  final ValueNotifier<bool> isTyping = ValueNotifier(false);
  final ValueNotifier<bool> hasError = ValueNotifier(false);
  final ValueNotifier<String?> lastErrorMessage = ValueNotifier(null);

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Map<String, dynamic> userPreferences = {
    'name': '',
    'budget': '',
    'location': '',
    'propertyType': '',
    'bedrooms': '',
  };

  int conversationStep = 0;
  bool isFirstInteraction = true;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    print('[DEBUG] Sending message: $text');

    final userMessage = ChatMessage(
      sender: Sender.user,
      text: text,
      timestamp: DateTime.now(),
      showAvatar: false,
    );
    _messages.add(userMessage);
    notifyListeners();

    _updateUserPreferences(text);
    await _generateAiResponse(text);
  }

  void _updateUserPreferences(String text) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains('budget') ||
        RegExp(r'\d+\s*(lakh|lac|cr|crore)').hasMatch(text)) {
      userPreferences['budget'] = text;
    }

    if (lowerText.contains('bangalore') ||
        lowerText.contains('bengaluru') ||
        lowerText.contains('hyderabad') ||
        lowerText.contains('chennai') ||
        lowerText.contains('mumbai') ||
        lowerText.contains('delhi') ||
        lowerText.contains('pune')) {
      userPreferences['location'] = text;
    }

    if (lowerText.contains('2 bhk') ||
        lowerText.contains('2 bedroom') ||
        lowerText.contains('2bhk')) {
      userPreferences['bedrooms'] = '2';
      userPreferences['propertyType'] = 'Apartment';
    } else if (lowerText.contains('3 bhk') ||
        lowerText.contains('3 bedroom') ||
        lowerText.contains('3bhk')) {
      userPreferences['bedrooms'] = '3';
      userPreferences['propertyType'] = 'Apartment';
    } else if (lowerText.contains('villa') || lowerText.contains('house')) {
      userPreferences['propertyType'] = 'Villa';
    } else if (lowerText.contains('plot') || lowerText.contains('land')) {
      userPreferences['propertyType'] = 'Plot';
    }
  }

  Future<void> _generateAiResponse(String userMessage) async {
    isTyping.value = true;
    notifyListeners();

    final typingDelay = 500 + Random().nextInt(1500);
    await Future.delayed(Duration(milliseconds: typingDelay));

    try {
      final response = _createRealisticResponse(userMessage);
      final responses = _splitResponse(response);

      for (int i = 0; i < responses.length; i++) {
        if (i > 0) {
          await Future.delayed(const Duration(milliseconds: 800));
        }

        final aiMessage = ChatMessage(
          sender: Sender.ai,
          text: responses[i],
          timestamp: DateTime.now(),
          showAvatar: i == 0,
        );

        _messages.add(aiMessage);
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 100));
      }

      conversationStep++;
      isTyping.value = false;
      isFirstInteraction = false;
      notifyListeners();
    } catch (e) {
      isTyping.value = false;
      hasError.value = true;
      lastErrorMessage.value = 'Oops! Something went wrong. Tap to try again.';
      notifyListeners();
    }
  }

  List<String> _splitResponse(String response) {
    final sentences = response.split(RegExp(r'(?<=[.!?])\s+'));
    final List<String> chunks = [];
    String currentChunk = '';

    for (final sentence in sentences) {
      if (currentChunk.isEmpty) {
        currentChunk = sentence;
      } else if ((currentChunk.length + sentence.length) < 100) {
        currentChunk += ' $sentence';
      } else {
        chunks.add(currentChunk);
        currentChunk = sentence;
      }
    }

    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk);
    }

    return chunks.length > 1 ? chunks : [response];
  }

  String _createRealisticResponse(String userInput) {
    final lower = userInput.toLowerCase();
    final random = Random();

    if (isFirstInteraction &&
        (lower.contains('hi') ||
            lower.contains('hello') ||
            lower.contains('hey'))) {
      final greetings = [
        "Hey there! 👋 I'm your property assistant. Looking to buy, rent, or sell today?",
        "Hello! Ready to find your dream property? Tell me what you're looking for!",
        "Hi! I'm here to help you with your property search. What brings you here today?",
      ];
      return greetings[random.nextInt(greetings.length)];
    }

    if (lower.contains('apartment') || lower.contains('flat')) {
      final responses = [
        "Great choice! Apartments offer great amenities and security. ${userPreferences['location']?.isNotEmpty == true ? 'In ${userPreferences['location']}, ' : ''}What's your budget range?",
        "Apartments are popular for their facilities! ${userPreferences['bedrooms']?.isNotEmpty == true ? 'Looking for ${userPreferences['bedrooms']} BHK? ' : ''}Any preferred localities?",
        "Nice! ${userPreferences['budget']?.isNotEmpty == true ? 'With your budget of ${userPreferences['budget']}, ' : ''}I can suggest some excellent apartment options.",
      ];
      return responses[random.nextInt(responses.length)];
    }

    if (lower.contains('villa') || lower.contains('independent house')) {
      final responses = [
        "Villas offer great privacy and space! ${userPreferences['location']?.isNotEmpty == true ? 'In ${userPreferences['location']}, ' : ''}what's your preferred budget?",
        "Excellent! Villas are perfect for families. ${userPreferences['bedrooms']?.isNotEmpty == true ? 'Looking for ${userPreferences['bedrooms']} bedroom villa? ' : ''}Any specific requirements?",
        "Villas provide luxury living! ${userPreferences['budget']?.isNotEmpty == true ? 'With ${userPreferences['budget']} budget, ' : ''}I can show some premium options.",
      ];
      return responses[random.nextInt(responses.length)];
    }

    if (lower.contains('budget') ||
        lower.contains('price') ||
        lower.contains('cost') ||
        RegExp(r'\d+\s*(lakh|lac|cr|crore)').hasMatch(userInput)) {
      final responses = [
        "Got it! Based on ${userPreferences['budget']?.isNotEmpty == true ? 'your budget of ${userPreferences['budget']}' : 'that budget'}, I can suggest properties that match your requirements. ${userPreferences['location']?.isEmpty == true ? 'Which area are you interested in?' : ''}",
        "Perfect! ${userPreferences['budget']?.isNotEmpty == true ? '${userPreferences['budget']} is a good range. ' : ''}${userPreferences['propertyType']?.isEmpty == true ? 'Are you looking for apartments or villas?' : 'I\'ll filter properties accordingly.'}",
        "Budget noted! ${userPreferences['location']?.isEmpty == true ? 'Could you specify the location?' : 'Let me check available options.'}",
      ];
      return responses[random.nextInt(responses.length)];
    }

    if (lower.contains('bangalore') ||
        lower.contains('bengaluru') ||
        lower.contains('hyderabad') ||
        lower.contains('chennai') ||
        lower.contains('mumbai') ||
        lower.contains('delhi') ||
        lower.contains('pune') ||
        lower.contains('location') ||
        lower.contains('area')) {
      final responses = [
        "${userPreferences['location']?.isNotEmpty == true ? '${userPreferences['location']} has great options! ' : ''}${userPreferences['budget']?.isEmpty == true ? 'What\'s your budget range?' : 'Let me check properties in that area.'}",
        "Good choice! ${userPreferences['location']?.isNotEmpty == true ? '${userPreferences['location']} is a growing area. ' : ''}${userPreferences['propertyType']?.isEmpty == true ? 'Looking for apartments or villas?' : ''}",
        "Nice location! ${userPreferences['budget']?.isEmpty == true ? 'Could you share your budget?' : 'I\'ll show you the best options there.'}",
      ];
      return responses[random.nextInt(responses.length)];
    }

    if (lower.contains('bhk') ||
        lower.contains('bedroom') ||
        lower.contains('bed')) {
      final responses = [
        "${userPreferences['bedrooms']?.isNotEmpty == true ? '${userPreferences['bedrooms']} BHK properties are in high demand. ' : ''}${userPreferences['location']?.isEmpty == true ? 'Which location are you considering?' : ''}",
        "Good choice! ${userPreferences['bedrooms']?.isNotEmpty == true ? '${userPreferences['bedrooms']} bedroom ' : ''}properties offer great space. ${userPreferences['budget']?.isEmpty == true ? 'What\'s your budget?' : ''}",
        "Perfect! ${userPreferences['bedrooms']?.isNotEmpty == true ? 'I\'ll focus on ${userPreferences['bedrooms']} BHK options. ' : ''}${userPreferences['propertyType']?.isEmpty == true ? 'Apartments or villas?' : ''}",
      ];
      return responses[random.nextInt(responses.length)];
    }

    if (lower.contains('rent') || lower.contains('rental')) {
      final responses = [
        "Looking for rental properties? ${userPreferences['location']?.isEmpty == true ? 'Which area?' : 'Great choice!'} Rental rates vary based on location and amenities.",
        "Rental properties available! ${userPreferences['budget']?.isEmpty == true ? 'What\'s your monthly budget?' : 'Let me check rentals in your budget.'}",
        "Renting is a smart choice! ${userPreferences['propertyType']?.isEmpty == true ? 'Apartments or villas for rent?' : 'I\'ll find suitable rentals.'}",
      ];
      return responses[random.nextInt(responses.length)];
    }

    if (lower.contains('buy') || lower.contains('purchase')) {
      final responses = [
        "Ready to buy! ${userPreferences['location']?.isEmpty == true ? 'Which location interests you?' : 'Perfect timing for investment.'}",
        "Buying a property is a great investment! ${userPreferences['budget']?.isEmpty == true ? 'What\'s your investment budget?' : 'Let me find properties for purchase.'}",
        "Excellent! ${userPreferences['propertyType']?.isEmpty == true ? 'Looking to buy apartments or villas?' : 'I\'ll show buying options.'}",
      ];
      return responses[random.nextInt(responses.length)];
    }

    final defaultResponses = [
      "Got it! Could you share more details like preferred location, budget, or property type?",
      "I understand! To help you better, could you tell me your budget range and preferred location?",
      "Thanks for sharing! What type of property are you looking for - apartment, villa, or plot?",
      "Noted! Are you looking to buy or rent the property?",
      "Thanks! Could you specify the number of bedrooms you need?",
      "I see! Which city or locality are you interested in?",
      "Great! What's your approximate budget for the property?",
      "Understood! Are you looking for ready-to-move or under-construction properties?",
      "Got it! Do you have any specific amenities in mind like gym, pool, or security?",
    ];

    return defaultResponses[random.nextInt(defaultResponses.length)];
  }

  Future<void> retryLastResponse() async {
    if (!hasError.value || _messages.isEmpty) return;

    hasError.value = false;
    lastErrorMessage.value = null;
    notifyListeners();

    for (final m in _messages.reversed) {
      if (m.sender == Sender.user) {
        await _generateAiResponse(m.text);
        break;
      }
    }
  }

  void clearConversation() {
    _messages.clear();
    isTyping.value = false;
    hasError.value = false;
    lastErrorMessage.value = null;
    userPreferences.clear();
    conversationStep = 0;
    isFirstInteraction = true;
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

  List<Map<String, dynamic>> _supportProfiles = [];
  String? _currentAgentName;
  String? _currentAgentEmoji;

  @override
  void initState() {
    super.initState();
    _loadSupportProfiles();
    _addWelcomeMessage();

    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
    _scrollToBottom();
  }

  void _loadSupportProfiles() {
    _supportProfiles = [
      {"name": "Riya", "emoji": "👩‍💼", "role": "Property Expert"},
      {"name": "Priya", "emoji": "👩‍💻", "role": "Real Estate Advisor"},
      {"name": "Ananya", "emoji": "👩‍🔧", "role": "Home Consultant"},
    ];

    final randomIndex = Random().nextInt(_supportProfiles.length);
    _currentAgentName = _supportProfiles[randomIndex]["name"];
    _currentAgentEmoji = _supportProfiles[randomIndex]["emoji"];
  }

  void _addWelcomeMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final welcomeMessage = ChatMessage(
        sender: Sender.ai,
        text:
            "Hello! I'm $_currentAgentName, your personal property assistant. 🏡\n\nHow can I help you find your dream home today?",
        timestamp: DateTime.now(),
        showAvatar: true,
      );

      if (widget.controller.messages.isEmpty) {
        widget.controller._messages.add(welcomeMessage);
        if (mounted) {
          setState(() {});
        }
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    print('[UI] Sending message: $text');

    _textController.clear();
    _focusNode.requestFocus();

    try {
      await widget.controller.sendMessage(text);
    } catch (e) {
      print('[UI] Error sending message: $e');
    }
  }

  void _confirmClear() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const ClearConfirmationDialog(),
    );
    if (confirm == true) {
      widget.controller.clearConversation();
      _addWelcomeMessage();
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5ECD9),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD7CCC8).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF8B7355),
                child: Text(
                  _currentAgentEmoji ?? "👩‍💼",
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentAgentName ?? "Property Assistant",
                    style: const TextStyle(
                      color: Color(0xFF5D4037),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Real Estate Expert",
                    style: TextStyle(
                      color: const Color(0xFFA1887F),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "I'll help you find the perfect property 🏠",
            style: TextStyle(color: Color(0xFF8B7355), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD9),
      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount:
                    widget.controller.messages.length +
                    (widget.controller.isTyping.value ? 1 : 0) +
                    (widget.controller.hasError.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < widget.controller.messages.length) {
                    final message = widget.controller.messages[index];
                    return ChatBubble(
                      message: message,
                      agentEmoji: _currentAgentEmoji,
                    );
                  } else if (widget.controller.isTyping.value &&
                      index == widget.controller.messages.length) {
                    return const TypingIndicator();
                  } else if (widget.controller.hasError.value &&
                      index == widget.controller.messages.length) {
                    return GestureDetector(
                      onTap: widget.controller.retryLastResponse,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5E6E6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFD32F2F).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.refresh,
                              color: const Color(0xFFD32F2F),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                widget.controller.lastErrorMessage.value ??
                                    'Error occurred',
                                style: const TextStyle(
                                  color: Color(0xFFD32F2F),
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          Container(
            color: Colors.white,
            child: InputComposer(
              controller: _textController,
              focusNode: _focusNode,
              onSend: _handleSend,
            ),
          ),
        ],
      ),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5ECD9),
        elevation: 0,
        automaticallyImplyLeading: false, // ✅ This removes the back arrow
        title: Text(
          'Property Assistant',
          style: TextStyle(
            color: const Color(0xFF5D4037),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _confirmClear,
            icon: const Icon(Icons.delete_outline, color: Color(0xFF5D4037)),
            tooltip: 'Clear conversation',
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final String? agentEmoji;
  const ChatBubble({super.key, required this.message, this.agentEmoji});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == Sender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser && message.showAvatar)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF8B7355),
                child: Text(
                  agentEmoji ?? "👩‍💼",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            )
          else if (isUser)
            const SizedBox(width: 40),

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF8B7355)
                    : const Color(0xFFF5ECD9),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF5D4037),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0xFFA1887F).withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isUser)
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 4),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xFF8B7355),
                child: Icon(Icons.person, size: 12, color: Colors.white),
              ),
            )
          else if (!message.showAvatar)
            const SizedBox(width: 40),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $amPm';
  }
}

class InputComposer extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  const InputComposer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  @override
  State<InputComposer> createState() => _InputComposerState();
}

class _InputComposerState extends State<InputComposer> {
  bool _isTextFieldEmpty = true;
  final List<String> _quickReplies = [
    "2 BHK under 50L",
    "Apartments in Bangalore",
    "Villas for rent",
    "Budget 80L",
    "3 BHK ready to move",
    "Buy property",
  ];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isTextFieldEmpty = widget.controller.text.trim().isEmpty;
    });
  }

  void _onQuickReplyTap(String text) {
    widget.controller.text = text;
    widget.onSend(); // Send immediately when tapping quick reply
  }

  @override
  Widget build(BuildContext context) {
    final canSend = !_isTextFieldEmpty;

    return Column(
      children: [
        // Quick replies
        if (_isTextFieldEmpty)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quickReplies.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    label: Text(_quickReplies[index]),
                    onPressed: () => _onQuickReplyTap(_quickReplies[index]),
                    backgroundColor: const Color(0xFFF5ECD9),
                    labelStyle: const TextStyle(
                      color: Color(0xFF5D4037),
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),

        // Input field
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color(0xFFD7CCC8).withOpacity(0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      minLines: 1,
                      maxLines: 4,
                      onChanged: (_) => _onTextChanged(),
                      onSubmitted: (_) {
                        if (canSend) {
                          widget.onSend();
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'Ask about properties...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Color(0xFFA1887F)),
                      ),
                      style: const TextStyle(color: Color(0xFF5D4037)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: canSend ? widget.onSend : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: canSend
                            ? const Color(0xFF8B7355)
                            : const Color(0xFFD7CCC8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});
  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
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
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5ECD9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Text(
                  'Typing$_dots',
                  style: const TextStyle(
                    color: Color(0xFF5D4037),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
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
      backgroundColor: Colors.white,
      title: const Text(
        'Clear conversation?',
        style: TextStyle(color: Color(0xFF5D4037)),
      ),
      content: const Text(
        'This will delete all chat messages.',
        style: TextStyle(color: Color(0xFFA1887F)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF8B7355)),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B7355),
          ),
          child: const Text('Clear'),
        ),
      ],
    );
  }
}
