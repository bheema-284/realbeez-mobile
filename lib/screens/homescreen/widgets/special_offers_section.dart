import 'package:flutter/material.dart';
import 'package:real_beez/property_cards.dart';
import 'package:real_beez/utils/app_colors.dart';

class SpecialOffersSection extends StatefulWidget {
  final int currentSpecialOfferPage;
  final ValueChanged<int> onPageChanged;

  const SpecialOffersSection({
    super.key,
    required this.currentSpecialOfferPage,
    required this.onPageChanged,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SpecialOffersSectionState createState() => _SpecialOffersSectionState();
}

class _SpecialOffersSectionState extends State<SpecialOffersSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.48; // Slightly less than half for spacing

    return SizedBox(
      height: 180,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero, // Remove all padding
              itemCount: PropertyData.specialOffers.length,
              itemBuilder: (context, index) {
                final offer = PropertyData.specialOffers[index];
                return Container(
                  width: cardWidth,
                  margin: const EdgeInsets.only(
                    right: 8,
                  ), // Only right margin for spacing
                  child: _buildOfferCard(
                    imageUrl: offer['image']!,
                    title: offer['title']!,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              PropertyData.specialOffers.length,
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

  Widget _buildOfferCard({required String imageUrl, required String title}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
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
