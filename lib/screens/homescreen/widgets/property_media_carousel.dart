import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:real_beez/utils/app_colors.dart';

class PropertyMediaCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> mediaItems;
  final double height;

  const PropertyMediaCarousel({
    Key? key,
    required this.mediaItems,
    required this.height,
  }) : super(key: key);

  @override
  _PropertyMediaCarouselState createState() => _PropertyMediaCarouselState();
}

class _PropertyMediaCarouselState extends State<PropertyMediaCarousel> {
  int _currentIndex = 0;
  late PageController _pageController;
  Map<int, VideoPlayerController> _videoControllers = {};
  Map<int, ChewieController> _chewieControllers = {};
  Timer? _autoPlayTimer;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeVideos();
    _startAutoPlay();
  }

  void _initializeVideos() async {
    for (int i = 0; i < widget.mediaItems.length; i++) {
      final item = widget.mediaItems[i];
      if (item.containsKey('video')) {
        final videoUrl = item['video'];
        if (videoUrl != null && videoUrl.isNotEmpty) {
          final videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
          try {
            await videoController.initialize();
            if (!mounted) return;
            final chewieController = ChewieController(
              videoPlayerController: videoController,
              autoPlay: false,
              looping: true,
              allowFullScreen: false,
              showControls: false,
              aspectRatio: videoController.value.isInitialized
                  ? videoController.value.aspectRatio
                  : 16 / 9,
            );
            setState(() {
              _videoControllers[i] = videoController;
              _chewieControllers[i] = chewieController;
            });
          } catch (e) {
            debugPrint('❌ Video init error for item $i: $e');
          }
        }
      }
    }
  }

  void _playCurrentVideo() {
    final controller = _videoControllers[_currentIndex];
    final chewie = _chewieControllers[_currentIndex];
    if (controller != null &&
        chewie != null &&
        controller.value.isInitialized &&
        !controller.value.isPlaying) {
      _pauseAllVideos();
      controller.play();
      chewie.play();
      setState(() {
        _isVideoPlaying = true;
      });
    }
  }

  void _pauseAllVideos() {
    _videoControllers.forEach((key, c) {
      if (c.value.isPlaying) c.pause();
    });
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (widget.mediaItems.length > 1 && !_isVideoPlaying) {
      _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_pageController.hasClients && mounted && !_isVideoPlaying) {
          final nextPage = (_currentIndex + 1) % widget.mediaItems.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn,
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
    _chewieControllers.forEach((_, c) => c.dispose());
    _videoControllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
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
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) _playCurrentVideo();
                  });
                } else {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) _startAutoPlay();
                  });
                }
              },
              itemBuilder: (context, index) {
                final media = widget.mediaItems[index];
                if (media.containsKey('video') && media['video'] != null) {
                  final chewie = _chewieControllers[index];
                  return _buildVideoItem(chewie);
                } else {
                  return _buildImageItem(media);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoItem(ChewieController? chewieController) {
    return Container(
      color: Colors.black,
      child: chewieController != null
          ? Chewie(controller: chewieController)
          : const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.beeYellow),
              ),
            ),
    );
  }

  Widget _buildImageItem(Map<String, dynamic> media) {
    return Container(
      color: Colors.grey[200],
      child: media['image'] != null
          ? Image.asset(media['image'], fit: BoxFit.cover)
          : const Icon(Icons.image, color: Colors.grey),
    );
  }
}