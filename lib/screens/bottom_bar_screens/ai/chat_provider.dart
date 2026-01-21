import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_service.dart';

enum Role { user, ai }

class ChatMessage {
  final String text;
  final Role role;
  final bool streaming;

  ChatMessage({required this.text, required this.role, this.streaming = false});

  Map<String, dynamic> toJson() => {'text': text, 'role': role.name};

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      role: Role.values.byName(json['role']),
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
  (ref) => ChatNotifier(),
);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]) {
    _loadHistory();
  }

  final _ai = AiService();

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('chat_history');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      state = list.map((e) => ChatMessage.fromJson(e)).toList();
    } else {
      _addWelcome();
    }
  }

  void _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'chat_history',
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
  }

  void _addWelcome() {
    state = [
      ChatMessage(
        role: Role.ai,
        text:
            "👋 Hi! I'm your AI assistant.\n\nTry asking:\n• Explain Flutter Riverpod\n• Write a login UI\n• Debug my error",
      ),
    ];
  }

  Future<void> send(String text) async {
    state = [
      ...state,
      ChatMessage(text: text, role: Role.user),
      ChatMessage(text: "", role: Role.ai, streaming: true),
    ];
    _save();

    final index = state.length - 1;
    String buffer = "";

    try {
      await for (final chunk in _ai.streamResponse(text)) {
        buffer += chunk;
        state = [
          ...state.sublist(0, index),
          ChatMessage(text: buffer, role: Role.ai, streaming: true),
        ];
      }

      state = [
        ...state.sublist(0, index),
        ChatMessage(text: buffer, role: Role.ai),
      ];
      _save();
    } catch (e) {
      state = [
        ...state.sublist(0, index),
        ChatMessage(
          text: "❌ Something went wrong.\nTap to retry.",
          role: Role.ai,
        ),
      ];
    }
  }

  void clearChat() async {
    state = [];
    _addWelcome();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('chat_history');
  }
}
