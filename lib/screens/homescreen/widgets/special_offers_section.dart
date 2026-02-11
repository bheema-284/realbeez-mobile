import 'package:flutter/material.dart';
import 'package:real_beez/property_cards.dart';
import 'package:real_beez/screens/homescreen/property_details_screen.dart';
import 'package:real_beez/utils/app_colors.dart';

class SpecialOffersSection extends StatefulWidget {
  final int currentSpecialOfferPage;
  final ValueChanged<int> onPageChanged;
  final int selectedTabIndex;

  const SpecialOffersSection({
    super.key,
    required this.currentSpecialOfferPage,
    required this.onPageChanged,
    required this.selectedTabIndex,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SpecialOffersSectionState createState() => _SpecialOffersSectionState();
}

class _SpecialOffersSectionState extends State<SpecialOffersSection> {
  final ScrollController _scrollController = ScrollController();

  // Map tab indices to category keys
  final Map<int, String> _tabIndexToCategory = {
    0: 'all',
    1: 'apartment',
    2: 'villas',
    3: 'farmlands',
    4: 'open_plots',
    5: 'commercial',
    6: 'independent',
  };

  // Get special offers for the selected tab
  List<Map<String, String>> get _currentSpecialOffers {
    final category = _tabIndexToCategory[widget.selectedTabIndex] ?? 'all';
    return PropertyData.categorySpecialOffers[category] ??
        PropertyData.categorySpecialOffers['all']!;
  }

  // Helper to get price range based on property type
  String _getPriceRangeForCategory(String category) {
    switch (category) {
      case 'apartment':
        return '₹ 50 L - 2 Cr';
      case 'villas':
        return '₹ 2 Cr - 5 Cr';
      case 'farmlands':
        return '₹ 30 L - 1 Cr';
      case 'open_plots':
        return '₹ 20 L - 80 L';
      case 'commercial':
        return '₹ 1 Cr - 5 Cr';
      case 'independent':
        return '₹ 1.5 Cr - 4 Cr';
      default:
        return '₹ 50 L - 5 Cr';
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'apartment':
        return 'Apartment';
      case 'villas':
        return 'Villa';
      case 'farmlands':
        return 'Farmland';
      case 'open_plots':
        return 'Open Plot';
      case 'commercial':
        return 'Commercial Space';
      case 'independent':
        return 'Independent House';
      default:
        return 'PROPERTY';
    }
  }

  @override
  void initState() {
    super.initState();
    // Reset scroll position when widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(0);
    });
  }

  @override
  void didUpdateWidget(covariant SpecialOffersSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If tab changed, reset scroll position to first item
    if (oldWidget.selectedTabIndex != widget.selectedTabIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(0);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.40;

    return SizedBox(
      height: 190,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: _currentSpecialOffers.length,
              itemBuilder: (context, index) {
                final offer = _currentSpecialOffers[index];
                final propertyId = offer['propertyId'] ?? 'prop_001';

                // Get the current category based on selected tab
                final currentCategory =
                    _tabIndexToCategory[widget.selectedTabIndex] ?? 'all';
                final categoryName = _getCategoryDisplayName(currentCategory);
                final priceRange = _getPriceRangeForCategory(currentCategory);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PropertyDetailScreen(propertyId: propertyId),
                      ),
                    );
                  },
                  child: Container(
                    width: cardWidth,
                    margin: const EdgeInsets.only(right: 8),
                    child: _buildOfferCard(
                      imageUrl: offer['image']!,
                      title: offer['title']!,
                      categoryName: categoryName,
                      priceRange: priceRange,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _currentSpecialOffers.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.currentSpecialOfferPage == index
                      ? Colors.black
                      : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard({
    required String imageUrl,
    required String title,
    required String categoryName,
    required String priceRange,
  }) {
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: imageUrl.startsWith('assets/')
                ? Image.asset(
                    imageUrl,
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    imageUrl,
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Type (APARTMENT/VILLA/etc.)
                Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.beeYellow,
                  ),
                ),

                // Property Title
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),

                // Price Range
                Text(
                  priceRange,
                  style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                ),
                const SizedBox(height: 2),

                // Unlock the offer button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.beeYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 5),
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
