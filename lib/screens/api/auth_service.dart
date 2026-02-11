import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "https://realbeez-backend.vercel.app/api";

  static Future<Map<String, dynamic>> login(String mobile) async {
    try {
      print("=== LOGIN API CALL ===");
      print("Mobile: $mobile");

      final response = await http.post(
        Uri.parse("$baseUrl/auth"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"action": "check-user", "email": mobile}),
      );

      final data = jsonDecode(response.body);

      print("=== LOGIN API RESPONSE ===");
      print("Status Code: ${response.statusCode}");
      print("Full response: $data");
      print("Success: ${data["success"]}");
      print("Has userId: ${data["userId"] != null}");
      print("========================");

      if (response.statusCode == 200 && data["success"] == true) {
        // User exists if we have a userId
        bool userExists =
            data["userId"] != null &&
            data["userId"].toString().isNotEmpty &&
            data["userId"].toString() != "null";

        print("User exists calculated: $userExists");

        return {
          "success": true,
          "exists": userExists,
          "message": data["message"] ?? "Login successful",
          "userId": data["userId"],
          "accessToken": data["accessToken"],
          "refreshToken": data["refreshToken"],
        };
      } else {
        return {
          "success": false,
          "exists": false,
          "message": data["message"] ?? "Login failed",
        };
      }
    } catch (e) {
      print("Login API Error: $e");
      return {
        "success": false,
        "exists": false,
        "message": "Network error: $e",
      };
    }
  }

  static Future<Map<String, dynamic>> loginWithEmail(String email) async {
    try {
      print("=== EMAIL LOGIN API CALL ===");
      print("Email: $email");

      final response = await http.post(
        Uri.parse("$baseUrl/auth"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"action": "check-user", "email": email}),
      );

      final data = jsonDecode(response.body);

      print("=== EMAIL LOGIN API RESPONSE ===");
      print("Status Code: ${response.statusCode}");
      print("Full response: $data");
      print("Success: ${data["success"]}");
      print("Has userId: ${data["userId"] != null}");
      print("===============================");

      if (response.statusCode == 200 && data["success"] == true) {
        // User exists if we have a userId
        bool userExists = data["exists"] == true;
        print("User exists calculated: $userExists");

        return {
          "success": true,
          "exists": userExists,
          "message": data["message"] ?? "Email login successful",
          "userId": data["userId"],
          "accessToken": data["accessToken"],
          "refreshToken": data["refreshToken"],
        };
      } else {
        return {
          "success": false,
          "exists": false,
          "message": data["message"] ?? "Email login failed",
        };
      }
    } catch (e) {
      print("Email Login API Error: $e");
      return {
        "success": false,
        "exists": false,
        "message": "Network error: $e",
      };
    }
  }

  static Future<Map<String, dynamic>> checkEmailOtp(String email) async {
    try {
      print("=== EMAIL LOGIN API CALL ===");
      print("Email: $email");

      final response = await http.post(
        Uri.parse("$baseUrl/auth"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"action": "send-email-otp", "email": email}),
      );

      final data = jsonDecode(response.body);

      print("=== EMAIL LOGIN API RESPONSE ===");
      print("Status Code: ${response.statusCode}");
      print("Full response: $data");
      print("Success: ${data["success"]}");
      print("Has userId: ${data["userId"] != null}");
      print("===============================");

      if (response.statusCode == 200 && data["success"] == true) {
        // User exists if we have a userId
        bool userExists = data["exists"] == true;
        print("User exists calculated: $userExists");

        return {
          "success": true,
          "exists": userExists,
          "message": data["message"] ?? "Email login successful",
          "userId": data["userId"],
          "accessToken": data["accessToken"],
          "refreshToken": data["refreshToken"],
        };
      } else {
        return {
          "success": false,
          "exists": false,
          "message": data["message"] ?? "Email login failed",
        };
      }
    } catch (e) {
      print("Email Login API Error: $e");
      return {
        "success": false,
        "exists": false,
        "message": "Network error: $e",
      };
    }
  }

  static Future<Map<String, dynamic>> checkPhoneOtp(String userData) async {
    try {
      print("=== REGISTER USER API CALL ===");
      print("User Data: $userData");

      final response = await http.post(
        Uri.parse("$baseUrl/auth"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"action": "register", "userData": userData}),
      );

      final data = jsonDecode(response.body);

      print("=== REGISTER USER API RESPONSE ===");
      print("Status Code: ${response.statusCode}");
      print("Full response: $data");
      print("Success: ${data["success"]}");
      print("Has userId: ${data["userId"] != null}");
      print("===============================");

      if (response.statusCode == 200 && data["success"] == true) {
        // User exists if we have a userId
        bool userExists = data["exists"] == true;
        print("User exists calculated: $userExists");

        return {
          "success": true,
          "exists": userExists,
          "message": data["message"] ?? "Email login successful",
          "userId": data["userId"],
          "accessToken": data["accessToken"],
          "refreshToken": data["refreshToken"],
        };
      } else {
        return {
          "success": false,
          "exists": false,
          "message": data["message"] ?? "Email login failed",
        };
      }
    } catch (e) {
      print("Email Login API Error: $e");
      return {
        "success": false,
        "exists": false,
        "message": "Network error: $e",
      };
    }
  }

  static Future<Map<String, dynamic>> registerUser(String userData) async {
    try {
      print("=== REGISTER USER API CALL ===");
      print("User Data: $userData");

      final response = await http.post(
        Uri.parse("$baseUrl/auth"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"action": "register", "userData": userData}),
      );

      final data = jsonDecode(response.body);

      print("=== REGISTER USER API RESPONSE ===");
      print("Status Code: ${response.statusCode}");
      print("Full response: $data");
      print("Success: ${data["success"]}");
      print("Has userId: ${data["userId"] != null}");
      print("===============================");

      if (response.statusCode == 200 && data["success"] == true) {
        // User exists if we have a userId
        bool userExists = data["exists"] == true;
        print("User exists calculated: $userExists");

        return {
          "success": true,
          "exists": userExists,
          "message": data["message"] ?? "Email login successful",
          "userId": data["userId"],
          "accessToken": data["accessToken"],
          "refreshToken": data["refreshToken"],
        };
      } else {
        return {
          "success": false,
          "exists": false,
          "message": data["message"] ?? "Email login failed",
        };
      }
    } catch (e) {
      print("Email Login API Error: $e");
      return {
        "success": false,
        "exists": false,
        "message": "Network error: $e",
      };
    }
  }
}
