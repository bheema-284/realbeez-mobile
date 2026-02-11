import 'dart:async';
import 'package:flutter/material.dart';
import 'package:real_beez/screens/homescreen/home_screen.dart';
import 'package:real_beez/screens/landing_pages/onboarding_screen.dart';
import 'package:real_beez/utils/app_colors.dart';

class OtpVerificationPage extends StatefulWidget {
  final String id;
  final bool isAadhaar;
  final LoginType loginType; // Add this
  final bool isSignUp; // Add this

  const OtpVerificationPage({
    super.key,
    required this.id,
    required this.isAadhaar,
    required this.loginType, // Add this
    this.isSignUp = false, // Add this with default value
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  int _focusedIndex = -1;
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleFakeVerify() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all 6 digits")),
      );
      return;
    }

    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isVerifying = false);

    // You can use the loginType and isSignUp flags here if needed
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Widget _buildOtpBox(int index) {
    bool isFocused = _focusedIndex == index;
    bool isFilled = _otpControllers[index].text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 45,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          width: 1,
          color: isFocused || isFilled
              ? AppColors.beeYellow
              : const Color.fromARGB(255, 150, 148, 148),
        ),
      ),
      child: Center(
        child: TextField(
          controller: _otpControllers[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          onTap: () => setState(() => _focusedIndex = index),
          style: const TextStyle(fontSize: 16, color: AppColors.textDark),
          decoration: const InputDecoration(
            counterText: "",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              FocusScope.of(context).nextFocus();
              setState(() => _focusedIndex = index + 1);
            } else if (value.isEmpty && index > 0) {
              FocusScope.of(context).previousFocus();
              setState(() => _focusedIndex = index - 1);
            }
            setState(() {});
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          children: [
            const SizedBox(height: 70),

            /// OTP sent text - update to show correct message based on loginType
            Text(
              widget.isSignUp
                  ? "Verify your ${widget.loginType == LoginType.phone ? 'mobile number' : 'email'} for signup"
                  : "OTP sent to ${widget.isAadhaar
                        ? 'Aadhaar'
                        : widget.loginType == LoginType.phone
                        ? 'Mobile'
                        : 'Email'} ${widget.id}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (i) => _buildOtpBox(i)),
            ),

            const SizedBox(height: 25),

            _secondsRemaining > 0
                ? Text(
                    "Resend OTP in $_formattedTime",
                    style: const TextStyle(color: AppColors.textDark),
                  )
                : const Text(
                    "Resend Code",
                    style: TextStyle(color: AppColors.beeYellow),
                  ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.beeYellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isVerifying ? null : _handleFakeVerify,
                child: _isVerifying
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.isSignUp
                            ? "Verify & Sign Up"
                            : "Verify & Continue",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
