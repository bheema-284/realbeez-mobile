import 'package:flutter/material.dart';
import 'package:real_beez/utils/app_colors.dart';

class BankOffersSection extends StatelessWidget {
  const BankOffersSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 400;
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
                'Exclusive Bank Offers',
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

          SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              clipBehavior: Clip.none,
              children: [
                _buildBankOfferCard(
                  logoUrl: 'assets/images/icici.png',
                  offerText: 'Up to 20% Off',
                ),
                const SizedBox(width: 10),
                _buildBankOfferCard(
                  logoUrl: 'assets/images/icici.png',
                  offerText: 'Flat 15% Cashback',
                ),
                const SizedBox(width: 10),
                _buildBankOfferCard(
                  logoUrl: 'assets/images/icici.png',
                  offerText: 'Get 10% Off',
                ),
                const SizedBox(width: 10),
                _buildBankOfferCard(
                  logoUrl: 'assets/images/icici.png',
                  offerText: 'Extra ₹1000 Cashback',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankOfferCard({
    required String logoUrl,
    required String offerText,
  }) =>
      Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
           boxShadow: [
               BoxShadow(
  color: Colors.black.withOpacity(0.08),
  blurRadius: 12,
  offset: const Offset(0, 4),
)

              ],
          
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                logoUrl,
                height: 80,
                width: 80,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  offerText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}