import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ChatDemoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatDemoPage extends StatefulWidget {
  const ChatDemoPage({super.key});

  @override
  State<ChatDemoPage> createState() => _ChatDemoPageState();
}

class _ChatDemoPageState extends State<ChatDemoPage> {
  bool _showChat = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat Demo'),
        backgroundColor: Colors.lime.shade600,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            // Main content area
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Candidate Information Page',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.shade100,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'John Doe',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Senior Software Engineer',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showChat = true;
                                  });
                                },
                                icon: const Icon(Icons.chat),
                                label: const Text('Open Chat'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lime.shade600,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 20),
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showChat = false;
                                  });
                                },
                                icon: const Icon(Icons.close),
                                label: const Text('Close Chat'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chat overlay - only show if _showChat is true
            if (_showChat)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Chat(
                      candidateName: 'John Doe',
                      onClose: () {
                        setState(() {
                          _showChat = false;
                        });
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Chat extends StatefulWidget {
  final String? candidateName;
  final VoidCallback onClose;

  const Chat({Key? key, this.candidateName, required this.onClose})
    : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  bool _loading = false;
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    // Prepare messages for API
    final List<Map<String, String>> apiMessages = [];

    // Add conversation history
    for (var message in _messages) {
      final role = message['sender'] == 'user' ? 'user' : 'assistant';
      apiMessages.add({'role': role, 'content': message['text'] ?? ''});
    }

    // Add current message
    apiMessages.add({'role': 'user', 'content': input});

    setState(() {
      _messages.add({'sender': 'user', 'text': input});
      _inputController.clear();
      _loading = true;
    });

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      // Solution 1: Direct API call with proper headers
      final apiUrl = 'https://realestatejobs-delta.vercel.app/api/chats';

      print('Calling API: $apiUrl');
      print('Request body: ${json.encode({'messages': apiMessages})}');

      final res = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'messages': apiMessages}),
          )
          .timeout(const Duration(seconds: 30));

      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        // Try to extract response from different possible structures
        String responseText = 'No response received';

        if (data is Map) {
          if (data.containsKey('response')) {
            responseText = data['response'].toString();
          } else if (data.containsKey('message')) {
            responseText = data['message'].toString();
          } else if (data.containsKey('content')) {
            responseText = data['content'].toString();
          } else if (data.containsKey('choices') &&
              data['choices'] is List &&
              data['choices'].isNotEmpty &&
              data['choices'][0] is Map &&
              data['choices'][0]['message'] is Map) {
            responseText = data['choices'][0]['message']['content'].toString();
          } else if (data.containsKey('text')) {
            responseText = data['text'].toString();
          } else if (data.containsKey('answer')) {
            responseText = data['answer'].toString();
          } else {
            // If we can't find a standard field, try to use the entire response
            responseText = 'AI Response: ${data.toString()}';
          }
        } else if (data is String) {
          responseText = data;
        }

        setState(() {
          _messages.add({'sender': 'ai', 'text': responseText});
        });
      } else {
        // Server returned an error
        final errorMessage = 'Server error ${res.statusCode}: ${res.body}';
        _showError(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (err) {
      debugPrint('Error: $err');

      // Check if it's a CORS error
      final errorStr = err.toString();
      if (errorStr.contains('CORS') ||
          errorStr.contains('Origin') ||
          errorStr.contains('Failed to fetch')) {
        // It's a CORS error - we need to fix this on the backend
        _showError(
          'CORS Error: Your backend needs to allow requests from this origin.\n'
          'Add these headers to your /api/chats endpoint:\n'
          'Access-Control-Allow-Origin: *\n'
          'Access-Control-Allow-Methods: POST, OPTIONS\n'
          'Access-Control-Allow-Headers: Content-Type',
        );
      } else {
        _showError('Error: $err');
      }

      // Remove the loading state
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } finally {
      // Auto-scroll to bottom after response
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
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );

      // Also show error in chat
      setState(() {
        _messages.add({
          'sender': 'ai',
          'text':
              'Error connecting to AI service: ${message.split('\n').first}',
        });
      });
    }
  }

  void _sendMessageOnEnter() {
    if (!_loading) {
      _sendMessage();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.lime.shade600,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Chat with AI about ${widget.candidateName ?? 'Candidate'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.lime.shade700,
                      padding: const EdgeInsets.all(4),
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
            ),

            // Messages area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final sender = message['sender'];
                    final text = message['text'];
                    final isUser = sender == 'user';

                    if (text == null || text.isEmpty)
                      return const SizedBox.shrink();

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: screenWidth * 0.6,
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.blue.shade100
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUser ? 'You:' : 'AI:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isUser
                                    ? Colors.blue.shade800
                                    : Colors.grey.shade800,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              text,
                              style: TextStyle(
                                color: isUser
                                    ? Colors.blue.shade800
                                    : Colors.grey.shade800,
                                fontSize: 14,
                              ),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Input area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: 'Ask a question...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      enabled: !_loading,
                      onSubmitted: (_) => _sendMessageOnEnter(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _loading ? null : _sendMessage,
                    icon: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: Colors.green.shade600
                          .withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
