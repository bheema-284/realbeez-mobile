import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:real_beez/screens/api/auth_service.dart';
import 'package:real_beez/screens/landing_pages/otp_verification.dart';
import 'package:real_beez/screens/landing_pages/signin.dart';
import '../../utils/app_colors.dart';

enum LoginType { phone, email }

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  LoginType _loginType = LoginType.email;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _emailError;
  String? _phoneError;
  String _selectedCode = "+91"; // Default country code

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Email validation function
  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
      caseSensitive: false,
    );
    return emailRegex.hasMatch(email.trim());
  }

  // Phone validation function
  bool _isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    // Remove any non-digit characters
    final cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    // Check for minimum length (considering country codes)
    if (cleanedPhone.length < 8) return false;
    // Check if it contains only digits and optional +
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    return phoneRegex.hasMatch(cleanedPhone);
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    final input = _loginType == LoginType.email
        ? _emailController.text.trim()
        : _phoneController.text.trim();

    // Reset errors
    setState(() {
      _emailError = null;
      _phoneError = null;
    });

    // Check if input is empty
    if (input.isEmpty) {
      setState(() {
        if (_loginType == LoginType.email) {
          _emailError = 'Please enter your email address';
        } else {
          _phoneError = 'Please enter your phone number';
        }
      });
      _showErrorSnackBar(
        _loginType == LoginType.email
            ? 'Please enter your email address'
            : 'Please enter your phone number',
      );
      return;
    }

    // Basic validation
    if (_loginType == LoginType.email) {
      if (!_isValidEmail(input)) {
        setState(() {
          _emailError = 'Please enter a valid email address';
        });
        _showErrorSnackBar('Please enter a valid email address');
        return;
      }
    } else {
      if (!_isValidPhone(input)) {
        setState(() {
          _phoneError = 'Please enter a valid phone number';
        });
        _showErrorSnackBar('Please enter a valid phone number');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final fullPhone = _loginType == LoginType.phone
          ? '$_selectedCode${input.replaceAll(RegExp(r'[^\d]'), '')}'
          : input;

      print("=== ONBOARDING SCREEN ===");
      print("Input: $input");
      print("Login Type: $_loginType");
      print("Full Phone (if phone): $fullPhone");
      print("Calling API...");

      final response = _loginType == LoginType.phone
          ? await AuthService.login(fullPhone)
          : await AuthService.loginWithEmail(input);

      print("=== NAVIGATION DECISION ===");
      print("API Success: ${response["success"]}");
      print("API Exists: ${response["exists"]}");
      print("API Message: ${response["message"]}");
      print("========================");

      setState(() => _isLoading = false);

      if (response["success"] == true) {
        // Use the exists field from API response
        bool userExists = response["exists"] == true;

        print("Final Decision:");
        print("User exists? $userExists");
        print(
          "Going to: ${userExists ? 'OTP Screen' : 'Create Account Screen'}",
        );

        if (userExists) {
          _loginType == LoginType.email
              ? await AuthService.checkEmailOtp(input)
              : await AuthService.checkPhoneOtp(fullPhone);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationPage(
                id: _loginType == LoginType.phone ? fullPhone : input,
                isAadhaar: false,
                loginType: _loginType,
              ),
            ),
          );
        } else {
          // User doesn't exist, go to Create Account
          print("Navigating to Create Account...");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CreateAccountScreen(
                initialEmail: _loginType == LoginType.email ? input : null,
                initialPhone: _loginType == LoginType.phone ? fullPhone : null,
                loginType: _loginType,
                userExists: false, // Explicitly false for new users
              ),
            ),
          );
        }
      } else {
        _showErrorSnackBar(response["message"] ?? "Something went wrong");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("Network error. Please try again.");
      print("Login error: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---------------- TOP SECTION ----------------
                SizedBox(
                  height: screenHeight * 0.4,
                  child: const ImageSwitchingHexagonLayout(
                    images: [
                      'assets/images/Polygon1.png',
                      'assets/images/Polygon2.png',
                      'assets/images/Polygon3.png',
                      'assets/images/Polygon4.png',
                      'assets/images/Polygon5.png',
                      'assets/images/Polygon6.png',
                    ],
                  ),
                ),

                SizedBox(
                  height: screenHeight * 0.1,
                  child: Center(
                    child: Image.asset(
                      'assets/logo/logo.png',
                      width: 300,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ---------------- LOGIN TYPE SELECTION ----------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRadio(LoginType.email, 'Email'),
                    const SizedBox(width: 24),
                    _buildRadio(LoginType.phone, 'Phone'),
                  ],
                ),

                const SizedBox(height: 20),

                // ---------------- COUNTRY CODE FOR PHONE ----------------
                if (_loginType == LoginType.phone) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color.fromARGB(255, 222, 219, 219),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.language,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Country Code:',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCode,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: "+91",
                                child: Text("+91 India"),
                              ),
                              DropdownMenuItem(
                                value: "+1",
                                child: Text("+1 USA"),
                              ),
                              DropdownMenuItem(
                                value: "+44",
                                child: Text("+44 UK"),
                              ),
                              DropdownMenuItem(
                                value: "+971",
                                child: Text("+971 UAE"),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedCode = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ---------------- INPUT FIELD ----------------
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              (_loginType == LoginType.email &&
                                      _emailError != null) ||
                                  (_loginType == LoginType.phone &&
                                      _phoneError != null)
                              ? Colors.red
                              : const Color.fromARGB(255, 222, 219, 219),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(
                            _loginType == LoginType.email
                                ? Icons.email_outlined
                                : Icons.phone_outlined,
                            color:
                                (_loginType == LoginType.email &&
                                        _emailError != null) ||
                                    (_loginType == LoginType.phone &&
                                        _phoneError != null)
                                ? Colors.red
                                : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _loginType == LoginType.email
                                  ? _emailController
                                  : _phoneController,
                              keyboardType: _loginType == LoginType.email
                                  ? TextInputType.emailAddress
                                  : TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: _loginType == LoginType.email
                                    ? 'Email Address *'
                                    : 'Phone Number *',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color:
                                      (_loginType == LoginType.email &&
                                              _emailError != null) ||
                                          (_loginType == LoginType.phone &&
                                              _phoneError != null)
                                      ? Colors.red.withOpacity(0.7)
                                      : Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          if ((_loginType == LoginType.email &&
                                  _emailController.text.isNotEmpty) ||
                              (_loginType == LoginType.phone &&
                                  _phoneController.text.isNotEmpty))
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  setState(() {
                                    if (_loginType == LoginType.email) {
                                      _emailController.clear();
                                      _emailError = null;
                                    } else {
                                      _phoneController.clear();
                                      _phoneError = null;
                                    }
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Error message below input field
                    if (_loginType == LoginType.email && _emailError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Text(
                          _emailError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (_loginType == LoginType.phone && _phoneError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Text(
                          _phoneError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // ---------------- CONTINUE BUTTON ----------------
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.beeYellow.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.beeYellow,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 20),

                // ---------------- TERMS AND PRIVACY POLICY ----------------
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'By continuing, you agree to Real Beez\'s Terms and Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔘 RADIO BUTTON WIDGET
  Widget _buildRadio(LoginType type, String label) {
    final isSelected = _loginType == type;

    return GestureDetector(
      onTap: () {
        // Clear errors when switching
        setState(() {
          _loginType = type;
          _emailError = null;
          _phoneError = null;
        });
      },
      child: Row(
        children: [
          Radio<LoginType>(
            value: type,
            groupValue: _loginType,
            activeColor: AppColors.beeYellow,
            onChanged: (value) {
              setState(() {
                _loginType = value!;
                _emailError = null;
                _phoneError = null;
              });
            },
          ),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// IMAGE SWITCHING HEXAGON LAYOUT (UNCHANGED)
// ------------------------------------------------------------------
class ImageSwitchingHexagonLayout extends StatefulWidget {
  final List<String> images;
  const ImageSwitchingHexagonLayout({super.key, required this.images});

  @override
  State<ImageSwitchingHexagonLayout> createState() =>
      _ImageSwitchingHexagonLayoutState();
}

class _ImageSwitchingHexagonLayoutState
    extends State<ImageSwitchingHexagonLayout>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentCycle = 0;
  final int _totalCycles = 6;
  final List<List<int>> _patterns = [
    [0, 1, 2, 3, 4, 5],
    [1, 2, 3, 4, 5, 0],
    [3, 4, 5, 0, 1, 2],
    [5, 0, 1, 2, 3, 4],
    [2, 3, 4, 5, 0, 1],
    [4, 5, 0, 1, 2, 3],
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                _currentCycle = (_currentCycle + 1) % _totalCycles;
              });
              Future.delayed(const Duration(milliseconds: 500), () {
                _controller.forward(from: 0);
              });
            }
          });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.2;
    final spacing = size * 0.1;
    final current = _patterns[_currentCycle];
    final next = _patterns[(_currentCycle + 1) % _totalCycles];

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _hex(widget.images[current[0]], widget.images[next[0]], size),
            SizedBox(height: size * 0.06),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _hex(widget.images[current[1]], widget.images[next[1]], size),
                SizedBox(width: spacing),
                _hex(widget.images[current[2]], widget.images[next[2]], size),
              ],
            ),
            SizedBox(height: size * 0.1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _hex(widget.images[current[3]], widget.images[next[3]], size),
                SizedBox(width: spacing),
                _hex(widget.images[current[4]], widget.images[next[4]], size),
                SizedBox(width: spacing),
                _hex(widget.images[current[5]], widget.images[next[5]], size),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _hex(String current, String next, double size) {
    return Stack(
      children: [
        Opacity(
          opacity: 1 - _controller.value,
          child: _buildHexagon(current, size),
        ),
        Opacity(opacity: _controller.value, child: _buildHexagon(next, size)),
      ],
    );
  }

  Widget _buildHexagon(String image, double size) {
    return ClipPath(
      clipper: VerticalHexagonClipper(),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(image, fit: BoxFit.cover),
      ),
    );
  }
}

class VerticalHexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.25)
      ..lineTo(w, h * 0.75)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.75)
      ..lineTo(0, h * 0.25)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
