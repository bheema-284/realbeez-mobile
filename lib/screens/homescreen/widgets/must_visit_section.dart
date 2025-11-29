
import 'package:flutter/material.dart';
import 'package:real_beez/utils/app_colors.dart';

class MustVisitSection extends StatelessWidget {
  final List<Map<String, String>> trendingApartments;

  const MustVisitSection({
    Key? key,
    required this.trendingApartments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                'Must Visits',
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
          const SizedBox(height: 14),

          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              clipBehavior: Clip.none,
              itemCount: trendingApartments.length,
              separatorBuilder: (context, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = trendingApartments[index];
                return _buildTrendingCard(
                  title: item['title']!,
                  imageUrl: item['image']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingCard({
    required String title,
    required String imageUrl,
  }) =>
      Container(
        width: 150,
        height: 156,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF1FF),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(100),
            topRight: Radius.circular(100),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(100),
            topRight: Radius.circular(100),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}