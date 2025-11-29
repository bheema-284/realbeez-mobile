import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_beez/screens/models/property.dart';
import 'package:real_beez/screens/models/wishlist_manager.dart';
import 'package:real_beez/utils/app_colors.dart';

class AnimatedWishlistButton extends StatefulWidget {
  final Property property;
  const AnimatedWishlistButton({required this.property});

  @override
  _AnimatedWishlistButtonState createState() => _AnimatedWishlistButtonState();
}

class _AnimatedWishlistButtonState extends State<AnimatedWishlistButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 1,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.3, end: 1.0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _onTap() async {
    HapticFeedback.heavyImpact();
    if (WishlistManager().isInWishlist(widget.property)) {
      WishlistManager().removeFromWishlist(widget.property);
    } else {
      WishlistManager().addToWishlist(widget.property);
    }
    _controller.reset();
    _controller.forward();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWishlisted = WishlistManager().isInWishlist(widget.property);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
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
                color: isWishlisted ? Colors.redAccent : AppColors.beeYellow,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }
}