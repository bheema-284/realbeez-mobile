import 'package:flutter/material.dart';
import 'package:real_beez/utils/app_colors.dart';
import '../widgets/popular_builders_section.dart';
import '../widgets/recommended_sites_section.dart';
import '../widgets/explore_section.dart';
import '../widgets/bank_offers_section.dart';
import '../widgets/must_visit_section.dart';
import '../widgets/featured_sites_section.dart';

class OtherTabsContent extends StatefulWidget {
  final int selectedBuilderIndex;
  final int currentRecommendedPage;
  final List<Map<String, String>> recommendedSites;
  final List<Map<String, String>> trendingApartments;
  final List<Map<String, String>> popularBuilders;
  final ValueChanged<int> onBuilderCardTap;
  final ValueChanged<int> onRecommendedPageChanged;

  const OtherTabsContent({
    super.key,
    required this.selectedBuilderIndex,
    required this.currentRecommendedPage,
    required this.recommendedSites,
    required this.trendingApartments,
    required this.popularBuilders,
    required this.onBuilderCardTap,
    required this.onRecommendedPageChanged,
  });

  @override
  // ignore: library_private_types_in_public_api
  _OtherTabsContentState createState() => _OtherTabsContentState();
}

class _OtherTabsContentState extends State<OtherTabsContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PopularBuildersSection(
          selectedBuilderIndex: widget.selectedBuilderIndex,
          onBuilderCardTap: widget.onBuilderCardTap,
        ),
        const SizedBox(height: 10),

        RecommendedSitesSection(
          currentRecommendedPage: widget.currentRecommendedPage,
          recommendedSites: widget.recommendedSites,
          onPageChanged: widget.onRecommendedPageChanged,
        ),
        const SizedBox(height: 6),

        const ExploreSection(),
        const SizedBox(height: 6),

        const BankOffersSection(),
        const SizedBox(height: 2),

        MustVisitSection(trendingApartments: widget.trendingApartments),
        const SizedBox(height: 6),

        _buildPopularBuildersButtonSection(),
        const SizedBox(height: 2),

        _buildFilterChipsSection(),
        const SizedBox(height: 6),

        const FeaturedSitesSection(),
      ],
    );
  }

  Widget _buildPopularBuildersButtonSection() {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 380;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.beeYellow,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text(
              'Explore more',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
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
                'Most Popular Builders',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 14),
              SizedBox(
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
          const SizedBox(height: 10),

          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: widget.popularBuilders.length,
              separatorBuilder: (context, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = widget.popularBuilders[index];
                return Container(
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color.fromRGBO(215, 154, 47, 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        item['logo']!,
                        height: 45,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['discount']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChipsSection() {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 380;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
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
                    'Popular Around you',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 10 : 14),
                  SizedBox(
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
            ],
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(Icons.filter_list_alt, 'Filter ▼'),
                const SizedBox(width: 8),
                _buildFilterChip(
                  Icons.percent_rounded,
                  'Offers',
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(null, 'Near & Top Rated'),
                const SizedBox(width: 8),
                _buildFilterChip(null, 'Rating 4.5+'),
                const SizedBox(width: 8),
                _buildFilterChip(null, 'Ready to Move'),
                const SizedBox(width: 8),
                _buildFilterChip(null, 'Newly Launched'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    IconData? icon,
    String label, {
    Color color = Colors.black,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 16,
              color: color == Colors.black ? Colors.black87 : color,
            ),
          if (icon != null) const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color == Colors.black ? Colors.black87 : color,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
