import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:real_beez/screens/landing_pages/onboarding_screen.dart';
import 'package:real_beez/screens/booking_screens/bookings_screen.dart';
import 'package:real_beez/screens/premium_screens/premium_plan.dart';
import 'package:real_beez/screens/profile_screens/about.dart';
import 'package:real_beez/screens/profile_screens/help.dart';
import 'package:real_beez/screens/profile_screens/my_bio_screen.dart';
import 'package:real_beez/screens/profile_screens/privacy_screen.dart';
import 'package:real_beez/utils/app_colors.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  static const Color backgroundColor = Color(0xFFF8F3E7);
  static const Color cardColor = Colors.white;
  static const Color chevronColor = Color(0xFFACB3B7);
  static const Color dividerColor = Color(0xFFF1F1EF);

  // ignore: library_private_types_in_public_api
  final List<_SettingItem> settingsItems = const [
    _SettingItem(label: 'Booking Details', icon: Icons.calendar_today, key: Key('booking')),
    _SettingItem(label: 'My Bio', icon: Icons.badge, key: Key('bio')),
    _SettingItem(label: 'Premium Plan Details', icon: Icons.stars, key: Key('premium')),
    _SettingItem(label: 'Privacy', icon: Icons.lock, key: Key('privacy')),
    _SettingItem(label: 'Help', icon: Icons.help_outline, key: Key('help')),
    _SettingItem(label: 'About', icon: Icons.info_outline, key: Key('about')),
  ];

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  _buildAppBar(context),
                  const SizedBox(height: 20),
                  _buildProfileSection(),
                  const SizedBox(height: 20),
                  _buildSettingsCard(context),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 32,
              child: _buildLogoutButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            key: const Key('back_arrow'),
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            tooltip: 'Back',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: const [
        CircleAvatar(
          radius: 32,
          backgroundImage: AssetImage('assets/images/car.png'),
        ),
        SizedBox(height: 10),
        Text(
          'Someone',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
          ),
          ...settingsItems.asMap().entries.map((entry) {
            int idx = entry.key;
            _SettingItem item = entry.value;
            return Column(
              children: [
                InkWell(
                  key: item.key,
                  onTap: () {
                    if (item.label == 'Booking Details') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const BookingScreen()));
                    } else if (item.label == 'My Bio') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBioScreen()));
                    } else if (item.label == 'About') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
                    } else if (item.label == 'Privacy') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                    } else if (item.label == 'Help') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
                    } else if (item.label == 'Premium Plan Details') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumPlanScreen()));
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  // ignore: deprecated_member_use
                  splashColor: AppColors.beeYellow.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration:
                              const BoxDecoration(color: AppColors.beeYellow, shape: BoxShape.circle),
                          child: Icon(item.icon, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(item.label,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black)),
                        ),
                        const Icon(Icons.chevron_right, color: chevronColor, size: 18),
                      ],
                    ),
                  ),
                ),
                if (idx != settingsItems.length - 1)
                  const Divider(color: dividerColor, height: 0.8),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        key: const Key('logout_button'),
        onPressed: () => _logout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.beeYellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

class _SettingItem {
  final String label;
  final IconData icon;
  final Key key;
  const _SettingItem({required this.label, required this.icon, required this.key});
}
