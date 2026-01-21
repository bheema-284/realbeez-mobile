import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String apiUrl =
      'https://realestatejobs-delta.vercel.app/api/chats';

  /// Streams response character-by-character
  Stream<String> streamResponse(String prompt) async* {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'messages': prompt}),
    );

    if (response.statusCode != 200) {
      throw Exception('API failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);

    /// 🔴 CHANGE THIS KEY if your API uses a different name
    final fullText = data['reply'] as String;

    // Fake streaming effect (like ChatGPT)
    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 25));
      yield fullText[i];
    }
  }
}
