import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:real_beez/utils/app_colors.dart';
import 'package:real_beez/utils/screen_util_helper.dart';

class PropertyCard extends StatefulWidget {
  final String propertyId; // ✅ Added propertyId parameter
  final List<Map<String, dynamic>> mediaItems;
  final String title;
  final String location;
  final String description;
  final String priceRange;
  final String tagText;
  final double rating;
  final String distance;
  final bool isNew;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onTap; // ✅ Added onTap callback for navigation

  const PropertyCard({
    super.key,
    required this.propertyId, // ✅ Required propertyId
    required this.mediaItems,
    required this.title,
    required this.location,
    required this.description,
    required this.priceRange,
    this.tagText = "",
    this.rating = 0.0,
    this.distance = "",
    this.isNew = false,
    this.onFavoriteTap,
    this.onLocationTap,
    this.onTap, // ✅ Optional onTap callback
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _carouselTimer;
  Map<int, VideoPlayerController?> _videoControllers = {};
  Map<int, ChewieController?> _chewieControllers = {};
  bool _isVideoPlaying = false;
  bool _isWishlisted = false; // ✅ For toggling heart icon

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeVideos();

    if (widget.mediaItems.isNotEmpty && widget.mediaItems.length > 1) {
      _startAutoPlay();
    }
  }

  void _initializeVideos() async {
  // 🟡 Load videos one by one instead of all together
  for (int i = 0; i < widget.mediaItems.length; i++) {
    final item = widget.mediaItems[i];
    if (_isVideoItem(i)) {
      final videoUrl = item['video'];
      try {
        debugPrint('🎥 Initializing video at index $i: $videoUrl');

        // ✅ Initialize with timeout protection (10 seconds)
        final videoController = VideoPlayerController.network(videoUrl);
        await videoController.initialize().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('⏰ Timeout loading video index $i');
            videoController.dispose();
            throw TimeoutException('Video loading timed out');
          },
        );

        if (mounted) {
          final chewieController = ChewieController(
            videoPlayerController: videoController,
            autoPlay: true,
            looping: true,
            allowFullScreen: false,
            showControls: false,
            allowMuting: false,
            allowPlaybackSpeedChanging: false,
            aspectRatio: videoController.value.aspectRatio,
            errorBuilder: (context, errorMessage) {
              return _buildVideoErrorState();
            },
          );

          setState(() {
            _videoControllers[i] = videoController;
            _chewieControllers[i] = chewieController;
          });
        }

        debugPrint('✅ Video $i initialized successfully');
      } catch (e) {
        // 🚨 Catch timeout, network, or invalid URL errors
        debugPrint('❌ Video initialization error at index $i: $e');
        if (mounted) {
          setState(() {
            _videoControllers[i] = null;
            _chewieControllers[i] = null;
          });
        }
      }
    }
  }
}

  Widget _buildVideoErrorState() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=1000&q=80',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: Colors.black54),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.videocam_off, color: Colors.white54, size: 40),
                SizedBox(height: 8),
                Text(
                  'Drone view unavailable',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  'Showing property images instead',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _playCurrentVideo() {
    final videoController = _videoControllers[_currentPage];
    final chewieController = _chewieControllers[_currentPage];

    if (videoController != null &&
        chewieController != null &&
        videoController.value.isInitialized &&
        !videoController.value.isPlaying) {
      _pauseAllVideos();
      videoController.play();
      setState(() {
        _isVideoPlaying = true;
      });
    }
  }

  void _pauseAllVideos() {
    _videoControllers.forEach((index, controller) {
      if (controller != null && controller.value.isPlaying) {
        controller.pause();
      }
    });
    setState(() {
      _isVideoPlaying = false;
    });
  }

  void _startAutoPlay() {
    _carouselTimer?.cancel();
    if (widget.mediaItems.isNotEmpty &&
        widget.mediaItems.length > 1 &&
        !_isVideoPlaying) {
      _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_pageController.hasClients && mounted && !_isVideoPlaying) {
          final nextPage = (_currentPage + 1) % widget.mediaItems.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _stopAutoPlay() {
    _carouselTimer?.cancel();
    _carouselTimer = null;
  }

  bool _isVideoItem(int index) {
    if (index >= widget.mediaItems.length) return false;
    return widget.mediaItems[index].containsKey('video') &&
        widget.mediaItems[index]['video'] != null &&
        widget.mediaItems[index]['video'].toString().isNotEmpty;
  }

  bool _isImageItem(int index) {
    if (index >= widget.mediaItems.length) return false;
    return widget.mediaItems[index].containsKey('image') &&
        widget.mediaItems[index]['image'] != null &&
        widget.mediaItems[index]['image'].toString().isNotEmpty;
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    _chewieControllers.forEach((_, controller) => controller?.dispose());
    _videoControllers.forEach((_, controller) => controller?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomMargin = ScreenUtilHelper.getSafeHeight(18);
    final double mediaHeight = ScreenUtilHelper.getSafeHeight(270);
    final double tagBottomPosition = ScreenUtilHelper.getSafeHeight(50);
    final hasMedia = widget.mediaItems.isNotEmpty;

    return GestureDetector(
      onTap: () {
        // ✅ Trigger the onTap callback when the card is tapped
        widget.onTap?.call();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: bottomMargin),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ScreenUtilHelper.getSafeRadius(10)),
          child: Stack(
            children: [
              SizedBox(
                height: mediaHeight,
                width: double.infinity,
                child: hasMedia ? _buildMediaCarousel() : _buildPlaceholder(),
              ),
              Positioned(
                top: ScreenUtilHelper.getSafeHeight(10),
                right: ScreenUtilHelper.getSafeWidth(10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onLocationTap,
                      child: Container(
                        margin: EdgeInsets.only(right: ScreenUtilHelper.getSafeWidth(8)),
                        padding: EdgeInsets.all(ScreenUtilHelper.getSafeWidth(4)),
                        decoration: const BoxDecoration(
                          color: AppColors.beeYellow,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: ScreenUtilHelper.getSafeFontSize(22), 
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _isWishlisted = !_isWishlisted);
                        widget.onFavoriteTap?.call();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(ScreenUtilHelper.getSafeWidth(4)),
                        decoration: const BoxDecoration(
                          color: AppColors.beeYellow, 
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: _isWishlisted
                              ? Colors.red 
                              : Colors.white, 
                          size: ScreenUtilHelper.getSafeFontSize(22), 
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.tagText.isNotEmpty)
                Positioned(
                  bottom: tagBottomPosition,
                  left: ScreenUtilHelper.getSafeWidth(2),
                  child: Container(
                    width: ScreenUtilHelper.getSafeWidth(220),
                    margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtilHelper.getSafeWidth(1),
                        vertical: ScreenUtilHelper.getSafeHeight(16)),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtilHelper.getSafeWidth(8),
                        vertical: ScreenUtilHelper.getSafeHeight(4)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ScreenUtilHelper.getSafeRadius(10)),
                        topRight: Radius.circular(ScreenUtilHelper.getSafeRadius(10)),
                        bottomRight: Radius.circular(ScreenUtilHelper.getSafeRadius(10)),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.beeYellow.withOpacity(0.95),
                          AppColors.beeYellow.withOpacity(0.8),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: ScreenUtilHelper.getSafeRadius(3),
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.tagText,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: ScreenUtilHelper.getSafeFontSize(10),
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),

              if (widget.isNew)
                Positioned(
                  top: ScreenUtilHelper.getSafeHeight(10),
                  left: ScreenUtilHelper.getSafeWidth(10),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtilHelper.getSafeWidth(4),
                        vertical: ScreenUtilHelper.getSafeHeight(4)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(ScreenUtilHelper.getSafeRadius(5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded,
                            color: Colors.green,
                            size: ScreenUtilHelper.getSafeFontSize(16)),
                        SizedBox(width: ScreenUtilHelper.getSafeWidth(4)),
                        Text(
                          "New",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: ScreenUtilHelper.getSafeFontSize(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              _buildInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(Icons.photo, size: 40, color: Colors.grey[500]),
      ),
    );
  }

  Widget _buildMediaCarousel() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.mediaItems.length,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
          _isVideoPlaying = false;
        });

        _stopAutoPlay();
        _pauseAllVideos();

        if (_isVideoItem(index)) {
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
        if (_isVideoItem(index)) {
          return _buildVideoItem(index);
        } else if (_isImageItem(index)) {
          return _buildImageItem(index);
        } else {
          return _buildPlaceholder();
        }
      },
    );
  }

  Widget _buildVideoItem(int index) {
    final chewieController = _chewieControllers[index];
    if (chewieController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final aspectRatio = chewieController.videoPlayerController.value.isInitialized
        ? chewieController.videoPlayerController.value.aspectRatio
        : 16 / 9;

    return ClipRRect(
      borderRadius: BorderRadius.circular(ScreenUtilHelper.getSafeRadius(10)),
      child: Container(
        color: Colors.black,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: chewieController.videoPlayerController.value.size.width,
            height: chewieController.videoPlayerController.value.size.height,
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Chewie(controller: chewieController),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageItem(int index) {
    final imageUrl = widget.mediaItems[index]['image'];
    return ClipRRect(
      borderRadius: BorderRadius.circular(ScreenUtilHelper.getSafeRadius(10)),
      child: Image.network(
        imageUrl ?? '',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 30),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: ScreenUtilHelper.getSafeWidth(3),
            vertical: ScreenUtilHelper.getSafeHeight(4)),
        padding: EdgeInsets.symmetric(
            horizontal: ScreenUtilHelper.getSafeWidth(8),
            vertical: ScreenUtilHelper.getSafeHeight(6)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(ScreenUtilHelper.getSafeRadius(10)),
            bottomLeft: Radius.circular(ScreenUtilHelper.getSafeRadius(10)),
            bottomRight: Radius.circular(ScreenUtilHelper.getSafeRadius(10)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: ScreenUtilHelper.getSafeRadius(6),
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: ScreenUtilHelper.getSafeFontSize(12),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtilHelper.getSafeWidth(6),
                          vertical: ScreenUtilHelper.getSafeHeight(4)),
                      decoration: BoxDecoration(
                        color: AppColors.beeYellow,
                        borderRadius: BorderRadius.circular(
                            ScreenUtilHelper.getSafeRadius(5)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            widget.rating.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize:
                                  ScreenUtilHelper.getSafeFontSize(9),
                            ),
                          ),
                          Icon(Icons.star_rounded,
                              size: ScreenUtilHelper.getSafeFontSize(10),
                              color: Colors.white),
                        ],
                      ),
                    ),
                    SizedBox(width: ScreenUtilHelper.getSafeWidth(4)),
                    Text(widget.distance,
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: ScreenUtilHelper.getSafeFontSize(9))),
                  ],
                ),
              ],
            ),
            SizedBox(height: ScreenUtilHelper.getSafeHeight(2)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.location,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize:
                                  ScreenUtilHelper.getSafeFontSize(9))),
                      SizedBox(height: ScreenUtilHelper.getSafeHeight(2)),
                      Text(widget.description,
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize:
                                  ScreenUtilHelper.getSafeFontSize(9))),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Price range",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize:
                                  ScreenUtilHelper.getSafeFontSize(9))),
                      Text(widget.priceRange,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  ScreenUtilHelper.getSafeFontSize(11),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}