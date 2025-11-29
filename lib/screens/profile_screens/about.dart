import 'package:flutter/material.dart';
import 'package:real_beez/utils/app_colors.dart';


void main() {
  runApp(MaterialApp(
    home: AboutScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    const Color darkGray = Color(0xFF333333);
    const TextStyle headerStyle = TextStyle(
      color: darkGray,
      fontSize: 26,
      fontWeight: FontWeight.bold,
    );
    const TextStyle subTextStyle = TextStyle(
      color: darkGray,
      fontSize: 16,
      height: 1.5,
    );
    const TextStyle cardTitleStyle = TextStyle(
      color: darkGray,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );
    const TextStyle cardDescStyle = TextStyle(
      color: Colors.black87,
      fontSize: 14,
    );

    return Scaffold(
      backgroundColor: Color(0xFFFAF2DD),
      appBar: AppBar(
        title: const Text(
          "About Real Beez",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFAF2DD),
    
        iconTheme: const IconThemeData(color: darkGray),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Center(
              child: Image.asset(
                'assets/logo/logo.png',
                height: 200,
                width: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),

            // Header
            const Text("About Real Beez", style: headerStyle, ),
            const SizedBox(height: 10),

            // Mission Statement
            const Text(
              "Connecting people with their dream properties. Real Beez offers the fastest, most reliable property search and management experience for buyers, renters, and agents.",
              style: subTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Company Values Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Our Values",
                style: headerStyle.copyWith(fontSize: 22),
                
              ),
            ),
            const SizedBox(height: 15),

            _buildValueCard(
              icon: Icons.verified_user_outlined,
              title: "Trust and Transparency",
              description:
                  "We ensure honesty and openness in every interaction, helping you make informed real estate decisions.",
              honeyYellow: AppColors.beeYellow,
            ),
            const SizedBox(height: 15),
            _buildValueCard(
              icon: Icons.lightbulb_outline,
              title: "Innovation",
              description:
                  "Leveraging modern technology to make your property search and management seamless and efficient.",
              honeyYellow: AppColors.beeYellow,
            ),
            const SizedBox(height: 15),
            _buildValueCard(
              icon: Icons.thumb_up_alt_outlined,
              title: "Customer Satisfaction",
              description:
                  "Our priority is to exceed customer expectations by providing reliable, personalized, and responsive service.",
              honeyYellow: AppColors.beeYellow,
            ),
            const SizedBox(height: 30),

            // Contact Info Card
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Contact Us", style: cardTitleStyle),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: AppColors.beeYellow, size: 22),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "123 Real Beez Street, Hyderabad, India",
                            style: cardDescStyle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.email_outlined,
                            color: AppColors.beeYellow, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          "support@realbeez.com",
                          style: cardDescStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined,
                            color:AppColors.beeYellow, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          "+91 98765 43210",
                          style: cardDescStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCard({
    required IconData icon,
    required String title,
    required String description,
    required Color honeyYellow,
  }) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: honeyYellow, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
