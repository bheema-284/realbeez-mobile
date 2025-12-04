import 'package:flutter/material.dart';
import 'package:real_beez/screens/map_screens/map_screen.dart';
import 'package:real_beez/utils/app_colors.dart';

class StickyMapButton extends StatelessWidget {
  const StickyMapButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const RealEstateHome(),
          ),
        );
      },
      child: Container(
        width: 75,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(61, 61, 61, 0.8),
              AppColors.beeYellow,
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(13),
            topRight: Radius.circular(13),
          
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 35,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(
                child: Image.asset(
                  "assets/icons/compass.png",
                  width: 36,
                  height: 36,
                ),
              ),
            ),
            
            const Text(
              "Maps",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
