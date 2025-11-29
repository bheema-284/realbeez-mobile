import 'dart:convert';
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
        return data; // Returns the list of cab bookings
      } else {
        throw Exception('Failed to load cab bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cab bookings: $e');
    }
  }

  static Future<Map<String, dynamic>> rescheduleBooking(
    String bookingId,
    String reason,
    String newDate,
    String newTime,
  ) async {
    try {
      print('Rescheduling booking: $bookingId, $newDate, $newTime, $reason');
      
      final response = await http.put(
        Uri.parse("$baseUrl/cab_services/$bookingId/reschedule"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "reason": reason,
          "new_booking_date": newDate,
          "new_booking_time": newTime,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Handle empty response
      if (response.body.isEmpty) {
        return {
          "success": true,
          "message": "Booking rescheduled successfully",
        };
      }

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Booking rescheduled successfully",
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Reschedule failed",
      };
    } catch (e) {
      print('Error in rescheduleBooking: $e');
      return {
        "success": false,
        "message": "Network error: $e",
      };
    }
  }

  static Future<Map<String, dynamic>> cancelBooking(
    String bookingId,
    String reason,
  ) async {
    try {
      print('Cancelling booking: $bookingId, $reason');
      
      final response = await http.put(
        Uri.parse("$baseUrl/cab_services/$bookingId/cancel"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "reason": reason,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Handle empty response
      if (response.body.isEmpty) {
        return {
          "success": true,
          "message": "Booking cancelled successfully",
        };
      }

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Booking cancelled successfully",
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Cancellation failed",
      };
    } catch (e) {
      print('Error in cancelBooking: $e');
      return {
        "success": false,
        "message": "Network error: $e",
      };
    }
  }
}