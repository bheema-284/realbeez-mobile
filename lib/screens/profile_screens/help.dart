import 'package:flutter/material.dart';
import 'package:real_beez/utils/app_colors.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> faqs = [
    {
      "question": "How do I create an account?",
      "answer":
          "To create an account, tap on the Sign Up button on the home screen, fill in your personal details, and verify your email or phone number."
    },
    {
      "question": "How can I list my property on Real Beez?",
      "answer":
          "Go to the Partner section, click on 'List Property', and fill in the property details along with required documents."
    },
    {
      "question": "How do I reset my password?",
      "answer":
          "On the login page, select 'Forgot Password', then follow the instructions sent to your registered email address."
    },
    {
      "question": "How can I contact customer support?",
      "answer":
          "You can reach our support team via email, phone, or live chat. Details are available in the 'Contact Support' section below."
    },
    {
      "question": "Is my data secure with Real Beez?",
      "answer":
          "Yes. We use industry-standard encryption and security protocols to protect your data and privacy."
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color darkGray = Color(0xFF333333);
    const Color softGray = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: Color(0xFFFAF2DD),
      appBar: AppBar(
        title: const Text(
          "Help & Support",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
         backgroundColor: Color(0xFFFAF2DD),
        centerTitle: true,
      
        iconTheme: const IconThemeData(color: darkGray),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo at the top
            Center(
              child: Image.asset(
                'assets/logo/logo.png',
                height: 80,
              ),
            ),
            const SizedBox(height: 30),

            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search help topics...",
                prefixIcon: const Icon(Icons.search, color: darkGray),
                filled: true,
                fillColor: softGray,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // FAQ Section
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.beeYellow,
              ),
            ),
            const SizedBox(height: 10),
            ...faqs
                .map(
                  (faq) => _buildFaqCard(
                    faq['question']!,
                    faq['answer']!,
                    AppColors.beeYellow,
                    darkGray,
                  ),
                )
                ,

            const SizedBox(height: 30),

            // Contact Support Section
            const Text(
              "Contact Support",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.beeYellow,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              color: softGray,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildContactOption(
                      icon: Icons.phone,
                      label: "Call",
                      onTap: () {},
                      color: AppColors.beeYellow,
                      darkColor: darkGray,
                    ),
                    _buildContactOption(
                      icon: Icons.email,
                      label: "Email",
                      onTap: () {},
                      color: AppColors.beeYellow,
                      darkColor: darkGray,
                    ),
                    _buildContactOption(
                      icon: Icons.chat,
                      label: "Chat",
                      onTap: () {},
                      color: AppColors.beeYellow,
                      darkColor: darkGray,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Quick Guides Section
            const Text(
              "Quick Guides",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.beeYellow,
              ),
            ),
            const SizedBox(height: 10),
            _buildGuideItem(
              icon: Icons.search_rounded,
              title: "How to Search",
              subtitle: "Learn how to quickly find properties.",
              honeyYellow: AppColors.beeYellow,
            ),
            _buildGuideItem(
              icon: Icons.home_work_outlined,
              title: "Booking a Property",
              subtitle: "Understand the booking process step-by-step.",
              honeyYellow: AppColors.beeYellow,
            ),
            _buildGuideItem(
              icon: Icons.person_outline,
              title: "Managing Your Account",
              subtitle: "Learn how to edit your details and preferences.",
              honeyYellow: AppColors.beeYellow,
            ),

            const SizedBox(height: 40),

            // Footer
            Center(
              child: Column(
                children: [
                  const Divider(thickness: 1, color: softGray),
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/logo/logo.png',
                    height: 80,
                    width: 80,
                  ),
                
                  const Text(
                    "© 2025 Real Beez. All rights reserved.",
                    style: TextStyle(
                      color: Colors.grey,
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

  Widget _buildFaqCard(
      String question, String answer, Color honeyYellow, Color darkGray) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: honeyYellow,
          collapsedIconColor: honeyYellow,
          title: Text(
            question,
            style: TextStyle(
              color: darkGray,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            Text(
              answer,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required Color darkColor,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: darkColor, size: 26),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: darkColor,
          ),
        ),
      ],
    );
  }

  Widget _buildGuideItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color honeyYellow,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          // ignore: deprecated_member_use
          backgroundColor: honeyYellow.withOpacity(0.2),
          child: Icon(icon, color: honeyYellow),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.black87),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          
        },
      ),
    );
  }
}
