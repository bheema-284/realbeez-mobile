import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_beez/screens/api/auth_service.dart';
import 'package:real_beez/utils/app_colors.dart';
import 'package:real_beez/screens/forms/common_text.dart';
import 'package:real_beez/screens/forms/landing_layout.dart';
import 'package:real_beez/screens/landing_pages/otp_verification.dart';

class RegisterNumberScreen extends StatefulWidget {
  const RegisterNumberScreen({super.key});

  @override
  State<RegisterNumberScreen> createState() => _RegisterNumberScreenState();
}

class _RegisterNumberScreenState extends State<RegisterNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  String _selectedCode = "+91";
  final List<String> _codes = ["+91", "+1", "+44", "+971"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_phoneFocus);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  // ==============================================================  
  // LOGIN → then navigate to OTP screen (no backend OTP validation)
  // ==============================================================  
  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();

    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter a valid 10-digit mobile starting with 6-9')),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    // 🔥 CALL BACKEND LOGIN API
    final response = await AuthService.login(phone);

    Navigator.pop(context); // close loader

    if (response["success"]) {
      print("✔ USER ID: ${response['userId']}");
      print("✔ ACCESS TOKEN: ${response['accessToken']}");
      print("✔ REFRESH TOKEN: ${response['refreshToken']}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "Login successful")),
      );

      // 🔥 STILL GO TO OTP SCREEN (UI only)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationPage(
            id: phone,
            isAadhaar: false,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "Login failed")),
      );
    }
  }

  // ==============================================================  
  // UI — PHONE FIELD
  // ==============================================================  
  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.beeYellow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Country Code
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: const BoxDecoration(
                  border:
                      Border(right: BorderSide(color: Colors.white, width: 1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCode,
                    dropdownColor: Colors.white,
                    icon: const SizedBox.shrink(),
                    items: _codes.map((code) {
                      return DropdownMenuItem(
                        value: code,
                        child:
                            Text(code, style: const TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedCode = value);
                    },
                    selectedItemBuilder: (_) {
                      return _codes.map((code) {
                        return Row(
                          children: [
                            Text(code,
                                style: const TextStyle(color: Colors.white)),
                            const Icon(Icons.keyboard_arrow_down,
                                color: Colors.white, size: 16),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
              ),

              // Phone Number Input
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter Mobile Number',
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),

              // Next Button
              GestureDetector(
                onTap: _handleLogin,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      ">",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        const CommonText(
          text: 'Continue to login using your mobile number',
          fontSize: 12,
          color: AppColors.greyText,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LandingLayout(
      title: 'LOGIN WITH MOBILE NUMBER',
      showBack: true,
      belowLogo: _buildPhoneInput(),
    );
  }
}
