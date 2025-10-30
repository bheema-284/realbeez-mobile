import 'package:flutter/material.dart';
import 'package:real_beez/screens/landing_pages/flash_screen_aadhar.dart';
import 'package:real_beez/screens/landing_pages/login_screen.dart';
import 'package:real_beez/screens/forms/common_button.dart';
import '../../utils/app_colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Hexagon section - Fixed height
              SizedBox(
                height: screenHeight * 0.35,
                child: const ImageSwitchingHexagonLayout(
                  images: [
                    'assets/images/Polygon1.png',
                    'assets/images/Polygon2.png',
                    'assets/images/Polygon3.png',
                    'assets/images/Polygon4.png',
                    'assets/images/Polygon5.png',
                    'assets/images/Polygon6.png',
                  ],
                ),
              ),

              // Logo section - Fixed height
              SizedBox(
                height: screenHeight * 0.1,
                child: Center(
                  child: Image.asset(
                    'assets/logo/logo.png',
                    width: 300,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Spacer to push button to bottom
              const Spacer(),

              // Button section - Fixed height
              SizedBox(
                height: screenHeight * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Aadhar Card Login Button
                    CommonButton(
                      text: "Log in with Aadhar card",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AadhaarLoginScreen(),
                          ),
                        );
                      },
                      backgroundColor: AppColors.beeYellow,
                      textColor: AppColors.white,
                    ),
                    const SizedBox(height: 16),

                    // "Or" divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.grey[400], thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Or",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey[400], thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Phone Number Login Button
                    CommonButton(
                      text: "Log in with Phone Number",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterNumberScreen(),
                          ),
                        );
                      },
                      backgroundColor: AppColors.white,
                      textColor: AppColors
                          .beeYellow, // You might need to adjust this color
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Image Switching Hexagon Layout
class ImageSwitchingHexagonLayout extends StatefulWidget {
  final List<String> images;

  const ImageSwitchingHexagonLayout({super.key, required this.images});

  @override
  State<ImageSwitchingHexagonLayout> createState() =>
      _ImageSwitchingHexagonLayoutState();
}

class _ImageSwitchingHexagonLayoutState
    extends State<ImageSwitchingHexagonLayout>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentCycle = 0;
  final int _totalCycles = 6; // Number of switching cycles

  // Define the switching patterns for each cycle
  final List<List<int>> _switchingPatterns = [
    [0, 1, 2, 3, 4, 5], // Original positions
    [1, 2, 3, 4, 5, 0], // Shift right
    [3, 4, 5, 0, 1, 2], // Swap top and bottom rows
    [5, 0, 1, 2, 3, 4], // Shift left
    [2, 3, 4, 5, 0, 1], // Rotate clockwise
    [4, 5, 0, 1, 2, 3], // Rotate counter-clockwise
  ];

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              // Move to next cycle when animation completes
              _switchToNextCycle();
            }
          });

    // Start the animation
    _startAnimation();
  }

  void _startAnimation() {
    _controller.forward(from: 0.0);
  }

  void _switchToNextCycle() {
    setState(() {
      _currentCycle = (_currentCycle + 1) % _totalCycles;
    });

    // Restart animation after a brief pause
    Future.delayed(const Duration(milliseconds: 500), () {
      _controller.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double hexagonSize = screenWidth * 0.12;
    final double horizontalSpacing = hexagonSize * 0.1;

    // Get current and next image indices
    final List<int> currentIndices = _switchingPatterns[_currentCycle];
    final List<int> nextIndices =
        _switchingPatterns[(_currentCycle + 1) % _totalCycles];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // First row - 1 hexagon
            _buildSwitchingHexagon(
              widget.images[currentIndices[0]],
              widget.images[nextIndices[0]],
              hexagonSize,
              _controller.value,
              0,
            ),

            SizedBox(height: hexagonSize * 0.1),

            // Second row - 2 hexagons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSwitchingHexagon(
                  widget.images[currentIndices[1]],
                  widget.images[nextIndices[1]],
                  hexagonSize,
                  _controller.value,
                  1,
                ),
                SizedBox(width: horizontalSpacing),
                _buildSwitchingHexagon(
                  widget.images[currentIndices[2]],
                  widget.images[nextIndices[2]],
                  hexagonSize,
                  _controller.value,
                  2,
                ),
              ],
            ),

            SizedBox(height: hexagonSize * 0.1),

            // Third row - 3 hexagons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSwitchingHexagon(
                  widget.images[currentIndices[3]],
                  widget.images[nextIndices[3]],
                  hexagonSize,
                  _controller.value,
                  3,
                ),
                SizedBox(width: horizontalSpacing),
                _buildSwitchingHexagon(
                  widget.images[currentIndices[4]],
                  widget.images[nextIndices[4]],
                  hexagonSize,
                  _controller.value,
                  4,
                ),
                SizedBox(width: horizontalSpacing),
                _buildSwitchingHexagon(
                  widget.images[currentIndices[5]],
                  widget.images[nextIndices[5]],
                  hexagonSize,
                  _controller.value,
                  5,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSwitchingHexagon(
    String currentImage,
    String nextImage,
    double size,
    double animationValue,
    int position,
  ) {
    // Calculate positions for smooth transition
    final double currentOpacity = 1.0 - animationValue;
    final double nextOpacity = animationValue;

    // Add some scale effect during transition
    final double scale = 1.0 - (animationValue * 0.3 * (1.0 - animationValue));

    return Stack(
      children: [
        // Current image fading out
        Opacity(
          opacity: currentOpacity,
          child: Transform.scale(
            scale: scale,
            child: _buildHexagon(currentImage, size),
          ),
        ),

        // Next image fading in
        Opacity(
          opacity: nextOpacity,
          child: Transform.scale(
            scale: 0.7 + (animationValue * 0.3), // Scale from 0.7 to 1.0
            child: _buildHexagon(nextImage, size),
          ),
        ),
      ],
    );
  }

  Widget _buildHexagon(String imagePath, double size) {
    return ClipPath(
      clipper: VerticalHexagonClipper(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: Icon(
                Icons.image,
                size: size * 0.5,
                color: Colors.grey[600],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Alternative: Circular Rotation Animation
class CircularRotationHexagonLayout extends StatefulWidget {
  final List<String> images;

  const CircularRotationHexagonLayout({super.key, required this.images});

  @override
  State<CircularRotationHexagonLayout> createState() =>
      _CircularRotationHexagonLayoutState();
}

class _CircularRotationHexagonLayoutState
    extends State<CircularRotationHexagonLayout>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _currentImages = [];

  @override
  void initState() {
    super.initState();
    _currentImages.addAll(widget.images);

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rotateImages() {
    setState(() {
      // Rotate images in a circular pattern
      final String temp = _currentImages[0];
      _currentImages[0] = _currentImages[1];
      _currentImages[1] = _currentImages[2];
      _currentImages[2] = _currentImages[5];
      _currentImages[5] = _currentImages[4];
      _currentImages[4] = _currentImages[3];
      _currentImages[3] = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double hexagonSize = screenWidth * 0.12;
    final double horizontalSpacing = hexagonSize * 0.1;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Rotate images every 0.5 seconds
        if (_controller.value % 0.166 < 0.01) {
          // 6 rotations per cycle (3 seconds / 6 = 0.5s each)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _rotateImages();
          });
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // First row - 1 hexagon
            _buildHexagon(_currentImages[0], hexagonSize),

            SizedBox(height: hexagonSize * 0.1),

            // Second row - 2 hexagons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHexagon(_currentImages[1], hexagonSize),
                SizedBox(width: horizontalSpacing),
                _buildHexagon(_currentImages[2], hexagonSize),
              ],
            ),

            SizedBox(height: hexagonSize * 0.1),

            // Third row - 3 hexagons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHexagon(_currentImages[3], hexagonSize),
                SizedBox(width: horizontalSpacing),
                _buildHexagon(_currentImages[4], hexagonSize),
                SizedBox(width: horizontalSpacing),
                _buildHexagon(_currentImages[5], hexagonSize),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildHexagon(String imagePath, double size) {
    return ClipPath(
      clipper: VerticalHexagonClipper(),
      child: Container(
        width: size,
        height: size,
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: Icon(
                Icons.image,
                size: size * 0.5,
                color: Colors.grey[600],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Vertical Hexagon Clipper (flat sides on top and bottom)
class VerticalHexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;

    return Path()
      ..moveTo(w * 0.5, 0) // Start at top center
      ..lineTo(w, h * 0.25) // Right top
      ..lineTo(w, h * 0.75) // Right bottom
      ..lineTo(w * 0.5, h) // Bottom center
      ..lineTo(0, h * 0.75) // Left bottom
      ..lineTo(0, h * 0.25) // Left top
      ..close(); // Back to top center
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
