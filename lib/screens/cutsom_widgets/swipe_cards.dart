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
  Offset _dragOffset = Offset.zero;
  int? _draggingIndex;

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

  void _onPanStart(int index, DragStartDetails details) {
    if (_draggingIndex != null) return;
    setState(() {
      _draggingIndex = index;
      _dragOffset = Offset.zero;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_draggingIndex == null) return;
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_draggingIndex == null) return;
    final screenHeight = MediaQuery.of(context).size.height;
    final shouldDismiss = _dragOffset.dy > screenHeight * 0.25;

    if (shouldDismiss) {
      setState(() {
        final removed = properties.removeAt(_draggingIndex!);
        properties.insert(0, removed);
        _draggingIndex = null;
        _dragOffset = Offset.zero;
      });
    } else {
      setState(() {
        _dragOffset = Offset.zero;
        _draggingIndex = null;
      });
    }
  }

  void _onImageTap(int index) {
    if (index == 0) {
      _navigateToPropertyDetails(properties[0]);
      return;
    }

    setState(() {
      final tappedProperty = properties.removeAt(index);
      properties.insert(0, tappedProperty);
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _navigateToPropertyDetails(properties[0]);
      }
    });
  }

  void _onDataPortionTap(int index) {
    if (index == 0) return;
    setState(() {
      final tappedProperty = properties.removeAt(index);
      properties.insert(0, tappedProperty);
    });
  }

  void _navigateToPropertyDetails(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(propertyId: property.id.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardW = 280.0;
    final cardH = 260.0;

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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
             
            ],
          ),
        ),
Center(
  child: SizedBox(
    width: cardW,
    height: cardH, // ← Remove the +60 extra height
    child: Stack(
      clipBehavior: Clip.none,
      children: _buildDeckWidgets(cardW, cardH),
    ),
  ),
),
      ],
    );
  }

  List<Widget> _buildDeckWidgets(double cardW, double cardH) {
    final widgets = <Widget>[];
    final count = properties.length;
    final mid = (count - 1) / 2.0;

    for (int i = 0; i < count; i++) {
      final rel = i - mid;
      final rotation = rel * 0.10;
      final translateX = rel * 24.0;
      final translateY = (rel.abs()) * 6.0;
      final scale = 1.0 - (rel.abs() * 0.03);

      Widget card = SizedBox(
        width: cardW,
        height: cardH,
        child: PropertyCard(
          property: properties[i],
          width: cardW,
          height: cardH,
          onImageTap: () => _onImageTap(i),
          onDataPortionTap: () => _onDataPortionTap(i),
        ),
      );

      if (_draggingIndex == i) {
        card = Transform.translate(
          offset: Offset(translateX + _dragOffset.dx, translateY + _dragOffset.dy),
          child: Transform.rotate(
            angle: rotation + (_dragOffset.dx * 0.001),
            child: Transform.scale(scale: scale, child: card),
          ),
        );
      } else {
        card = Transform.translate(
          offset: Offset(translateX, translateY),
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(scale: scale, child: card),
          ),
        );
      }

      card = GestureDetector(
        onPanStart: (d) => _onPanStart(i, d),
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onTap: () {
          if (i != 0) {
            setState(() {
              final tapped = properties.removeAt(i);
              properties.insert(0, tapped);
            });
          }
        },
        child: card,
      );

      widgets.add(card);
    }

    return widgets;
  }
}

class PropertyCard extends StatelessWidget {
  final Property property;
  final double width;
  final double height;
  final VoidCallback? onImageTap;
  final VoidCallback? onDataPortionTap;

  const PropertyCard({
    super.key,
    required this.property,
    required this.width,
    required this.height,
    this.onImageTap,
    this.onDataPortionTap,
  });

  bool get isNew => property.status == 'pre_launch';

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18.0);
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6.0,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onDataPortionTap,
            child: Container(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            property.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            _circleIcon(Icons.location_on, Colors.orange),
                            const SizedBox(width: 8),
                            _AnimatedWishlistButton(property: property),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      "${property.address.area}, ${property.address.city}",
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      "Price Range start from",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Text(
                      _formatPrice(property.price, property.currency),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onImageTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    child: _buildImage(property.images.isNotEmpty
                        ? property.images.first.url
                        : 'assets/images/swipe1.png'),
                  ),
                  if (isNew)
                    Positioned(
                      bottom: 100,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
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
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              "New",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
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

  Widget _circleIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 3),
        ],
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image, color: Colors.grey, size: 50),
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
              child: Icon(Icons.error, color: Colors.grey, size: 50),
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
              child: Icon(Icons.error, color: Colors.grey, size: 50),
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

  const _AnimatedWishlistButton({required this.property});

  @override
  State<_AnimatedWishlistButton> createState() => _AnimatedWishlistButtonState();
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

    // FIXED: Use a simple Tween instead of TweenSequence
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut, // This gives a nice bounce effect
      ),
    );

    // Reset the animation when it completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }

  void _onTap() async {
    // Use heavy impact for stronger vibration like Myntra
    HapticFeedback.heavyImpact();
    
    setState(() {
      isWishlisted = !isWishlisted;
    });

    // FIXED: Properly handle the animation
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 3),
            ],
          ),
          child: Icon(
            isWishlisted ? Icons.favorite : Icons.favorite_border,
            color: isWishlisted ? Colors.redAccent : Colors.orange,
            size: 20,
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
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
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