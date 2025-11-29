import 'package:flutter/material.dart';
import 'package:real_beez/utils/app_colors.dart';
import 'package:real_beez/screens/forms/common_text.dart';

class AuthFooter extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onLinkTap;

  const AuthFooter({
    super.key,
    required this.text,
    required this.linkText,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonText(
              text: text,
              fontSize: 14,
              isBold: true,
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onLinkTap,
              child: CommonText(
                text: linkText,
                isBold: true,
                fontSize: 14,
                color: AppColors.beeYellow,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CommonText(
          text:
              "By signing up you need to accept the Terms of Services and Privacy Policy",
          fontSize: 12,
          color: AppColors.greyText,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
