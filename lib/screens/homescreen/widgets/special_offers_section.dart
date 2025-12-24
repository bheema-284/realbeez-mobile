import 'dart:async';
import 'package:flutter/material.dart';
import 'package:real_beez/property_cards.dart';
import 'package:real_beez/utils/app_colors.dart';

class SpecialOffersSection extends StatefulWidget {
  final int currentSpecialOfferPage;
  final ValueChanged<int> onPageChanged;
  final GlobalKey dotsKey;  // 🔥 PATCH 3: Added this field

  const SpecialOffersSection({
    super.key,
    required this.currentSpecialOfferPage,
    required this.onPageChanged,
    required this.dotsKey,  // 🔥 PATCH 3: Added this parameter
  });

  @override
  // ignore: library_private_types_in_public_api
  _SpecialOffersSectionState createState() => _SpecialOffersSectionState();
}

class _SpecialOffersSectionState extends State<SpecialOffersSection> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  bool _isAutoPlaying = true;
  Timer? _autoPlayTimer;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentSpecialOfferPage;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isInitialized = true;
      _scrollController.addListener(_onScroll);
      _startAutoPlay();
    });
  }

  @override
  void didUpdateWidget(SpecialOffersSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If parent updated the page (from auto-play), sync with scroll
    if (widget.currentSpecialOfferPage != _currentPage && 
        widget.currentSpecialOfferPage != oldWidget.currentSpecialOfferPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isInitialized) {
          _scrollToPage(widget.currentSpecialOfferPage, notifyParent: false);
        }
      });
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel(); // Cancel any existing timer first
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _isAutoPlaying && _isInitialized) {
        final nextPage = (_currentPage + 1) % PropertyData.specialOffers.length;
        _scrollToPage(nextPage);
      }
    });
  }

  void _scrollToPage(int page, {bool notifyParent = true}) {
    if (!_scrollController.hasClients || !mounted || !_isInitialized) return;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.48;
    const spacing = 8.0;
    const leftPadding = 4.0;
    
    final scrollOffset = (cardWidth + spacing) * page + leftPadding;
    
    // SLOWER ANIMATION DURATION - Changed from 500ms to 1000ms (1 second)
    _scrollController.animateTo(
      scrollOffset,
      duration: const Duration(milliseconds: 1000), // <-- SLOWER HERE
      curve: Curves.easeInOut,
    );
    
    // Update local state
    if (mounted) {
      setState(() {
        _currentPage = page;
      });
    }
    
    // Notify parent if needed
    if (notifyParent) {
      widget.onPageChanged(page);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || 
        !_scrollController.position.hasContentDimensions ||
        !_isInitialized) {
      return;
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.48;
    const spacing = 8.0;
    
    final scrollOffset = _scrollController.offset;
    final estimatedPage = (scrollOffset / (cardWidth + spacing)).round();
    
    // Only update if page actually changed
    if (estimatedPage != _currentPage) {
      _currentPage = estimatedPage.clamp(0, PropertyData.specialOffers.length - 1);
      
      // Delay setState to avoid build conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
      
      // Notify parent
      widget.onPageChanged(_currentPage);
    }
  }

  void _onDragStart(DragStartDetails details) {
    _isAutoPlaying = false;
    _autoPlayTimer?.cancel();
  }

  void _onDragEnd(DragEndDetails details) {
    // Restart auto-play after 3 seconds of inactivity
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isInitialized) {
        _isAutoPlaying = true;
        _startAutoPlay();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.48;
    
    return SizedBox(
      height: 184,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragEnd: _onDragEnd,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: PropertyData.specialOffers.length,
                itemBuilder: (context, index) {
                  final offer = PropertyData.specialOffers[index];
                  return Container(
                    width: cardWidth,
                    margin: const EdgeInsets.only(right: 8, left: 4),
                    child: _buildOfferCard(
                      imageUrl: offer['image']!,
                      title: offer['title']!,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            key: widget.dotsKey,    // 🔥 PATCH 4: Added this
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              PropertyData.specialOffers.length,
              (index) => GestureDetector(
                onTap: () {
                  _scrollToPage(index);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard({required String imageUrl, required String title}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: imageUrl.startsWith('assets/')
                ? Image.asset(
                    imageUrl,
                    height: 90,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    imageUrl,
                    height: 90,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "More Details:",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.beeYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(0, 24),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Unlock the offer",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}