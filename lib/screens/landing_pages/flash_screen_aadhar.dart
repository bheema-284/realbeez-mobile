import 'package:flutter/material.dart';
import 'package:real_beez/screens/api/auth_service.dart';
import 'package:real_beez/utils/app_colors.dart';

class AadhaarLoginScreen extends StatefulWidget {
  const AadhaarLoginScreen({super.key});

  @override
  State<AadhaarLoginScreen> createState() => _AadhaarLoginScreenState();
}

class _AadhaarLoginScreenState extends State<AadhaarLoginScreen> {
  late TextEditingController _aadhaarController;

  @override
  void initState() {
    super.initState();
    _aadhaarController = TextEditingController();
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    super.dispose();
  }

  Future<void> _handleAadhaarLogin() async {
    final aadhaar = _aadhaarController.text.trim();

    if (aadhaar.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 12-digit Aadhaar number")),
      );
      return;
    }

    // Show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: AppColors.beeYellow)),
    );

    // 🔥 Call common login API (backend treats Aadhaar as "mobile")
    final response = await AuthService.login(aadhaar);

    Navigator.pop(context); // close loader

    if (response["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "Login successful")),
      );

      // TODO: Navigate inside app after login
      // Example:
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "Login failed")),
      );
    }
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
          onPressed: () => Navigator.pop(context),
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
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 4),
            Text(
              "AADHAAR CARD",
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
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
            border: Border.all(color: AppColors.beeYellow, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter Aadhaar Number",
                style: TextStyle(
                  color: AppColors.beeYellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _aadhaarController,
                maxLength: 12,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  counterText: "",
                  isDense: true,
                  contentPadding: EdgeInsets.only(top: 4),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.beeYellow),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.beeYellow, width: 2),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _aadhaarController.text.length == 12 ? AppColors.beeYellow : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 ),
                    ),
                  ),
                  onPressed:
                      _aadhaarController.text.length == 12 ? _handleAadhaarLogin : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration:
                            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.arrow_forward,
                            color: Colors.black, size: 18),
                      )
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
