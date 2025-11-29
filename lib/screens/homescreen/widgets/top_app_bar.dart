import 'package:flutter/material.dart';

class TopAppBar extends StatelessWidget {
  final bool shouldUseWhiteIcons;
  final bool isSmallScreen;
  final VoidCallback onProfileTap;
  final VoidCallback onWishlistTap;
  final VoidCallback onNotificationsTap;

  const TopAppBar({
    super.key,
    required this.shouldUseWhiteIcons,
    required this.isSmallScreen,
    required this.onProfileTap,
    required this.onWishlistTap,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.location_on,
                  color: shouldUseWhiteIcons ? Colors.white : Colors.black,
                  size: isSmallScreen ? 18 : 20),
              SizedBox(width: isSmallScreen ? 4 : 6),
              Text("Hyderabad, TG",
                  style: TextStyle(
                      color: shouldUseWhiteIcons ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 14 : 16)),
              Icon(Icons.arrow_drop_down,
                  color: shouldUseWhiteIcons ? Colors.white : Colors.black,
                  size: isSmallScreen ? 18 : 20),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onNotificationsTap,
                child: Stack(
                  children: [
                    Icon(Icons.notifications,
                        color: shouldUseWhiteIcons ? Colors.white : Colors.black,
                        size: isSmallScreen ? 22 : 28),
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        child: Text("1",
                            style: TextStyle(fontSize: 8, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              GestureDetector(
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: isSmallScreen ? 14 : 18,
                  backgroundImage: AssetImage("assets/images/submit.png"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}