import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

const Color kBackground = Color(0xFFF8F3E7);
const Color kGoldTop = Color(0xFFD7A44B);
const Color kGoldBottom = Color(0xFF876E3B);
const Color kGoldText = Color(0xFFD7A44B);
const double kPagePadding = 16.0;
const double kAppBarAvatarSize = 44.0;
const double kBackIconSize = 24.0;
const double kCardCornerRadius = 22.0;
const double kVideoCornerRadius = 15.0;
const double kPlayCircleRadius = 28.0;
const double kMinTapSize = 44.0;

class PremiumPlanScreen extends StatefulWidget {
  const PremiumPlanScreen({super.key});

  @override
  State<PremiumPlanScreen> createState() => _PremiumPlanScreenState();
}

class _PremiumPlanScreenState extends State<PremiumPlanScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/videos/real_estate.mp4')
      ..initialize().then((_) {
        setState(() {}); // refresh after initialization
      });

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double videoHeight = 180.0;
    final double videoWidth = 380.0; // reduced width for better fit
    final double cardWidth = videoWidth; // match video width

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kPagePadding),
          child: Column(
            children: [
              _buildTopBar(context),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            'Watch Our Video about Premium plan and Services',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // 🎬 Video Player (centered)
                        Center(
                          child: _buildVideoPlayer(
                            width: videoWidth,
                            height: videoHeight,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'About Plans',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 22),

                        Center(
                          child: Container(
                            width: cardWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                kCardCornerRadius,
                              ),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [kGoldTop, kGoldBottom],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 18),
                                const Text(
                                  'Premium Plan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Rs 499/- Life Time',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 18),

                                // Plan Features
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      _PlanBullet(
                                        text: 'Access to Services',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      SizedBox(height: 12),
                                      _PlanBullet(
                                        text: 'You will get One Lead',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      SizedBox(height: 12),
                                      _PlanBullet(
                                        text:
                                            'You can Add Your property Listing',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Subscribe Button
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 24.0,
                                    ),
                                    child: SizedBox(
                                      width: cardWidth * 0.5,
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Subscribe tapped!',
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Text(
                                          'Subscribe',
                                          style: TextStyle(
                                            color: kGoldText,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: kMinTapSize,
              minHeight: kMinTapSize,
            ),
            alignment: Alignment.centerLeft,
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: kBackIconSize,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer({required double width, required double height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(kVideoCornerRadius),
      child: Container(
        width: width,
        height: height,
        color: Colors.black12,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_controller.value.isInitialized)
              SizedBox(
                width: width,
                height: height,
                child: FittedBox(
                  fit: BoxFit.cover, // ensures video fills the container
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            else
              const Center(child: CircularProgressIndicator(color: kGoldText)),
            // Play/Pause overlay
            if (_controller.value.isInitialized)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                  child: Container(
                    width: kPlayCircleRadius * 2,
                    height: kPlayCircleRadius * 2,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlanBullet extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  const _PlanBullet({
    required this.text,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w400,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // shrink row to fit content
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
