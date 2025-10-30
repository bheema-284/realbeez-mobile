import 'package:flutter/material.dart';
import 'package:real_beez/utils/app_colors.dart';

class RealbeeMarathonApp extends StatelessWidget {
  const RealbeeMarathonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RealbeeMarathonScreen(),
    );
  }
}

class RealbeeMarathonScreen extends StatefulWidget {
  const RealbeeMarathonScreen({super.key});

  @override
  State<RealbeeMarathonScreen> createState() => _RealbeeMarathonScreenState();
}

class _RealbeeMarathonScreenState extends State<RealbeeMarathonScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Fast blink speed
    )..repeat(reverse: true);

    // Completely disappear to fully visible
    _opacityAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color darkGrey = Color(0xFF333333);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Column(
                children: [
                  Image.asset('assets/logo/logo.png', height: 48),
                  const SizedBox(height: 4),
                  const Text(
                    "Presents",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Title
              Column(
                children: const [
                  Text(
                    "WORLD’S FIRST EVER",
                    style: TextStyle(
                      color: AppColors.beeYellow,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "REAL ESTATE",
                    style: TextStyle(
                      color: AppColors.beeYellow,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    "MARATHON",
                    style: TextStyle(
                      color: AppColors.beeYellow,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Illustration
              Image.asset(
                'assets/images/marathon.png',
                height: 180,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 32),

              // Registration Button with blinking text
              SizedBox(
                width: 400,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.beeYellow,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                    // ignore: deprecated_member_use
                    shadowColor: AppColors.beeYellow.withOpacity(0.3),
                  ),
                  onPressed: () {
                    // Navigate to registration page
                  },
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: const Text(
                      "Click here for Registration",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Sponsors Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.remove,
                    color: AppColors.beeYellow,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Sponsors",
                    style: TextStyle(
                      color: darkGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.remove,
                    color: AppColors.beeYellow,
                    size: 18,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Sponsors grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  final logos = [
                    'assets/images/provincia.png',
                    'assets/images/sattva.png',
                    'assets/images/prestige.png',
                    'assets/images/lodha.png',
                    'assets/images/aparna.png',
                    'assets/images/my_home.png',
                    'assets/images/home.png',
                    'assets/images/smr.png',
                  ];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFF5F5F8),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Image.asset(
                        logos[index],
                        height: 50,
                        width: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
