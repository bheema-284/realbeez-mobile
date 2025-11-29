import 'package:flutter/material.dart';
import 'package:real_beez/utils/app_colors.dart';

class SchedulePicker extends StatefulWidget {
  final String selectedMonth;
  final int selectedYear;
  final int selectedDate;
  final String? selectedTimeSlot;
  final Function(int day, String month, int year) onDateChanged;
  final Function(String time) onTimeSlotSelected;

  const SchedulePicker({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.onDateChanged,
    required this.onTimeSlotSelected,
  });

  static const List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const List<int> years = [2024, 2025, 2026, 2027, 2028];

  @override
  State<SchedulePicker> createState() => _SchedulePickerState();
}

class _SchedulePickerState extends State<SchedulePicker> {
  late String _selectedMonth;
  late int _selectedYear;
  late int _selectedDate;
  String? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.selectedMonth;
    _selectedYear = widget.selectedYear;
    _selectedDate = widget.selectedDate;
    _selectedTimeSlot = widget.selectedTimeSlot;
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
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
                  itemCount: SchedulePicker.months.length,
                  itemBuilder: (context, index) {
                    bool isDisabled = _isMonthDisabled(index + 1, _selectedYear);
                    return TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: _selectedMonth == SchedulePicker.months[index] 
                            ? AppColors.beeYellow 
                            : (isDisabled ? Colors.grey[100] : Colors.grey[100]),
                        padding: const EdgeInsets.all(4),
                        minimumSize: Size.zero,
                      ),
                      onPressed: isDisabled ? null : () {
                        setState(() {
                          _selectedMonth = SchedulePicker.months[index];
                          _selectedTimeSlot = null;
                        });
                        widget.onDateChanged(_selectedDate, _selectedMonth, _selectedYear);
                        Navigator.pop(context);
                      },
                      child: Text(
                        SchedulePicker.months[index].substring(0, 3),
                        style: TextStyle(
                          fontSize: 12,
                          color: _selectedMonth == SchedulePicker.months[index] 
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
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
                  itemCount: SchedulePicker.years.length,
                  itemBuilder: (context, index) {
                    bool isDisabled = _isYearDisabled(SchedulePicker.years[index]);
                    return TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: _selectedYear == SchedulePicker.years[index] 
                            ? AppColors.beeYellow 
                            : (isDisabled ? Colors.grey[100] : Colors.grey[100]),
                        padding: const EdgeInsets.all(4),
                        minimumSize: Size.zero,
                      ),
                      onPressed: isDisabled ? null : () {
                        setState(() {
                          _selectedYear = SchedulePicker.years[index];
                          _selectedTimeSlot = null;
                        });
                        widget.onDateChanged(_selectedDate, _selectedMonth, _selectedYear);
                        Navigator.pop(context);
                      },
                      child: Text(
                        SchedulePicker.years[index].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _selectedYear == SchedulePicker.years[index] 
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
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
    int selectedMonthIndex = SchedulePicker.months.indexOf(_selectedMonth) + 1;
    if (_selectedYear < now.year) return true;
    if (_selectedYear == now.year && selectedMonthIndex < now.month) return true;
    if (_selectedYear == now.year && selectedMonthIndex == now.month && day < now.day) return true;
    return false;
  }

  bool _isTimeSlotAvailable(String time) {
    DateTime now = DateTime.now();
    DateTime selectedDateTime = DateTime(_selectedYear, SchedulePicker.months.indexOf(_selectedMonth) + 1, _selectedDate);
    if (selectedDateTime.year == now.year &&
        selectedDateTime.month == now.month &&
        selectedDateTime.day == now.day) {
      TimeOfDay selectedTime = _parseTimeString(time);
      TimeOfDay currentTime = TimeOfDay.fromDateTime(now);
      if (selectedTime.hour < currentTime.hour) return false;
      if (selectedTime.hour == currentTime.hour && selectedTime.minute <= currentTime.minute) return false;
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
        slots.add(buildTimeSlot(
          time,
          booked: booked,
          available: available,
          isSelected: isSelected,
          onTap: () {
            if (available && !booked) {
              setState(() {
                _selectedTimeSlot = time;
              });
              widget.onTimeSlotSelected(time);
            }
          },
        ));
      }
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ---------------- Month & Year ----------------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Select Date:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
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

        // ---------------- Horizontal Dates ----------------
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
                onTap: isDisabled ? null : () {
                  setState(() {
                    _selectedDate = dayNumber;
                    _selectedTimeSlot = null;
                  });
                  widget.onDateChanged(_selectedDate, _selectedMonth, _selectedYear);
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

        // ---------------- Time Slots ----------------
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Select Schedule Time:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              // ignore: deprecated_member_use
              color: AppColors.beeYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.beeYellow),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, color: AppColors.beeYellow, size: 16),
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
      ],
    );
  }

  Widget buildTimeSlot(String time,
      {bool booked = false, bool available = false, bool isSelected = false, VoidCallback? onTap}) {
    if (booked) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          time,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      );
    } else if (available) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.beeYellow : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.beeYellow),
          ),
          child: Text(
            time,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 14,
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
