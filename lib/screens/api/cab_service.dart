import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CabService {
  static const String baseUrl = "https://realbeez-backend.vercel.app/api";

  static Future<List<dynamic>> getCabBookings() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/cab_services"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("GET Response: $data");
        return data; // Returns the list of cab bookings
      } else {
        throw Exception('Failed to load cab bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cab bookings: $e');
    }
  }

  static Future<Map<String, dynamic>> postCabBooking({
    required String bookingId,
    required int passengerCount,
    required String bookingDate,
    required String bookingTime,
    required String pickupLocation,
    required String dropLocation,
  }) async {
    try {
      // Create request body matching backend format
      Map<String, dynamic> requestBody = {
        "passenger_count": passengerCount,
        "booking_date": bookingDate,
        "booking_time": bookingTime,
        "pickup_location": pickupLocation,
        "drop_location": dropLocation,
        "status": "booked",
      };

      // Log request for debugging
      debugPrint("POST Request URL: $baseUrl/cab_services");
      debugPrint("POST Request Body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse("$baseUrl/cab_services"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      // Log response details
      debugPrint("POST Status Code: ${response.statusCode}");
      debugPrint("POST Response Body: ${response.body}");

      // Handle empty response
      if (response.body.isEmpty) {
        return {
          "success": response.statusCode == 200 || response.statusCode == 201,
          "message": response.statusCode == 201
              ? "Booking created successfully"
              : "Empty response with status ${response.statusCode}",
          "data": {"_id": bookingId}, // Return the generated ID
          "statusCode": response.statusCode,
        };
      }

      // Parse response
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Ensure the response contains an ID
        Map<String, dynamic> responseData = {...data};
        if (data["_id"] == null && data["id"] == null) {
          responseData["_id"] = bookingId; // Add generated ID if not present
        }
        
        return {
          "success": true,
          "message": data["message"] ?? "Booking created successfully",
          "data": responseData, // Include the full response with ID
          "statusCode": response.statusCode,
        };
      } else {
        // Handle error response
        return {
          "success": false,
          "message":
              data["message"] ??
              data["error"] ??
              "Failed to create booking. Status: ${response.statusCode}",
          "statusCode": response.statusCode,
          "error": data,
        };
      }
    } catch (e) {
      debugPrint("Exception in postCabBooking: $e");
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> rescheduleBooking(
    String bookingId,
    String reason,
    String newDate,
    String newTime,
  ) async {
    try {
      // First try PATCH method
      final response = await http.patch(
        Uri.parse("$baseUrl/cab_services/$bookingId/reschedule"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "reason": reason,
          "new_booking_date": newDate,
          "new_booking_time": newTime,
        }),
      );

      debugPrint("Reschedule Status (PATCH): ${response.statusCode}");
      debugPrint("Reschedule Body (PATCH): ${response.body}");

      // If PATCH fails with 405, try POST
      if (response.statusCode == 405 || response.statusCode == 404) {
        debugPrint("PATCH failed for reschedule, trying POST method...");
        return await _rescheduleBookingWithPost(bookingId, reason, newDate, newTime);
      }

      if (response.body.isEmpty) {
        return {
          "success": response.statusCode == 200 || response.statusCode == 204,
          "message": "Booking rescheduled successfully",
          "statusCode": response.statusCode,
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          "success": true,
          "message": data["message"] ?? "Booking rescheduled successfully",
          "data": data,
          "statusCode": response.statusCode,
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Reschedule failed",
        "statusCode": response.statusCode,
        "error": data,
      };
    } catch (e) {
      debugPrint("Exception in rescheduleBooking (PATCH): $e");
      // If PATCH fails with exception, try POST
      return await _rescheduleBookingWithPost(bookingId, reason, newDate, newTime);
    }
  }

  // Helper method to try reschedule with POST method
  static Future<Map<String, dynamic>> _rescheduleBookingWithPost(
    String bookingId,
    String reason,
    String newDate,
    String newTime,
  ) async {
    try {
      debugPrint("Trying POST method for reschedule...");
      final response = await http.post(
        Uri.parse("$baseUrl/cab_services/$bookingId/reschedule"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "reason": reason,
          "new_booking_date": newDate,
          "new_booking_time": newTime,
        }),
      );

      debugPrint("Reschedule Status (POST): ${response.statusCode}");
      debugPrint("Reschedule Body (POST): ${response.body}");

      if (response.body.isEmpty) {
        return {
          "success": response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204,
          "message": "Booking rescheduled successfully",
          "statusCode": response.statusCode,
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return {
          "success": true,
          "message": data["message"] ?? "Booking rescheduled successfully",
          "data": data,
          "statusCode": response.statusCode,
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Reschedule failed",
        "statusCode": response.statusCode,
        "error": data,
      };
    } catch (e) {
      debugPrint("Exception in _rescheduleBookingWithPost: $e");
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> cancelBooking(
    String bookingId,
    String reason,
  ) async {
    try {
      // First try PATCH method (common for updates)
      final response = await http.patch(
        Uri.parse("$baseUrl/cab_services/$bookingId/cancel"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"reason": reason}),
      );

      debugPrint("Cancel Status (PATCH): ${response.statusCode}");
      debugPrint("Cancel Body (PATCH): ${response.body}");

      // If PATCH fails, try POST
      if (response.statusCode == 405 || response.statusCode == 404) {
        debugPrint("PATCH failed, trying POST method...");
        return await _cancelBookingWithPost(bookingId, reason);
      }

      if (response.body.isEmpty) {
        return {
          "success": response.statusCode == 200 || response.statusCode == 204,
          "message": "Booking cancelled successfully",
          "statusCode": response.statusCode,
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          "success": true,
          "message": data["message"] ?? "Booking cancelled successfully",
          "data": data,
          "statusCode": response.statusCode,
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Cancellation failed",
        "statusCode": response.statusCode,
        "error": data,
      };
    } catch (e) {
      debugPrint("Exception in cancelBooking (PATCH): $e");
      // If PATCH fails with exception, try POST
      return await _cancelBookingWithPost(bookingId, reason);
    }
  }

  // Helper method to try cancellation with POST method
  static Future<Map<String, dynamic>> _cancelBookingWithPost(
    String bookingId,
    String reason,
  ) async {
    try {
      debugPrint("Trying POST method for cancellation...");
      final response = await http.post(
        Uri.parse("$baseUrl/cab_services/$bookingId/cancel"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"reason": reason}),
      );

      debugPrint("Cancel Status (POST): ${response.statusCode}");
      debugPrint("Cancel Body (POST): ${response.body}");

      if (response.body.isEmpty) {
        return {
          "success": response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204,
          "message": "Booking cancelled successfully",
          "statusCode": response.statusCode,
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return {
          "success": true,
          "message": data["message"] ?? "Booking cancelled successfully",
          "data": data,
          "statusCode": response.statusCode,
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Cancellation failed",
        "statusCode": response.statusCode,
        "error": data,
      };
    } catch (e) {
      debugPrint("Exception in _cancelBookingWithPost: $e");
      return {"success": false, "message": "Network error: $e"};
    }
  }
}