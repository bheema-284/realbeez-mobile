import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_beez/screens/homescreen/property_details_screen.dart';
import 'package:real_beez/screens/models/wishlist_manager.dart';
import 'package:real_beez/screens/models/property.dart';
import 'package:real_beez/screens/repositories/property_repository.dart';

class PropertyDeckSection extends StatefulWidget {
  const PropertyDeckSection({super.key});

  @override
  State<PropertyDeckSection> createState() => _PropertyDeckSectionState();
}

class _PropertyDeckSectionState extends State<PropertyDeckSection> {
  final PropertyRepository _repository = const PropertyRepository();
  List<Property> properties = [];

  // New state variables for fan arrangement
  int centerIndex = 0;
  double _startDx = 0;
  double _currentDx = 0;
  static const double swipeThreshold = 30;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await _repository.loadProperties();
    if (!mounted) return;
    setState(() {
      properties = list;
    });
  }

  // Swipe navigation methods (from PokerFanMatched)
  void _next() {
    setState(() {
      centerIndex = (centerIndex + 1) % properties.length;
    });
  }

  void _previous() {
    setState(() {
      centerIndex = (centerIndex - 1 + properties.length) % properties.length;
    });
  }

  Property propertyAt(int offset) {
    final index =
        (centerIndex + offset + properties.length) % properties.length;
    return properties[index];
  }

  void _handleSwipeEnd() {
    final delta = _currentDx - _startDx;

    if (delta.abs() > swipeThreshold) {
      if (delta < 0) {
        // LEFT swipe → next
        _next();
      } else {
        // RIGHT swipe → previous
        _previous();
      }
    }

    _startDx = 0;
    _currentDx = 0;
  }

  void _onCardTap(int index) {
    if (index == 0) {
      _navigateToPropertyDetails(propertyAt(0));
      return;
    }

    setState(() {
      centerIndex = (centerIndex + index) % properties.length;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _navigateToPropertyDetails(propertyAt(0));
      }
    });
  }

  void _navigateToPropertyDetails(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PropertyDetailScreen(propertyId: property.id.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Center(
                child: Text(
                  "Featured Sites",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: SizedBox(
            // Significantly increased container size
            width: 340,
            height: 360,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                _startDx = event.position.dx;
              },
              onPointerMove: (event) {
                _currentDx = event.position.dx;
              },
              onPointerUp: (_) {
                _handleSwipeEnd();
              },
              child: _buildFanDeck(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFanDeck() {
    if (properties.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (properties.length >= 5) {
      return Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          _card(x: -78, y: 22, angle: -0.32, model: propertyAt(-2), index: -2),
          _card(x: -42, y: 12, angle: -0.18, model: propertyAt(-1), index: -1),
          _card(x: 78, y: 22, angle: 0.32, model: propertyAt(2), index: 2),
          _card(x: 42, y: 12, angle: 0.18, model: propertyAt(1), index: 1),
          _card(
            x: 0,
            y: 10,
            angle: 0,
            model: propertyAt(0),
            index: 0,
            isCenter: true,
          ),
        ],
      );
    } else {
      // Handle fewer properties gracefully
      final positions = _getPositionsForCount(properties.length);
      return Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: positions.map((pos) {
          return _card(
            x: pos.x,
            y: pos.y,
            angle: pos.angle,
            model: propertyAt(pos.index),
            index: pos.index,
            isCenter: pos.index == 0,
          );
        }).toList(),
      );
    }
  }

  Widget _card({
    required double x,
    required double y,
    required double angle,
    required Property model,
    required int index,
    bool isCenter = false,
  }) {
    // Significantly increased card dimensions
    final cardWidth = isCenter ? 230.0 : 215.0; // Increased
    final cardHeight = isCenter ? 250.0 : 210.0; // Increased

    return Positioned(
      left: 170 + x - (isCenter ? cardWidth / 2 : cardWidth / 2 - 4),
      top: 180 + y - (isCenter ? cardHeight / 2 : cardHeight / 2 - 4),
      child: GestureDetector(
        onTap: () => _onCardTap(index),
        child: Transform.rotate(
          angle: angle,
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  blurRadius: isCenter ? 16 : 8,
                  offset: const Offset(0, 8),
                  color: Colors.black38,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PropertyCard(
                property: model,
                width: cardWidth,
                height: cardHeight,
                isCenter: isCenter,
                onImageTap: () => _onCardTap(index),
                onDataPortionTap: () => _onCardTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for handling fewer cards
  List<_CardPosition> _getPositionsForCount(int count) {
    switch (count) {
      case 1:
        return [_CardPosition(0, 0, 0, 0)];
      case 2:
        return [
          _CardPosition(-1, -20, 12, -0.1),
          _CardPosition(0, 20, 12, 0.1),
        ];
      case 3:
        return [
          _CardPosition(-1, -40, 12, -0.15),
          _CardPosition(0, 0, 10, 0),
          _CardPosition(1, 40, 12, 0.15),
        ];
      case 4:
        return [
          _CardPosition(-2, -60, 20, -0.2),
          _CardPosition(-1, -30, 12, -0.1),
          _CardPosition(1, 30, 12, 0.1),
          _CardPosition(2, 60, 20, 0.2),
        ];
      default:
        return [
          _CardPosition(-2, -78, 22, -0.32),
          _CardPosition(-1, -42, 12, -0.18),
          _CardPosition(1, 42, 12, 0.18),
          _CardPosition(2, 78, 22, 0.32),
          _CardPosition(0, 0, 10, 0),
        ];
    }
  }
}

// Helper class for card positions
class _CardPosition {
  final int index;
  final double x;
  final double y;
  final double angle;

  _CardPosition(this.index, this.x, this.y, this.angle);
}

class PropertyCard extends StatelessWidget {
  final Property property;
  final double width;
  final double height;
  final VoidCallback? onImageTap;
  final VoidCallback? onDataPortionTap;
  final bool isCenter;

  const PropertyCard({
    super.key,
    required this.property,
    required this.width,
    required this.height,
    this.onImageTap,
    this.onDataPortionTap,
    this.isCenter = false,
  });

  bool get isNew => property.status == 'pre_launch';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Data section - DIFFERENT HEIGHTS FOR CENTER VS SIDE CARDS
          Container(
            height: isCenter
                ? height * 0.42
                : height * 0.44, // Different heights
            padding: EdgeInsets.fromLTRB(
              12,
              isCenter ? 12 : 10,
              12,
              isCenter ? 10 : 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title row with icons
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Property title
                          Text(
                            property.title,
                            style: TextStyle(
                              fontSize: isCenter ? 15 : 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          // Location - Using single line only
                          Text(
                            property.address.area,
                            style: TextStyle(
                              fontSize: isCenter ? 12 : 11,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Location icon and wishlist button in a row
                    Row(
                      children: [
                        // Location icon
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 3,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.orange,
                            size: isCenter ? 16 : 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Wishlist button
                        _AnimatedWishlistButton(
                          property: property,
                          isCenter: isCenter,
                        ),
                      ],
                    ),
                  ],
                ),
                // Price section - SIMPLIFIED LAYOUT
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Price starts from",
                      style: TextStyle(
                        fontSize: isCenter ? 12 : 10,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      _formatPrice(property.price, property.currency),
                      style: TextStyle(
                        fontSize: isCenter ? 15 : 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Divider line
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.grey[200],
          ),
          // Image section
          Expanded(
            child: GestureDetector(
              onTap: onImageTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: _buildImage(
                      property.images.isNotEmpty
                          ? property.images.first.url
                          : 'assets/images/swipe1.png',
                    ),
                  ),
                  if (isNew)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons/new.png',
                              width: isCenter ? 14 : 12,
                              height: isCenter ? 14 : 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "New",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: isCenter ? 10 : 9,
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
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image, color: Colors.grey, size: 40),
        ),
      );
    }
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.error, color: Colors.grey, size: 40),
            ),
          );
        },
      );
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.error, color: Colors.grey, size: 40),
            ),
          );
        },
      );
    }
  }

  static String _formatPrice(int price, String currency) {
    final symbol = currency == 'INR' ? '₹' : '';
    final str = price.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (i > 0 && ((count == 3) || (count > 3 && (count - 3) % 2 == 0))) {
        buffer.write(',');
      }
    }
    final formatted = buffer.toString().split('').reversed.join();
    return "$symbol$formatted";
  }
}

class _AnimatedWishlistButton extends StatefulWidget {
  final Property property;
  final bool isCenter;

  const _AnimatedWishlistButton({
    required this.property,
    this.isCenter = false,
  });

  @override
  State<_AnimatedWishlistButton> createState() =>
      _AnimatedWishlistButtonState();
}

class _AnimatedWishlistButtonState extends State<_AnimatedWishlistButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool isWishlisted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }

  void _onTap() async {
    HapticFeedback.heavyImpact();

    setState(() {
      isWishlisted = !isWishlisted;
    });

    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.forward();

    if (isWishlisted) {
      WishlistManager().addToWishlist(widget.property);
    } else {
      WishlistManager().removeFromWishlist(widget.property);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            isWishlisted ? Icons.favorite : Icons.favorite_border,
            color: isWishlisted ? Colors.redAccent : Colors.orange,
            size: widget.isCenter ? 16 : 14,
          ),
        ),
      ),
    );
  }
}

class AnimatedCompassIcon extends StatefulWidget {
  const AnimatedCompassIcon({super.key});

  @override
  State<AnimatedCompassIcon> createState() => _AnimatedCompassIconState();
}

class _AnimatedCompassIconState extends State<AnimatedCompassIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(Icons.explore, color: Colors.white, size: 22),
    );
  }
}
