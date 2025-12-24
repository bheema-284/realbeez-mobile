import 'package:flutter/material.dart';
import 'package:real_beez/screens/booking_screens/booking_confirm.dart';
import 'package:real_beez/utils/app_colors.dart';
import 'package:video_player/video_player.dart';
import 'package:real_beez/screens/api/cab_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const BookServiceApp());
}

class BookServiceApp extends StatelessWidget {
  const BookServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BookServiceScreen(),
    );
  }
}

class BookServiceScreen extends StatefulWidget {
  const BookServiceScreen({super.key});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  late VideoPlayerController _controller;

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dropLocationController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _membersController = TextEditingController();

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final List<int> _years = [2024, 2025, 2026, 2027, 2028];

  String _selectedMonth = 'July';
  int _selectedYear = 2024;
  int _selectedDate = 24;
  final DateTime _currentDate = DateTime.now();
  String? _selectedTimeSlot;

  bool _showBookingConfirmation = false;

  @override
  void initState() {
    super.initState();

    // ------------------------------------------
    // AUTO FILL SAVED NAME FROM SHARED PREFERENCES
    // ------------------------------------------
    _loadSavedName();

    _controller = VideoPlayerController.asset(
      'assets/videos/real_estate.mp4',
    )..initialize().then((_) {
        setState(() {});
      });

    _controller.addListener(() {
      setState(() {});
    });

    _selectedDate = _currentDate.day;
    _selectedMonth = _months[_currentDate.month - 1];
    _selectedYear = _currentDate.year;
  }

  // ------------------------------------------------
  // NEW — LOAD NAME FROM REGISTER SCREEN (Local Data)
  // ------------------------------------------------
  Future<void> _loadSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString("fullName");

    if (savedName != null && savedName.isNotEmpty) {
      setState(() {
        _nameController.text = savedName;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _locationController.dispose();
    _dropLocationController.dispose();
    _nameController.dispose();
    _membersController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void _showMonthYearPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Month',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: _months.length,
                  itemBuilder: (context, index) {
                    bool isDisabled = _isMonthDisabled(index + 1, _selectedYear);
                    return TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: _selectedMonth == _months[index]
                            ? AppColors.beeYellow
                            : (isDisabled ? Colors.grey[100] : Colors.grey[100]),
                        padding: const EdgeInsets.all(4),
                        minimumSize: Size.zero,
                      ),
                      onPressed: isDisabled
                          ? null
                          : () {
                              setState(() {
                                _selectedMonth = _months[index];
                                _selectedTimeSlot = null;
                              });
                              Navigator.pop(context);
                            },
                      child: Text(
                        _months[index].substring(0, 3),
                        style: TextStyle(
                          fontSize: 12,
                          color: _selectedMonth == _months[index]
                              ? Colors.white
                              : (isDisabled ? Colors.grey[400] : Colors.black),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                const Text(
                  'Select Year',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: _years.length,
                  itemBuilder: (context, index) {
                    bool isDisabled = _isYearDisabled(_years[index]);
                    return TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: _selectedYear == _years[index]
                            ? AppColors.beeYellow
                            : (isDisabled ? Colors.grey[100] : Colors.grey[100]),
                        padding: const EdgeInsets.all(4),
                        minimumSize: Size.zero,
                      ),
                      onPressed: isDisabled
                          ? null
                          : () {
                              setState(() {
                                _selectedYear = _years[index];
                                _selectedTimeSlot = null;
                              });
                              Navigator.pop(context);
                            },
                      child: Text(
                        _years[index].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _selectedYear == _years[index]
                              ? Colors.white
                              : (isDisabled ? Colors.grey[400] : Colors.black),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Close',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBookingConfirmationOverlay() {
    setState(() {
      _showBookingConfirmation = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showBookingConfirmation = false;
        });
      }
    });
  }

  void _showConfirmationDialog() {
    final parentContext = context;

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select Date:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Text(
                  "$_selectedMonth, $_selectedYear",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Text("Mon", style: TextStyle(fontSize: 12)),
                    Text("Tue", style: TextStyle(fontSize: 12)),
                    Text("Wed", style: TextStyle(fontSize: 12)),
                    Text("Thu", style: TextStyle(fontSize: 12)),
                    Text("Fri", style: TextStyle(fontSize: 12)),
                    Text("Sat", style: TextStyle(fontSize: 12)),
                    Text("Sun", style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _selectedDate.toString(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Do you want to book a cab service?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          child: const Text(
                            "No",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.beeYellow,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(dialogContext);

                            final monthIndex = _months.indexOf(_selectedMonth) + 1;

                            final bookingDate =
                                "${_selectedYear.toString().padLeft(4, '0')}-"
                                "${monthIndex.toString().padLeft(2, '0')}-"
                                "${_selectedDate.toString().padLeft(2, '0')}";

                            String bookingTime = "";
                            if (_selectedTimeSlot != null) {
                              bookingTime = _convertTo24HourFormat(_selectedTimeSlot!);
                            }

                            final bookingId =
                                "BK${DateTime.now().millisecondsSinceEpoch}";

                            final passengerCount =
                                int.tryParse(_membersController.text.trim()) ?? 1;

                            final pickupLocation =
                                _locationController.text.trim();
                            final dropLocation =
                                _dropLocationController.text.trim();
                            final name =
                                _nameController.text.trim();

                            if (pickupLocation.isEmpty) {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Please enter pickup location")),
                              );
                              return;
                            }

                            if (dropLocation.isEmpty) {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Please enter drop location")),
                              );
                              return;
                            }

                            if (name.isEmpty) {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                    content: Text("Please enter your name")),
                              );
                              return;
                            }

                            if (bookingTime.isEmpty) {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                    content: Text("Please select a time slot")),
                              );
                              return;
                            }

                            final response = await CabService.postCabBooking(
                              bookingId: bookingId,
                              passengerCount: passengerCount,
                              bookingDate: bookingDate,
                              bookingTime: bookingTime,
                              pickupLocation: pickupLocation,
                              dropLocation: dropLocation,
                            );

                            ScaffoldMessenger.of(parentContext)
                                .hideCurrentSnackBar();

                            if (!mounted) return;

                            if (response["success"] == true) {
                              _showBookingConfirmationOverlay();

                              String newBookingId = "";
                              if (response["data"] != null) {
                                if (response["data"]["_id"] != null) {
                                  newBookingId =
                                      response["data"]["_id"].toString();
                                } else if (response["data"]["id"] != null) {
                                  newBookingId =
                                      response["data"]["id"].toString();
                                } else if (response["data"]["bookingId"] !=
                                    null) {
                                  newBookingId = response["data"]["bookingId"]
                                      .toString();
                                }
                              }

                              if (newBookingId.isEmpty) {
                                newBookingId = bookingId;
                              }

                              _locationController.clear();
                              _dropLocationController.clear();
                              _nameController.clear();
                              _membersController.clear();
                              setState(() {
                                _selectedTimeSlot = null;
                              });

                              Future.delayed(const Duration(seconds: 2), () {
                                if (mounted) {
                                  Navigator.push(
                                    parentContext,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BookingConfirmationScreen(
                                        bookingId: newBookingId,
                                      ),
                                    ),
                                  );
                                }
                              });
                            } else {
                              String errorMessage = response["message"] ??
                                  "Failed to create booking";
                              if (response["statusCode"] != null) {
                                errorMessage +=
                                    " (Status: ${response["statusCode"]})";
                              }

                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "Yes",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  String _convertTo24HourFormat(String time12Hour) {
    try {
      List<String> parts = time12Hour.split(' ');
      List<String> timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      String period = parts[1];

      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return time12Hour;
    }
  }

  bool _isMonthDisabled(int month, int year) {
    DateTime now = DateTime.now();
    if (year < now.year) return true;
    if (year == now.year && month < now.month) return true;
    return false;
  }

  bool _isYearDisabled(int year) {
    return year < DateTime.now().year;
  }

  bool _isDateDisabled(int day) {
    DateTime now = DateTime.now();
    int selectedMonthIndex = _months.indexOf(_selectedMonth) + 1;

    if (_selectedYear < now.year) return true;
    if (_selectedYear == now.year && selectedMonthIndex < now.month) {
      return true;
    }
    if (_selectedYear == now.year && selectedMonthIndex == now.month) {
      return day < now.day;
    }

    return false;
  }

  bool _isTimeSlotAvailable(String time) {
    DateTime now = DateTime.now();
    DateTime selectedDateTime =
        DateTime(_selectedYear, _months.indexOf(_selectedMonth) + 1, _selectedDate);

    if (selectedDateTime.year == now.year &&
        selectedDateTime.month == now.month &&
        selectedDateTime.day == now.day) {
      TimeOfDay selectedTime = _parseTimeString(time);
      TimeOfDay currentTime = TimeOfDay.fromDateTime(now);

      if (selectedTime.hour < currentTime.hour) return false;
      if (selectedTime.hour == currentTime.hour &&
          selectedTime.minute <= currentTime.minute) return false;
    }
    return true;
  }

  TimeOfDay _parseTimeString(String time) {
    List<String> parts = time.split(' ');
    List<String> timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    if (parts[1] == 'PM' && hour != 12) hour += 12;
    if (parts[1] == 'AM' && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  List<Widget> _getAvailableTimeSlots() {
    List<Widget> slots = [];

    List<Map<String, dynamic>> allSlots = [
      {'time': '9:30 AM', 'booked': true},
      {'time': '10:30 AM', 'booked': false},
      {'time': '3:30 PM', 'booked': true},
      {'time': '5:30 PM', 'booked': true},
      {'time': '6:30 PM', 'booked': false},
      {'time': '7:30 PM', 'booked': false},
      {'time': '8:30 PM', 'booked': false},
      {'time': '9:30 PM', 'booked': false},
      {'time': '10:30 PM', 'booked': true},
    ];

    for (var slot in allSlots) {
      String time = slot['time'];
      bool booked = slot['booked'];
      bool available = !booked && _isTimeSlotAvailable(time);
      bool isSelected = _selectedTimeSlot == time;

      if (booked || available) {
        slots.add(
          buildTimeSlot(
            time,
            booked: booked,
            available: available,
            isSelected: isSelected,
            onTap: () {
              if (available && !booked) {
                setState(() {
                  _selectedTimeSlot = time;
                });
              }
            },
          ),
        );
      }
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EEDC),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Text(
                      "Book Your Services",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _controller.value.isInitialized
                            ? GestureDetector(
                                onTap: _togglePlayPause,
                                child: SizedBox(
                                  height: 180,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: AspectRatio(
                                          aspectRatio: _controller.value.aspectRatio,
                                          child: VideoPlayer(_controller),
                                        ),
                                      ),
                                      if (!_controller.value.isPlaying)
                                        Container(
                                          color: Colors.transparent,
                                          child: Center(
                                            child: Container(
                                              height: 50,
                                              width: 50,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.play_arrow,
                                                color: Colors.black,
                                                size: 32,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (_controller.value.isPlaying)
                                        Container(
                                          color: Colors.transparent,
                                          child: Center(
                                            child: Opacity(
                                              opacity: 0.7,
                                              child: Container(
                                                height: 50,
                                                width: 50,
                                                decoration: const BoxDecoration(
                                                  color: Colors.black,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.pause,
                                                  color: Colors.white,
                                                  size: 32,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[300],
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                        const SizedBox(height: 10),

                        const Text(
                          "SMR Buildings",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Current Location",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            hintText: "Liberty (40.6892° N, 74.0445° W)",
                            hintStyle: TextStyle(color: Colors.grey),
                            suffixIcon: Icon(Icons.location_on, color: Colors.red),
                            filled: true,
                            fillColor: Color(0xFFFFFFFF),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: Color(0xFFDBDADA), width: 0.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: Color(0xFFDBDADA), width: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Drop Location",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _dropLocationController,
                          decoration: const InputDecoration(
                            hintText: "Enter Drop Location",
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Color(0xFFFFFFFF),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: Color(0xFFDBDADA), width: 0.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: Color(0xFFDBDADA), width: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Name",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: "Enter Name",
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Color(0xFFFFFFFF),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: Color(0xFFDBDADA), width: 0.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: Color(0xFFDBDADA), width: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Members",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _membersController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Enter Members",
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Color(0xFFFFFFFF),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: Color(0xFFDBDADA), width: 0.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: Color(0xFFDBDADA), width: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Select Date:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: _showMonthYearPicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "$_selectedMonth, $_selectedYear",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_drop_down, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        SizedBox(
                          height: 70,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: List.generate(31, (index) {
                              int dayNumber = index + 1;
                              List<String> days = [
                                'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
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
                                        : (isSelected
                                            ? AppColors.beeYellow
                                            : Colors.white),
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

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Select Schedule Time:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _getAvailableTimeSlots(),
                        ),

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

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.beeYellow,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _showConfirmationDialog,
                            child: Text(
                              _selectedTimeSlot != null
                                  ? "Book Your Services for $_selectedTimeSlot"
                                  : "Book Your Services",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          if (_showBookingConfirmation)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Booking Confirmed!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // SLOT WIDGET---------------------------------------
  Widget buildTimeSlot(
    String time, {
    bool booked = false,
    bool available = false,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    if (booked) {
      return Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text("Booked", style: TextStyle(color: Colors.black54)),
          ],
        ),
      );
    } else if (isSelected) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.beeYellow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text("Selected",
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              )
            ],
          ),
        ),
      );
    } else if (available) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.green),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.circle, size: 8, color: Colors.green),
                  SizedBox(width: 4),
                  Text("Available",
                      style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              )
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
