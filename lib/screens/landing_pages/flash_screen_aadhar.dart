import 'dart:math';
import 'package:flutter/material.dart';
import 'package:real_beez/screens/landing_pages/otp_verification.dart';

class AadhaarLoginApp extends StatelessWidget {
  const AadhaarLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AadhaarLoginScreen(),
    );
  }
}

class AadhaarLoginScreen extends StatefulWidget {
  const AadhaarLoginScreen({super.key});

  @override
  State<AadhaarLoginScreen> createState() => _AadhaarLoginScreenState();
}

class _AadhaarLoginScreenState extends State<AadhaarLoginScreen> {
  late TextEditingController _aadhaarController;
  late TextEditingController _captchaController;

  String captcha = "Capt6a";

  bool get isFormValid =>
      (_aadhaarController.text.length == 12) &&
      (_captchaController.text.trim() == captcha);

  @override
  void initState() {
    super.initState();
    _aadhaarController = TextEditingController();
    _captchaController = TextEditingController();
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  void _refreshCaptcha() {
    setState(() {
      // just for demo: random new captcha
      captcha = "Cap${Random().nextInt(9999)}";
    });
  }

  void _playCaptchaAudio() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Playing captcha audio...")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDE9F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            Text(
              "LOGIN WITH YOUR",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "AADHAAR CARD",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),

      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.orange, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter Aadhaar Number",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),

              TextField(
                controller: _aadhaarController,
                maxLength: 12,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  counterText: "",
                  isDense: true,
                  contentPadding: EdgeInsets.only(top: 4),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange, width: 2),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 16),

              // Captcha row
              Row(
                children: [
                  // Captcha input
                  Expanded(
                    child: TextField(
                      controller: _captchaController,
                      decoration: const InputDecoration(
                        hintText: "Enter Captcha",
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.orange,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange, width: 1),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.orange.shade50,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CaptchaWidget(captcha: captcha),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(
                            Icons.volume_up,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: _playCaptchaAudio,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: _refreshCaptcha,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // pill shape
                    ),
                  ),
                  onPressed: isFormValid
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OtpVerificationPage(
                                phoneNumber: _aadhaarController.text,
                              ),
                            ),
                          );
                        }
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Login With OTP",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ],
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

class CaptchaWidget extends StatelessWidget {
  final String captcha;
  const CaptchaWidget({super.key, required this.captcha});

  @override
  Widget build(BuildContext context) {
    final random = Random();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: captcha.split('').map((char) {
        final angle = (random.nextDouble() * 0.4) - 0.2;
        final color = [
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.orange,
          Colors.purple,
          Colors.teal,
        ][random.nextInt(6)];

        return Transform.rotate(
          angle: angle,
          child: Text(
            char,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
          ),
        );
      }).toList(),
    );
  }
}
