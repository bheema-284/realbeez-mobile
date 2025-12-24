import 'dart:async';
import 'package:flutter/material.dart';
import 'package:real_beez/utils/app_colors.dart';

class RecommendedSitesSection extends StatefulWidget {
  final List<Map<String, String>> recommendedSites;

  const RecommendedSitesSection({
    super.key,
    required this.recommendedSites,
  });

  @override
  // ignore: library_private_types_in_public_api
  _RecommendedSitesSectionState createState() => _RecommendedSitesSectionState();
}

class _RecommendedSitesSectionState extends State<RecommendedSitesSection> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  Timer? _autoPlayTimer;
  bool _isAutoPlaying = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoPlay();
    });
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _isAutoPlaying && _pageController.hasClients) {
        final nextPage = (_currentPage + 1) % widget.recommendedSites.length;
        
        // Animate to next page
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        
        // Update state AFTER animation completes
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _currentPage = nextPage;
            });
          }
        });
      }
    });
  }

  void _onPageChanged(int page) {
    // Update state when user scrolls
    setState(() {
      _currentPage = page;
    });
    
    // Pause auto-play on manual scroll
    if (_isAutoPlaying) {
      _isAutoPlaying = false;
      _autoPlayTimer?.cancel();
      
      // Restart auto-play after 5 seconds of inactivity
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          _isAutoPlaying = true;
          _startAutoPlay();
        }
      });
    }
  }

  void _onDotTap(int page) {
    // When user taps a dot, jump to that page
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
    
    // Update state
    setState(() {
      _currentPage = page;
    });
    
    // Pause and restart auto-play
    if (_isAutoPlaying) {
      _isAutoPlaying = false;
      _autoPlayTimer?.cancel();
      
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          _isAutoPlaying = true;
          _startAutoPlay();
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: isSmallScreen ? 48 : 52,
                height: isSmallScreen ? 48 : 52,
                child: Image.asset(
                  'assets/icons/design.png',
                  fit: BoxFit.contain,
                  color: AppColors.beeYellow,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.architecture,
                    color: AppColors.beeYellow,
                    size: isSmallScreen ? 42 : 46,
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 14),
              Text(
                'Recommended Sites',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 14),
              SizedBox(
                width: isSmallScreen ? 48 : 52,
                height: isSmallScreen ? 48 : 52,
                child: Image.asset(
                  'assets/icons/design.png',
                  fit: BoxFit.contain,
                  color: AppColors.beeYellow,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.construction,
                    color: AppColors.beeYellow,
                    size: isSmallScreen ? 42 : 46,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.recommendedSites.length,
              padEnds: false,
              clipBehavior: Clip.none,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final site = widget.recommendedSites[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          site['image']!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: _buildSaleBadge(site['sale']!),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            site['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.recommendedSites.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _onDotTap(entry.key),
                child: Container(
                  width: 6.0,
                  height: 6.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == entry.key
                        ? Colors.indigo
                        : Colors.indigo.shade200,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleBadge(String saleText) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.percent_rounded, 
                color: Colors.white, 
                size: 12,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Sale $saleText',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
}