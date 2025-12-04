import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:real_beez/screens/api/cab_service.dart';
import 'package:real_beez/screens/homescreen/home_screen.dart';
import 'package:real_beez/screens/models/booking_model.dart';
import 'package:real_beez/utils/app_colors.dart';

void main() {
  runApp(const BookingApp());
} 

class BookingApp extends StatelessWidget {
  const BookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Booking Confirmation",
      debugShowCheckedModeBanner: false,
      home: const BookingConfirmationScreen(),
    );
  }
}

class BookingConfirmationScreen extends StatefulWidget {
  final String? bookingId;
  
  const BookingConfirmationScreen({
    super.key,
    this.bookingId,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends State<BookingConfirmationScreen> {
  bool _showRescheduleUI = false;
  bool _showCompletionDialog = false;
  String _completionType = "";
  BookingModel? _currentBooking;
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (widget.bookingId != null && widget.bookingId!.isNotEmpty) {
        _fetchSpecificBooking(widget.bookingId!);
      } else {
        _fetchBookings();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  Future<void> _fetchSpecificBooking(String bookingId) async {
    try {
      if (!mounted) return;
      
      setState(() {
      });
      final allBookings = await CabService.getCabBookings().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Booking fetch timeout');
        },
      );
      BookingModel? foundBooking;
      for (var bookingData in allBookings) {
        final booking = BookingModel.fromJson(bookingData);
        if (booking.id == bookingId || 
            bookingData["_id"] == bookingId ||
            bookingData["id"] == bookingId) {
          foundBooking = booking;
          break;
        }
      }

      if (!mounted) return;
      
      setState(() {
        if (foundBooking != null) {
          _currentBooking = foundBooking;
        } else {
          if (allBookings.isNotEmpty) {
            _currentBooking = BookingModel.fromJson(allBookings.first);
          }
        }
      });
      if (foundBooking == null && widget.bookingId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking ${widget.bookingId} not found. Showing latest booking.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load booking details: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _fetchBookings() async {
    try {
      if (!mounted) return;
      
      setState(() {
      });
      final response = await CabService.getCabBookings().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Booking fetch timeout');
        },
      );
      
      final List<BookingModel> bookings = response.map<BookingModel>((booking) {
        return BookingModel.fromJson(booking);
      }).toList();

      if (!mounted) return;
      
      setState(() {
        // If we have a specific booking ID but had to fall back to fetch all,
        // try to find it again
        if (widget.bookingId != null && bookings.isNotEmpty) {
          var found = bookings.firstWhere(
            (booking) => booking.id == widget.bookingId,
            orElse: () => bookings.first,
          );
          _currentBooking = found;
        } else if (bookings.isNotEmpty) {
          // Use the first booking as current booking for demo
          _currentBooking = bookings.firstWhere(
            (booking) => booking.status == 'booked',
            orElse: () => bookings.first,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load booking details: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showCompletionPopup(String type) {
    if (!mounted) return;
    
    debugPrint("Showing completion popup for type: $type");
    
    setState(() {
      _showCompletionDialog = true;
      _completionType = type;
    });
  }

  void _hideCompletionPopup() {
    if (!mounted) return;
    
    debugPrint("Hiding completion popup");
    
    setState(() {
      _showCompletionDialog = false;
      _completionType = "";
    });
  }

  // Extract coordinates from location string (basic implementation)
  LatLng _extractCoordinates(String location) {
    // This is a simple implementation - you might need more sophisticated parsing
    if (location.contains("Noida")) {
      return const LatLng(28.6292, 77.3747); // Noida coordinates
    } else if (location.contains("Delhi")) {
      return const LatLng(28.6139, 77.2090); // Delhi coordinates
    } else if (location.contains("Airport")) {
      return const LatLng(28.5562, 77.1000); // Airport coordinates
    } else {
      return const LatLng(40.6892, -74.0445); // Default coordinates
    }
  }

  String _formatDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        String period = hour >= 12 ? 'PM' : 'AM';
        if (hour > 12) hour -= 12;
        if (hour == 0) hour = 12;
        return '$hour:${parts[1]} $period';
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }
  
  Future<void> _handleCancelBooking(String bookingId, String reason) async {
    if (_isProcessing || !mounted) return;
    
    debugPrint("Starting cancellation for booking: $bookingId");
    debugPrint("Cancellation reason: $reason");
    
    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await CabService.cancelBooking(bookingId, reason);
      
      debugPrint("Cancellation API result: $result");
      
     if (result["success"] == true) {
  debugPrint("Cancellation successful, showing completion popup");
  _showCompletionPopup("cancel");
  // Don't fetch bookings here - let the dialog handle navigation
} else if (result["statusCode"] == 405 && 
           (result["message"]?.contains("successfully") ?? false)) {
  // Handle 405 status with success message as success
  debugPrint("Cancellation successful (405 status), showing completion popup");
  _showCompletionPopup("cancel");
} else {
  debugPrint("Cancellation failed: ${result["message"]}");
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(result["message"] ?? "Cancellation failed"),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    ),
  );
}
    } catch (e) {
      debugPrint("Error in cancellation: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling booking: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        debugPrint("Setting _isProcessing to false");
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

 Future<void> _handleRescheduleBooking(
  String bookingId, 
  String reason, 
  String newDate, 
  String newTime
) async {
  if (_isProcessing || !mounted) return;
  
  debugPrint("Starting reschedule for booking: $bookingId");
  debugPrint("Reschedule reason: $reason");
  debugPrint("New date: $newDate, New time: $newTime");
  
  setState(() {
    _isProcessing = true;
  });

  try {
    final result = await CabService.rescheduleBooking(
      bookingId, 
      reason, 
      newDate, 
      newTime
    );
    
    debugPrint("Reschedule API result: $result");
    
    if (result["success"] == true) {
      debugPrint("Reschedule successful, showing completion popup");
      _showCompletionPopup("reschedule");
      // Don't fetch bookings here
      if (mounted) {
        setState(() {
          _showRescheduleUI = false;
        });
      }
    } else if (result["statusCode"] == 405 && 
               (result["message"]?.contains("successfully") ?? false)) {
      // Handle 405 status with success message as success
      debugPrint("Reschedule successful (405 status), showing completion popup");
      _showCompletionPopup("reschedule");
      if (mounted) {
        setState(() {
          _showRescheduleUI = false;
        });
      }
    } else {
      debugPrint("Reschedule failed: ${result["message"]}");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ?? "Reschedule failed"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    debugPrint("Error in reschedule: $e");
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error rescheduling booking: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  } finally {
    if (mounted) {
      debugPrint("Setting _isProcessing to false for reschedule");
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

  // Build map fallback widget
  Widget _buildMapFallback(LatLng pickupCoords, LatLng dropCoords, BookingModel booking) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.32,
      width: double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(
            'Map Preview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentBooking == null) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No booking found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your booking details',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.beeYellow,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Go Back',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Only proceed if we have a booking
    final booking = _currentBooking!;
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = screenHeight * 0.32;
    final pickupCoords = _extractCoordinates(booking.pickupLocation);
    final dropCoords = _extractCoordinates(booking.dropLocation);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Google Map or Fallback - USE FALLBACK TO PREVENT INFINITE LOOP
                      SizedBox(
                        height: mapHeight,
                        width: double.infinity,
                        child: _buildMapFallback(pickupCoords, dropCoords, booking),
                      ),
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: _getStatusColor(booking.status),
                                  child: Icon(_getStatusIcon(booking.status),
                                      size: 14, color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getStatusText(booking.status),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: 12,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.black, size: 20),
                            onPressed: () {
                              if (_showRescheduleUI) {
                                setState(() => _showRescheduleUI = false);
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      Positioned(
                        top: mapHeight - 40,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(35),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.fromLTRB(0, 40, 16, 12),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _showRescheduleUI
                                                      ? "Reschedule Booking"
                                                      : "Trip Details",
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  booking.carModel,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.fromLTRB(
                                              16, 20, 16, 40),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(25),
                                            ),
                                          ),
                                          child: _showRescheduleUI
                                              ? RescheduleUI(
                                                  bookingId: booking.id,
                                                  onRescheduleComplete: (date, time) {
                                                    _handleRescheduleBooking(
                                                      booking.id,
                                                      "Customer requested reschedule",
                                                      date,
                                                      time,
                                                    );
                                                  },
                                                  isLoading: _isProcessing,
                                                )
                                              : _bookingDetailsUI(context, booking),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 30,
                                right: 20,
                                child: Transform.rotate(
                                  angle: 0,
                                  child: Image.asset(
                                    _getCarImage(booking.vehicleType),
                                    height: 90,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Simple Completion Dialog Overlay - FIXED POSITIONING
          if (_showCompletionDialog && !_isProcessing)
            Positioned.fill(
              child: _SimpleCompletionDialog(
                type: _completionType,
                onClose: _hideCompletionPopup,
                bookingId: _currentBooking?.id ?? '',
              ),
            ),

          // Loading overlay for API calls
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.beeYellow),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper methods for status and images
  Color _getStatusColor(String status) {
    switch (status) {
      case 'booked':
        return Colors.green;
      case 'rescheduled':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'booked':
        return Icons.check;
      case 'rescheduled':
        return Icons.schedule;
      case 'cancelled':
        return Icons.close;
      default:
        return Icons.check;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'booked':
        return "Booking Confirmed";
      case 'rescheduled':
        return "Booking Rescheduled";
      case 'cancelled':
        return "Booking Cancelled";
      default:
        return "Booking Confirmed";
    }
  }

  String _getCarImage(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'suv':
        return "assets/images/innova.png";
      case 'sedan':
        return "assets/images/sedan.png";
      default:
        return "assets/images/car.png";
    }
  }

  Widget _bookingDetailsUI(BuildContext context, BookingModel booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
         "Booking ID: ${booking.id}",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        LocationBuildingTile(
          icon: Icons.location_on,
          iconColor: AppColors.beeYellow,
          label: booking.pickupLocation,
        ),
        const SizedBox(height: 10),
        LocationBuildingTile(
          icon: Icons.apartment,
          iconColor: const Color(0xFFABABAB),
          label: booking.dropLocation,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _infoTile(
              icon: Icons.group, 
              label: "Members", 
              value: "${booking.passengerCount}"
            ),
            _infoTile(
              icon: Icons.calendar_today,
              label: _formatDate(booking.bookingDate),
              value: _formatTime(booking.bookingTime),
            ),
            _infoTile(icon: Icons.headset_mic, label: "Support"),
          ],
        ),
        const SizedBox(height: 80),
        
        // Action Buttons
        Row(
          children: [
            // Cancel Button - White background with black text
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // White background
                  foregroundColor: Colors.black, // Black text color
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.beeYellow),
                  ),
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => CancelBookingPopup(
                      bookingId: booking.id,
                      onCancelBooking: (reason) {
                        _handleCancelBooking(booking.id, reason);
                      },
                    ),
                  );
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Reschedule Button - Yellow background with white text
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.beeYellow,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.2),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => ReschedulePopup(
                      onRescheduleNow: () {
                        Navigator.of(context).pop();
                        setState(() => _showRescheduleUI = true);
                      },
                    ),
                  );
                },
                child: const Text(
                  "Reschedule Booking",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ---------------- Info Tile Helper ----------------
  static Widget _infoTile(
      {required IconData icon, required String label, String? value}) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: AppColors.textDark),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          if (value != null) ...[
            const SizedBox(height: 2),
            Text(
              value,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ]
        ],
      ),
    );
  }
}

class _SimpleCompletionDialog extends StatefulWidget {
  final String type;
  final VoidCallback onClose;
  final String bookingId;
  
  const _SimpleCompletionDialog({
    required this.type,
    required this.onClose,
    required this.bookingId,
  });

  @override
  State<_SimpleCompletionDialog> createState() => _SimpleCompletionDialogState();
}

class _SimpleCompletionDialogState extends State<_SimpleCompletionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isRedirecting = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation
    _controller.forward();

    // Auto-redirect after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || _isRedirecting) return;
      _redirectToHome();
    });
  }

  void _redirectToHome() {
    if (_isRedirecting) return;
    
    _isRedirecting = true;
    
    // First close the dialog
    widget.onClose();
    
    // Then navigate after a small delay to ensure dialog is closed
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred Background
        BackdropFilter(
          filter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        // Center Content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.type == "reschedule" 
                      ? "Reschedule Completed!"
                      : "Cancellation Completed!",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  widget.type == "reschedule" 
                      ? "assets/icons/reschedule.png"
                      : "assets/icons/cancelled.png",
                  width: 50, 
                  height: 50, 
                ),
              ),
              const SizedBox(height: 10),
              if (_isRedirecting)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class LocationBuildingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const LocationBuildingTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x8CE8E8E8),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF444444),
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
    }
  }


class CancelBookingPopup extends StatefulWidget {
  final String bookingId;
  final Function(String) onCancelBooking;
  
  const CancelBookingPopup({
    super.key, 
    required this.bookingId,
    required this.onCancelBooking,
  });

  @override
  State<CancelBookingPopup> createState() => _CancelBookingPopupState();
}

class _CancelBookingPopupState extends State<CancelBookingPopup> {
  String? _selectedReason;

  final List<String> _reasons = [
    "Emergency for other",
    "Something urgent came up",
    "Due to [reason], I need to move outside",
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  const Text(
                    "Cancel Booking",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child:
                        const Icon(Icons.close, size: 20, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Cancellation Reason Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Reason for Cancellation",
                  style: TextStyle(
                    color: AppColors.beeYellow,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Column(
                children: _reasons.map((reason) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: reason,
                          groupValue: _selectedReason,
                          activeColor: AppColors.beeYellow,
                          onChanged: (value) {
                            setState(() {
                              _selectedReason = value;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            reason,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              
              // Cancel Booking Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  onPressed: _selectedReason != null ? () {
                    Navigator.of(context).pop();
                    widget.onCancelBooking(_selectedReason!);
                  } : null,
                  child: const Text(
                    "Cancel Booking",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReschedulePopup extends StatefulWidget {
  final VoidCallback onRescheduleNow;
  
  const ReschedulePopup({
    super.key, 
    required this.onRescheduleNow,
  });

  @override
  State<ReschedulePopup> createState() => _ReschedulePopupState();
}

class _ReschedulePopupState extends State<ReschedulePopup> {
  String? _selectedReason;

  final List<String> _reasons = [
    "Emergency for other",
    "Something urgent came up",
    "Due to [reason], I need to move outside",
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  const Text(
                    "Reschedule Booking",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child:
                        const Icon(Icons.close, size: 20, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Rescheduling Reason Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Reason for Rescheduling",
                  style: TextStyle(
                    color: AppColors.beeYellow,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Column(
                children: _reasons.map((reason) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: reason,
                          groupValue: _selectedReason,
                          activeColor: AppColors.beeYellow,
                          onChanged: (value) {
                            setState(() {
                              _selectedReason = value;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            reason,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              
              // Reschedule Now Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.beeYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  onPressed: _selectedReason != null ? widget.onRescheduleNow : null,
                  child: const Text(
                    "Reschedule Now",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RescheduleUI extends StatefulWidget {
  final String bookingId;
  final Function(String, String) onRescheduleComplete;
  final bool isLoading;
  
  const RescheduleUI({
    super.key, 
    required this.bookingId,
    required this.onRescheduleComplete,
    this.isLoading = false,
  });

  @override
  State<RescheduleUI> createState() => _RescheduleUIState();
}

class _RescheduleUIState extends State<RescheduleUI> {
  int _selectedDate = 8; // Default selected date
  final String _selectedMonth = "Oct";
  final int _selectedYear = 2025;
  String? _selectedTimeSlot;

  bool _isDateDisabled(int day) {
    return day < 8; // Disable past dates
  }

  final List<String> timeSlots = [
    "09:00 AM",
    "11:00 AM",
    "01:00 PM",
    "03:00 PM",
    "05:00 PM",
    "07:00 PM"
  ];

  void _showMonthYearPicker() {
    // Implement your month/year picker here
  }

  List<Widget> _getAvailableTimeSlots() {
    return timeSlots.map((slot) {
      bool isSelected = slot == _selectedTimeSlot;
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedTimeSlot = slot;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.beeYellow : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isSelected ? AppColors.beeYellow : Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Text(
                slot,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.check_circle, size: 14, color: Colors.white),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Date:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _showMonthYearPicker,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$_selectedMonth, $_selectedYear",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Horizontal Scrollable Dates
              SizedBox(
                height: 70,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List.generate(31, (index) {
                    int dayNumber = index + 1;
                    List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    String dayName = days[dayNumber % 7];
                    bool isSelected = dayNumber == _selectedDate;
                    bool isDisabled = _isDateDisabled(dayNumber);

                    return GestureDetector(
                      onTap: isDisabled
                          ? null
                          : () {
                              setState(() {
                                _selectedDate = dayNumber;
                                _selectedTimeSlot = null;
                              });
                            },
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isDisabled
                              ? Colors.grey[200]
                              : (isSelected ? AppColors.beeYellow : Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDisabled
                                ? Colors.grey[300]!
                                : (isSelected ? AppColors.beeYellow : Colors.grey[300]!),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isDisabled
                                    ? Colors.grey[400]
                                    : (isSelected ? Colors.black : Colors.grey[700]),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$dayNumber',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isDisabled
                                    ? Colors.grey[400]
                                    : (isSelected ? Colors.black : Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 25),

              // Schedule Time
              const Text(
                "Select Schedule Time:",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _getAvailableTimeSlots(),
              ),

              // Selected Time Display
              if (_selectedTimeSlot != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.beeYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.beeYellow),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time,
                          color: AppColors.beeYellow, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "Selected Time: $_selectedTimeSlot",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),
              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.beeYellow,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (_selectedTimeSlot != null && !widget.isLoading)
                      ? () {
                          // Format date for API (YYYY-MM-DD)
                          String formattedDate = "$_selectedYear-${_getMonthNumber(_selectedMonth)}-${_selectedDate.toString().padLeft(2, '0')}";
                          // Format time for API (HH:MM)
                          String formattedTime = _formatTimeForAPI(_selectedTimeSlot!);
                          
                          widget.onRescheduleComplete(formattedDate, formattedTime);
                        }
                      : null,
                  child: widget.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _selectedTimeSlot != null
                              ? "Reschedule for $_selectedTimeSlot"
                              : "Select Time to Reschedule",
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),

        // Loading overlay
        if (widget.isLoading)
          Container(
            color: Colors.black.withOpacity(0.1),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.beeYellow),
              ),
            ),
          ),
      ],
    );
  }

  String _getMonthNumber(String month) {
    final months = {
      'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
      'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
      'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
    };
    return months[month] ?? '10';
  }

  String _formatTimeForAPI(String timeSlot) {
    try {
      final parts = timeSlot.split(' ');
      return parts[0];
    } catch (e) {
      return timeSlot;
    }
  }
}