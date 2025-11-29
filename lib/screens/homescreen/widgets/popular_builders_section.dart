import 'package:flutter/material.dart';
import 'package:real_beez/property_cards.dart';
import 'package:real_beez/utils/app_colors.dart';

class PopularBuildersSection extends StatefulWidget {
  final int selectedBuilderIndex;
  final ValueChanged<int> onBuilderCardTap;

  const PopularBuildersSection({
    Key? key,
    required this.selectedBuilderIndex,
    required this.onBuilderCardTap,
  }) : super(key: key);

  @override
  _PopularBuildersSectionState createState() => _PopularBuildersSectionState();
}

class _PopularBuildersSectionState extends State<PopularBuildersSection> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
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
                'Popular Builders',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 14),
              Container(
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
          SizedBox(height: 4),
          Container(
            height: isSmallScreen ? 100 : 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: (PropertyData.builderImages.length / 2).ceil(),
              itemBuilder: (context, index) {
                return _buildBuilderCard(index, isSmallScreen);
              },
            ),
          ),
          SizedBox(height: 12),
          Container(
            height: isSmallScreen ? 100 : 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: PropertyData.builderImages.length - (PropertyData.builderImages.length / 2).ceil(),
              itemBuilder: (context, index) {
                int actualIndex = index + (PropertyData.builderImages.length / 2).ceil();
                return _buildBuilderCard(actualIndex, isSmallScreen);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuilderCard(int index, bool isSmallScreen) {
    final isSelected = widget.selectedBuilderIndex == index;

    return GestureDetector(
      onTap: () => widget.onBuilderCardTap(index),
      child: Container(
        width: isSmallScreen ? 90 : 100,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.beeYellow : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Image.asset(
              PropertyData.builderImages[index],
              width: isSmallScreen ? 60 : 70,
              height: isSmallScreen ? 60 : 70,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.business,
                color: isSelected ? Colors.white : Colors.grey,
                size: isSmallScreen ? 30 : 35,
              ),
            ),
          ),
        ),
      ),
    );
  }
}