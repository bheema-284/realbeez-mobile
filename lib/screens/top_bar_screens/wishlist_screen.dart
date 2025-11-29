import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beez/screens/models/wishlist_manager.dart';
import 'package:real_beez/screens/models/property.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistManager _wishlistManager = WishlistManager();
  List<Property> _wishlist = []; // Initialize with empty list instead of late

  @override
  void initState() {
    super.initState();
    _initializeWishlist();
    _wishlistManager.addListener(_onWishlistChanged);
  }

  void _initializeWishlist() {
    _wishlist = _wishlistManager.wishlist;
  }

  void _onWishlistChanged() {
    if (mounted) {
      setState(() {
        _wishlist = _wishlistManager.wishlist;
      });
    }
  }

  @override
  void dispose() {
    _wishlistManager.removeListener(_onWishlistChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFF1F2FF); 
    const Color titleColor = Colors.black87;
    const Color subtitleColor = Colors.grey;
    const Color iconColor = Colors.grey;
    const Color scrollbarColor = Color(0xFFFFD700); 

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Wishlist',
          style: GoogleFonts.poppins(
            color: titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Theme(
        data: Theme.of(context).copyWith(
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: WidgetStateProperty.all(scrollbarColor),
          ),
        ),
        child: _wishlist.isEmpty
            ? const Center(
                child: Text(
                  'No items in wishlist',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : Scrollbar(
                thumbVisibility: true,
                thickness: 4,
                radius: const Radius.circular(4),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _wishlist.length,
                  itemBuilder: (context, index) {
                    final Property property = _wishlist[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Material(
                            elevation: 3,
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: property.images.isNotEmpty
                                        ? _buildPropertyImage(property.images.first.url)
                                        : Image.asset(
                                            'assets/images/wishlist.png',
                                            width: 100,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          property.title,
                                          style: GoogleFonts.poppins(
                                            color: titleColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_getCurrencySymbol(property.currency)} ${_formatPrice(property.price)}',
                                          style: GoogleFonts.poppins(
                                            color: subtitleColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 200,
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(Icons.location_on, color: iconColor, size: 16),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  '${property.address.area}, ${property.address.city}',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: -5,
                            right: -5,
                            child: GestureDetector(
                              onTap: () {
                                _wishlistManager.removeFromWishlist(property);
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 3,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(Icons.favorite, color: Colors.red, size: 20),
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
      ),
    );
  }

  Widget _buildPropertyImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: 100,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/wishlist.png',
            width: 100,
            height: 80,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      return Image.network(
        imageUrl,
        width: 100,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/wishlist.png',
            width: 100,
            height: 80,
            fit: BoxFit.cover,
          );
        },
      );
    }
  }

  String _formatPrice(int price) {
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
    return buffer.toString().split('').reversed.join();
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currency;
    }
  }
}