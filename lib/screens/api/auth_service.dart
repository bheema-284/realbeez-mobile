import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "https://realbeez-backend.vercel.app/api";

  static Future<Map<String, dynamic>> login(String mobileOrAadhaar) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mobile": mobileOrAadhaar,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        return {
          "success": true,
          "message": data["message"],
          "userId": data["userId"],
          "accessToken": data["accessToken"],
          "refreshToken": data["refreshToken"],
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Login failed",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }
}
