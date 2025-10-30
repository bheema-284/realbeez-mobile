import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:real_beez/screens/homescreen/home_screen.dart';
import 'package:real_beez/utils/app_colors.dart';

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
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(40.6892, -74.0445),
    zoom: 14.0,
  );

  bool _showRescheduleUI = false;
  bool _showCompletionDialog = false;
  String _completionType = ""; // "reschedule" or "cancel"

  void _showCompletionPopup(String type) {
    setState(() {
      _showCompletionDialog = true;
      _completionType = type;
    });
  }

  void _hideCompletionPopup() {
    setState(() {
      _showCompletionDialog = false;
      _completionType = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = screenHeight * 0.32;

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
                      // Google Map
                      SizedBox(
                        height: mapHeight,
                        width: double.infinity,
                        child: GoogleMap(
                          initialCameraPosition: _initialPosition,
                          mapType: MapType.normal,
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          markers: {
                            Marker(
                              markerId: const MarkerId('pickup'),
                              position: const LatLng(40.6892, -74.0445),
                              infoWindow: const InfoWindow(title: 'Liberty'),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueOrange,
                              ),
                            ),
                            Marker(
                              markerId: const MarkerId('destination'),
                              position: const LatLng(40.6895, -74.0448),
                              infoWindow: const InfoWindow(
                                title: 'SMR Buildings',
                              ),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueBlue,
                              ),
                            ),
                          },
                          polylines: {
                            Polyline(
                              polylineId: const PolylineId('route'),
                              color: Colors.blue,
                              width: 4,
                              points: const [
                                LatLng(40.6892, -74.0445),
                                LatLng(40.6895, -74.0448),
                              ],
                            ),
                          },
                        ),
                      ),

                      // ✅ Booking Confirmed Label
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.green,
                                  child: Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Booking Confirmed",
                                  style: TextStyle(
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

                      // 🔙 Back button
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
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: 20,
                            ),
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

                      // 🔹 Main Card Section
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            0,
                                            40,
                                            16,
                                            12,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 16,
                                            ),
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
                                                const Text(
                                                  "Innova Crysta",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // 🔸 Inner White Section (switch between UIs)
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.fromLTRB(
                                            16,
                                            20,
                                            16,
                                            40,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(25),
                                            ),
                                          ),
                                          child: _showRescheduleUI
                                              ? RescheduleUI(
                                                  onRescheduleComplete:
                                                      (date, time) {
                                                        _showCompletionPopup(
                                                          "reschedule",
                                                        );
                                                      },
                                                )
                                              : _bookingDetailsUI(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // 🔹 Car Image Floating (always visible)
                              Positioned(
                                top: 30,
                                right: 20,
                                child: Transform.rotate(
                                  angle: -0.1,
                                  child: Image.asset(
                                    "assets/images/car.png",
                                    height: 120,
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

          // Simple Completion Dialog Overlay
          if (_showCompletionDialog)
            _SimpleCompletionDialog(
              type: _completionType,
              onClose: _hideCompletionPopup,
            ),
        ],
      ),
    );
  }

  /// ---------------- Booking Details UI ----------------
  Widget _bookingDetailsUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Booking ID: QWE123456567",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        const LocationBuildingTile(
          icon: Icons.location_on,
          iconColor: AppColors.beeYellow,
          label: "Liberty (40.6892° N, 74.0445° W)",
        ),
        const SizedBox(height: 10),
        const LocationBuildingTile(
          icon: Icons.apartment,
          iconColor: Color(0xFFABABAB),
          label: "SMR Buildings",
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _infoTile(icon: Icons.group, label: "Members", value: "6"),
            _infoTile(
              icon: Icons.calendar_today,
              label: "25/09/2025",
              value: "9:00 AM",
            ),
            _infoTile(icon: Icons.headset_mic, label: "Support"),
          ],
        ),
        const SizedBox(height: 80),

        // Separated Cancel and Reschedule Buttons
        Row(
          children: [
            // Cancel Button - White background with black text
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // White background
                  foregroundColor: Colors.black, // Black text color
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ), // Increased vertical padding
                  minimumSize: const Size.fromHeight(50), // Set minimum height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.beeYellow,
                    ), // Yellow border
                  ),
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => CancelBookingPopup(
                      onCancelBooking: () {
                        Navigator.of(context).pop();
                        _showCompletionPopup("cancel");
                      },
                    ),
                  );
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black, // Black text
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Reschedule Button - Yellow background with white text
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.beeYellow, // Yellow background
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ), // Increased vertical padding
                  minimumSize: const Size.fromHeight(50), // Set minimum height
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
                    color: Colors.white, // White text
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
  static Widget _infoTile({
    required IconData icon,
    required String label,
    String? value,
  }) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
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
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🔸 Simple Completion Dialog (Text first, then icon with animation)
// -----------------------------------------------------------------------------
class _SimpleCompletionDialog extends StatefulWidget {
  final String type;
  final VoidCallback onClose;

  const _SimpleCompletionDialog({required this.type, required this.onClose});

  @override
  State<_SimpleCompletionDialog> createState() =>
      _SimpleCompletionDialogState();
}

class _SimpleCompletionDialogState extends State<_SimpleCompletionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Start animation
    _controller.forward();

    // Auto-redirect to HomeScreen after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      widget.onClose();
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

        // Center Content (Text first, then animated icon)
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text First with fade animation
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
            ],
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            behavior: HitTestBehavior.translucent,
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
        borderRadius: BorderRadius.circular(18),
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

// -----------------------------------------------------------------------------
// 🔸 Separate Cancel Booking Popup
// -----------------------------------------------------------------------------
class CancelBookingPopup extends StatefulWidget {
  final VoidCallback onCancelBooking;

  const CancelBookingPopup({super.key, required this.onCancelBooking});

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
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.black,
                    ),
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
                  onPressed: _selectedReason != null
                      ? widget.onCancelBooking
                      : null,
                  child: const Text(
                    "Cancel Booking",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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

  const ReschedulePopup({super.key, required this.onRescheduleNow});

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
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.black,
                    ),
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
                  onPressed: _selectedReason != null
                      ? widget.onRescheduleNow
                      : null,
                  child: const Text(
                    "Reschedule Now",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
  final Function(String, String) onRescheduleComplete;

  const RescheduleUI({super.key, required this.onRescheduleComplete});

  @override
  State<RescheduleUI> createState() => _RescheduleUIState();
}

class _RescheduleUIState extends State<RescheduleUI> {
  int _selectedDate = 8; // Default selected date
  String _selectedMonth = "Oct";
  int _selectedYear = 2025;
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
    "07:00 PM",
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
              color: isSelected ? AppColors.beeYellow : Colors.grey.shade300,
            ),
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
                  child: Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                List<String> days = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun',
                ];
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
                            : (isSelected
                                  ? AppColors.beeYellow
                                  : Colors.grey[300]!),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isDisabled
                                ? Colors.grey[400]
                                : (isSelected
                                      ? Colors.black
                                      : Colors.grey[700]),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isDisabled
                                ? Colors.grey[400]
                                : (isSelected
                                      ? Colors.black
                                      : Colors.grey[700]),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: _getAvailableTimeSlots()),

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
                  const Icon(
                    Icons.access_time,
                    color: AppColors.beeYellow,
                    size: 16,
                  ),
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
              onPressed: _selectedTimeSlot != null
                  ? () {
                      widget.onRescheduleComplete(
                        "$_selectedDate $_selectedMonth $_selectedYear",
                        _selectedTimeSlot!,
                      );
                    }
                  : null,
              child: Text(
                _selectedTimeSlot != null
                    ? "Reschedule for $_selectedTimeSlot"
                    : "Select Time to Reschedule",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
