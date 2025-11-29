import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:real_beez/utils/app_colors.dart';

class PropertyMediaCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> mediaItems;
  final double height;

  const PropertyMediaCarousel({
    super.key,
    required this.mediaItems,
    required this.height,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PropertyMediaCarouselState createState() => _PropertyMediaCarouselState();
}

class _PropertyMediaCarouselState extends State<PropertyMediaCarousel> {
  int _currentIndex = 0;
  late PageController _pageController;
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, ChewieController> _chewieControllers = {};
  Timer? _autoPlayTimer;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeVideos();
    _startAutoPlay();
  }

  Future<void> _initializeVideos() async {
    for (int i = 0; i < widget.mediaItems.length; i++) {
      final item = widget.mediaItems[i];
      final videoUrl = item['video'];

      if (videoUrl != null && videoUrl.toString().isNotEmpty) {
        try {
          final videoController =
              VideoPlayerController.networkUrl(Uri.parse(videoUrl));
          await videoController.initialize();

          if (!mounted) return;

          final chewieController = ChewieController(
            videoPlayerController: videoController,
            autoPlay: false,
            looping: true,
            allowFullScreen: false,
            showControls: false,
            aspectRatio: videoController.value.aspectRatio,
          );

          setState(() {
            _videoControllers[i] = videoController;
            _chewieControllers[i] = chewieController;
          });
        } catch (e) {
          debugPrint("❌ Video init error for item $i: $e");
        }
      }
    }
  }

  void _playCurrentVideo() {
    final controller = _videoControllers[_currentIndex];
    if (controller != null && controller.value.isInitialized) {
      _pauseAllVideos();
      controller.play();
      setState(() => _isVideoPlaying = true);
    }
  }

  void _pauseAllVideos() {
    for (var c in _videoControllers.values) {
      if (c.value.isPlaying) c.pause();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (widget.mediaItems.length > 1 && !_isVideoPlaying) {
      _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (_pageController.hasClients && mounted && !_isVideoPlaying) {
          final nextPage = (_currentIndex + 1) % widget.mediaItems.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoPlayTimer?.cancel();
    for (var c in _chewieControllers.values) {
      c.dispose();
    }
    for (var c in _videoControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaItems.isEmpty) {
      return Container(
        height: widget.height,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.image, size: 40, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.mediaItems.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _isVideoPlaying = false;
          });
          _stopAutoPlay();
          _pauseAllVideos();
          if (widget.mediaItems[index].containsKey('video')) {
            Future.delayed(const Duration(milliseconds: 300), _playCurrentVideo);
          } else {
            Future.delayed(const Duration(milliseconds: 300), _startAutoPlay);
          }
        },
        itemBuilder: (context, index) {
          final media = widget.mediaItems[index];
          if (media.containsKey('video') && media['video'] != null) {
            final controller = _videoControllers[index];
            if (controller != null && controller.value.isInitialized) {
              return AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: Chewie(controller: _chewieControllers[index]!),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.beeYellow),
                ),
              );
            }
          } else {
            final imageUrl = media['image'];
            return imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                    ),
                  )
                : const Icon(Icons.image, color: Colors.grey);
          }
        },
      ),
    );
  }
}
