import 'package:flutter/material.dart';
import 'package:real_beez/screens/api/auth_service.dart';
import 'package:real_beez/screens/forms/common_button.dart';
import 'package:real_beez/screens/landing_pages/onboarding_screen.dart';
import 'package:real_beez/screens/landing_pages/otp_verification.dart';
import '../../utils/app_colors.dart';
import 'dart:convert';

class CreateAccountScreen extends StatefulWidget {
  final String? initialEmail;
  final String? initialPhone;
  final LoginType? loginType;
  final bool userExists;

  const CreateAccountScreen({
    super.key,
    this.initialEmail,
    this.initialPhone,
    this.loginType,
    this.userExists = false,
  });

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showPassword = false;
  bool _autoRedirecting = false;

  String? _nameError;
  String? _mobileError;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();

    // Check if we should auto-redirect to OTP
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoRedirect();
    });

    // Pre-fill email or phone based on what was passed
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
    if (widget.initialPhone != null) {
      _mobileController.text = widget.initialPhone!;
    }
  }

  void _checkAutoRedirect() {
    // If user exists and we have credentials, auto-redirect to OTP
    if (widget.userExists &&
        (widget.initialEmail != null || widget.initialPhone != null) &&
        !_autoRedirecting) {
      setState(() => _autoRedirecting = true);

      // Small delay to let UI build
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;

        final identifier = widget.loginType == LoginType.email
            ? widget.initialEmail
            : widget.initialPhone;

        if (identifier != null && identifier.isNotEmpty) {
          _navigateToOtp(identifier: identifier, isSignUp: false);
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Name validation function
  bool _isValidName(String name) {
    if (name.isEmpty) return false;
    if (name.trim().length < 2) return false;
    final nameRegex = RegExp(r"^[a-zA-Z\s\-'.]+$");
    if (!nameRegex.hasMatch(name)) return false;
    if (name.contains('  ')) return false;
    return true;
  }

  // Mobile validation function - NOW ALWAYS REQUIRED
  bool _isValidMobile(String mobile) {
    if (mobile.isEmpty) return false;

    final cleanedMobile = mobile.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleanedMobile.length < 10 || cleanedMobile.length > 15) return false;

    final mobileRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return mobileRegex.hasMatch(cleanedMobile);
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

  // Password validation function
  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return null;
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    if (password.toLowerCase().contains('password') ||
        password.toLowerCase().contains('123456') ||
        password.toLowerCase().contains('qwerty')) {
      return 'Please choose a stronger password';
    }

    return null;
  }

  // Format mobile number for display
  String _formatMobileNumber(String mobile) {
    if (mobile.isEmpty) return mobile;

    final digits = mobile.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length <= 5) {
      return digits;
    } else if (digits.length <= 10) {
      return '${digits.substring(0, 5)} ${digits.substring(5)}';
    } else {
      final countryCode = digits.length > 10
          ? digits.substring(0, digits.length - 10)
          : '';
      final mainNumber = digits.length > 10
          ? digits.substring(digits.length - 10)
          : digits;
      final formattedMain = mainNumber.length > 5
          ? '${mainNumber.substring(0, 5)} ${mainNumber.substring(5)}'
          : mainNumber;

      return countryCode.isNotEmpty
          ? '+$countryCode $formattedMain'
          : formattedMain;
    }
  }

  void _navigateToOtp({required String identifier, required bool isSignUp}) {
    // Use push instead of pushReplacement to keep back navigation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationPage(
          id: identifier,
          isAadhaar: false,
          loginType: widget.loginType ?? LoginType.email,
          isSignUp: isSignUp,
        ),
      ),
    );
  }

  void _createAccount() async {
    if (_isLoading) return;

    setState(() {
      _nameError = null;
      _mobileError = null;
      _emailError = null;
      _passwordError = null;
    });

    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    bool hasError = false;

    // Validate name
    if (name.isEmpty) {
      setState(() {
        _nameError = 'Name is required';
        hasError = true;
      });
    } else if (!_isValidName(name)) {
      setState(() {
        _nameError = 'Please enter a valid name (min 2 characters)';
        hasError = true;
      });
    }

    // Validate mobile - ALWAYS REQUIRED
    if (mobile.isEmpty) {
      setState(() {
        _mobileError = 'Mobile number is required';
        hasError = true;
      });
    } else if (!_isValidMobile(mobile)) {
      setState(() {
        _mobileError = 'Please enter a valid 10-15 digit mobile number';
        hasError = true;
      });
    }

    // Validate email
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email address is required';
        hasError = true;
      });
    } else if (!_isValidEmail(email)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
        hasError = true;
      });
    }

    // Validate password
    final passwordValidation = _validatePassword(password);
    if (passwordValidation != null) {
      setState(() {
        _passwordError = passwordValidation;
        hasError = true;
      });
    }

    if (hasError) {
      _showErrorSnackBar('Please fix the errors before proceeding');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.registerUser(
        jsonEncode({
          "name": name,
          "mobile": mobile,
          "email": email,
          "password": password.isNotEmpty ? password : null,
        }),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to create account. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onMobileChanged(String value) {
    setState(() => _mobileError = null);

    if (value.isNotEmpty) {
      final formatted = _formatMobileNumber(value);
      if (formatted != value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final newSelection = TextSelection.collapsed(
            offset: formatted.length,
          );
          _mobileController.value = TextEditingValue(
            text: formatted,
            selection: newSelection,
          );
        });
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? errorText,
    bool isRequired = true,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: errorText != null
                  ? Colors.red
                  : const Color.fromARGB(255, 222, 219, 219),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                prefixIcon,
                color: errorText != null ? Colors.red : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: errorText != null
                          ? Colors.red.withOpacity(0.7)
                          : Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              if (suffixIcon != null) suffixIcon,
              const SizedBox(width: 8),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while auto-redirecting
    if (_autoRedirecting) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.beeYellow),
              ),
              const SizedBox(height: 20),
              Text(
                widget.userExists ? 'Signing you in...' : 'Redirecting...',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Simply pop to go back to previous screen
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.userExists ? 'Sign In' : 'Create Account',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // CENTERED: Logo/Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.beeYellow.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.userExists ? Icons.login : Icons.person_add,
                    size: 50,
                    color: AppColors.beeYellow,
                  ),
                ),
                const SizedBox(height: 20),

                // CENTERED: Title
                Text(
                  widget.userExists ? 'Welcome Back!' : 'Create Your Account',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // CENTERED: Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    widget.userExists
                        ? 'Sign in to continue to your account'
                        : 'Please fill in all required fields to continue',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),

                // LEFT-ALIGNED: Form Fields Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Only show name field for new accounts
                      if (!widget.userExists) ...[
                        _buildTextField(
                          label: 'Full Name',
                          hintText: 'Enter your full name',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline,
                          keyboardType: TextInputType.name,
                          errorText: _nameError,
                          isRequired: true,
                          onChanged: (value) =>
                              setState(() => _nameError = null),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Mobile Number Field - ALWAYS REQUIRED
                      _buildTextField(
                        label: 'Mobile Number',
                        hintText: 'Enter your mobile number',
                        controller: _mobileController,
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        errorText: _mobileError,
                        isRequired: true,
                        onChanged: _onMobileChanged,
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      _buildTextField(
                        label: 'Email Address',
                        hintText: 'Enter your email address',
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                        isRequired: true,
                        onChanged: (value) =>
                            setState(() => _emailError = null),
                      ),
                      const SizedBox(height: 20),

                      // Password Field - Always show
                      _buildTextField(
                        label: 'Password',
                        hintText: 'Enter password',
                        controller: _passwordController,
                        prefixIcon: Icons.lock_outline,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: !_showPassword,
                        errorText: _passwordError,
                        isRequired: false,
                        onChanged: (value) =>
                            setState(() => _passwordError = null),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Password is optional but recommended for security',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Create Account/Sign In Button - Full width
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
                            : CommonButton(
                                text: widget.userExists
                                    ? 'Sign In'
                                    : 'Create Account',
                                onPressed: _createAccount,
                                backgroundColor: AppColors.beeYellow,
                                textColor: AppColors.white,
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // CENTERED: Terms and Privacy Policy
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'By creating an account, you agree to Real Beez\'s Terms of Service and Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
