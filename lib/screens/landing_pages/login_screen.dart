import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_beez/screens/landing_pages/otp_verification.dart';
import 'package:real_beez/utils/app_colors.dart';
import 'package:real_beez/screens/forms/common_text.dart';
import 'package:real_beez/screens/forms/landing_layout.dart';

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
      if (mounted) FocusScope.of(context).requestFocus(_phoneFocus);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

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
              // Flat country code + tiny down arrow
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.white, width: 1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCode,
                    dropdownColor: Colors.white,
                    icon: const SizedBox
                        .shrink(), // remove default Flutter dropdown arrow
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    items: _codes.map((code) {
                      return DropdownMenuItem(
                        value: code,
                        child: Text(
                          code,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCode = value);
                      }
                    },
                    // custom "code + arrow" look
                    selectedItemBuilder: (context) {
                      return _codes.map((code) {
                        return Row(
                          children: [
                            Text(
                              code,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 16, // smaller custom arrow
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
              ),

              // Phone number text field
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child:TextField(
  controller: _phoneController,
  focusNode: _phoneFocus,
  keyboardType: TextInputType.phone,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10), // ✅ allow max 10 digits
    _IndianMobileFormatter(), // ✅ must start with 6-9
  ],
  style: const TextStyle(
    color: Colors.white,
    fontSize: 14,
  ),
  decoration: const InputDecoration(
    border: InputBorder.none,
    hintText: 'Enter Mobile Number',
    hintStyle: TextStyle(
      color: Colors.white70,
      fontSize: 14,
    ),
  ),
),

                ),
              ),

              // Small white circle with black ">" symbol
              GestureDetector(
                onTap: () {
                  final phone = _phoneController.text.trim();
                  final isValid = RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
                  if (!isValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter a valid 10-digit mobile starting with 6-9')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OtpVerificationPage(
                        phoneNumber: "$_selectedCode ${_phoneController.text}",
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      ">",
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
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
          text: 'We will send an OTP to verify your number',
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
      title: 'REGISTER YOUR NUMBER',
      showBack: true,
      belowLogo: _buildPhoneInput(),
    );
  }
}

// Enforces Indian mobile rule: first digit 6-9; allows interim empty/partial edits gracefully
class _IndianMobileFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue; // allow clearing
    // Block if first digit is not 6-9
    if (text.length == 1 && !RegExp(r'^[6-9]$').hasMatch(text)) {
      return oldValue; // reject first invalid digit
    }
    // Enforce digits only and max 10 is already handled by existing formatters
    return newValue;
  }
}
