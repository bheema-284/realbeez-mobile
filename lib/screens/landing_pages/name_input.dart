import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_beez/screens/homescreen/home_screen.dart';
import 'package:real_beez/utils/app_colors.dart';
import 'package:real_beez/screens/forms/common_button.dart';
import 'package:real_beez/screens/forms/common_text.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Added

void main() {
  runApp(MaterialApp(
    home: NameInputPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class NameInputPage extends StatefulWidget {
  const NameInputPage({super.key});

  @override
  State<NameInputPage> createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  String? _selectedGender;
  String? _errorMessage;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _onSubmit() async {
    final fullName = _fullNameController.text.trim();
    final dateOfBirth = _dateOfBirthController.text.trim();

    // Check for empty fields
    if (fullName.isEmpty || dateOfBirth.isEmpty) {
      setState(() {
        _errorMessage = "Please fill in all fields";
      });
      return;
    }

    // Check if gender is selected
    if (_selectedGender == null) {
      setState(() {
        _errorMessage = "Please select your gender";
      });
      return;
    }

    // Allow only alphabets for name
    final RegExp nameRegExp = RegExp(r'^[A-Za-z ]+$');
    if (!nameRegExp.hasMatch(fullName)) {
      setState(() {
        _errorMessage = "Name can only contain letters (A–Z)";
      });
      return;
    }

    // ✅ Clear error and save login state
    setState(() {
      _errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('fullName', fullName);
    await prefs.setString('gender', _selectedGender!);
    await prefs.setString('dob', dateOfBirth);

    // ✅ Navigate to Home after saving
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  HomeScreen()),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.greyText),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.beeYellow),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.beeYellow, width: 1.2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  InputDecoration _dateFieldDecoration() {
    return InputDecoration(
      hintText: "DD/MM/YYYY",
      hintStyle: const TextStyle(color: AppColors.greyText),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.beeYellow),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.beeYellow, width: 1.2),
        borderRadius: BorderRadius.circular(8),
      ),
      suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today, color: AppColors.beeYellow),
        onPressed: _selectDate,
      ),
    );
  }

  Widget _buildGenderOption(String gender, String displayText) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: _selectedGender == gender
                ? AppColors.beeYellow
                : Colors.transparent,
            border: Border.all(
              color: AppColors.beeYellow,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            displayText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _selectedGender == gender
                  ? AppColors.white
                  : AppColors.beeYellow,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonText(
              text: "What's your name?",
              isBold: true,
              fontSize: 16,
            ),
            const SizedBox(height: 12),

            // ✅ Full Name Field
            TextField(
              controller: _fullNameController,
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
              ],
              decoration: _fieldDecoration("Full Name"),
            ),

            const SizedBox(height: 20),

            // ✅ Date of Birth Field
            const CommonText(
              text: "Date of Birth",
              isBold: true,
              fontSize: 16,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dateOfBirthController,
              readOnly: true,
              decoration: _dateFieldDecoration(),
              onTap: _selectDate,
            ),

            const SizedBox(height: 20),

            // ✅ Gender Selection
            const CommonText(
              text: "Gender",
              isBold: true,
              fontSize: 16,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildGenderOption("male", "Male"),
                const SizedBox(width: 12),
                _buildGenderOption("female", "Female"),
                const SizedBox(width: 12),
                _buildGenderOption("other", "Other"),
              ],
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              CommonText(
                text: _errorMessage!,
                color: Colors.red,
                fontSize: 12,
              ),
            ],

            const Spacer(),
            CommonButton(
              text: "Let's Get Started",
              onPressed: _onSubmit,
              backgroundColor: AppColors.beeYellow,
              textColor: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image.asset(
          'assets/images/submit.png',
          width: 120,
          height: 120,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
