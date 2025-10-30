import 'package:flutter/material.dart';
import 'package:real_beez/utils/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkGray = Color(0xFF333333);
   

    const TextStyle bodyStyle = TextStyle(
      fontSize: 15,
      color: darkGray,
      height: 1.6,
    );

    return Scaffold(
      backgroundColor: Color(0xFFFAF2DD), // Yellow background for whole screen
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            color: Colors.black, // Black title text
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFFAF2DD), // Yellow app bar background
        centerTitle: true,
  
       
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Align(
              alignment: Alignment.topRight,
              child: Image.asset(
                'assets/logo/logo.png',
                height: 80,
                width: 80,
              ),
            ),

            _buildSectionCard(
              title: "What Information We Collect",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "We collect information to provide better services to all our users, including:",
                    style: bodyStyle,
                  ),
                  SizedBox(height: 8),
                  _BulletItem(text: "Personal information such as name, email address, and contact details."),
                  _BulletItem(text: "Property-related preferences and search history."),
                  _BulletItem(text: "Device information and location data when using our mobile app."),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionCard(
              title: "How We Use Your Data",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Your data helps us enhance your Real Beez experience. We use the collected data to:",
                    style: bodyStyle,
                  ),
                  SizedBox(height: 8),
                  _BulletItem(text: "Personalize your property recommendations."),
                  _BulletItem(text: "Improve our services and mobile application."),
                  _BulletItem(text: "Communicate offers, updates, and promotions relevant to your interests."),
                  _BulletItem(text: "Comply with applicable legal and regulatory requirements."),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionCard(
              title: "Your Rights and Choices",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "You have full control over your personal data. You may:",
                    style: bodyStyle,
                  ),
                  SizedBox(height: 8),
                  _BulletItem(text: "Access, update, or delete your personal information."),
                  _BulletItem(text: "Opt out of receiving promotional emails."),
                  _BulletItem(text: "Withdraw consent for data processing at any time."),
                  SizedBox(height: 10),
                  Text(
                    "To exercise these rights, please reach out through our support channels below.",
                    style: bodyStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionCard(
              title: "Contact Us",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "For privacy concerns or inquiries, please contact our Privacy Officer:",
                    style: bodyStyle,
                  ),
                  SizedBox(height: 10),
                  _BulletItem(text: "Email: privacy@realbeez.com"),
                  _BulletItem(text: "Phone: +91 98765 43210"),
                  _BulletItem(text: "Address: 123 Real Beez Street, Hyderabad, India"),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Footer
            Center(
              child: Column(
                children: [
                  const Divider(thickness: 1, color: Colors.black54),
                  Image.asset(
                    'assets/logo/logo.png',
                    height: 80,
                    width: 80,
                  ),
                  const Text(
                    "© 2025 Real Beez. All rights reserved.",
                    style: TextStyle(
                      color: Colors.black87, // Dark text for better visibility on yellow
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white, // White card background
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.beeYellow, // Black title text
              ),
            ),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("•  ",
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF333333),
              )),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}