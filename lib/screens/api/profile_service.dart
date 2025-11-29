import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {
  static const String baseUrl = "https://realbeez-backend.vercel.app/api";

  static Future<List<dynamic>> getProfiles() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/profile"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to load profiles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching profiles: $e');
    }
  }

  static Future<Map<String, dynamic>> updateProfile(
    String profileId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      print('Updating profile: $profileId with data: $profileData');
      
      final response = await http.put(
        Uri.parse("$baseUrl/profile/$profileId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(profileData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Handle empty response
      if (response.body.isEmpty) {
        return {
          "success": true,
          "message": "Profile updated successfully",
        };
      }

      // Try to parse response
      try {
        final data = jsonDecode(response.body);
        
        if (response.statusCode == 200) {
          return {
            "success": true,
            "message": data["message"] ?? "Profile updated successfully",
            "profile": data,
          };
        } else {
          return {
            "success": false,
            "message": data["message"] ?? "Profile update failed",
          };
        }
      } catch (parseError) {
        // If JSON parsing fails but status is 200, consider it success
        if (response.statusCode == 200) {
          return {
            "success": true,
            "message": "Profile updated successfully",
          };
        } else {
          return {
            "success": false,
            "message": "Server error: ${response.statusCode}",
          };
        }
      }
    } catch (e) {
      print('Error in updateProfile: $e');
      return {
        "success": false,
        "message": "Network error: $e",
      };
    }
  }

  // Alternative method to create profile if update doesn't work
  static Future<Map<String, dynamic>> createProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/profile"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(profileData),
      );

      print('Create profile response: ${response.statusCode}');
      print('Create profile body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": "Profile created successfully",
        };
      } else {
        return {
          "success": false,
          "message": "Failed to create profile",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error creating profile: $e",
      };
    }
  }
}