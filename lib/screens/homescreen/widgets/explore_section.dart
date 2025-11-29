import 'package:flutter/material.dart';
import 'package:real_beez/utils/app_colors.dart';

class ExploreSection extends StatelessWidget {
  const ExploreSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 400;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Column(
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
                'Explore',
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
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExploreCard(
                title: 'Up to\n20% Off',
                imagePathOrUrl: 'assets/images/banner.png',
                isAsset: true,
                imageAlignment: Alignment.bottomRight,
                imageWidth: 120,
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _buildExploreCard(
                title: 'Under\nConstruction',
                imagePathOrUrl: 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?auto=format&fit=crop&w=600&q=80',
                isAsset: false,
                imageAlignment: Alignment.centerRight,
                imageWidth: 90,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExploreCard({
    required String title,
    required String imagePathOrUrl,
    required bool isAsset,
    required VoidCallback onTap,
    required Alignment imageAlignment,
    double imageWidth = 100,
  }) =>
      Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
               BoxShadow(
  color: Colors.black.withOpacity(0.08),
  blurRadius: 12,
  offset: const Offset(0, 4),
)

              ],
              border: Border.all(color: Colors.grey.withOpacity(0.28)),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 4,
                  left: 16,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: isAsset
                        ? Image.asset(
                            imagePathOrUrl,
                            fit: BoxFit.fitWidth,
                            width: double.infinity,
                            height: 100,
                            alignment: Alignment.bottomCenter,
                          )
                        : Image.network(
                            imagePathOrUrl,
                            fit: BoxFit.fitWidth,
                            width: double.infinity,
                            height: 30,
                            alignment: Alignment.bottomCenter,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}