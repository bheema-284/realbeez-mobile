import 'package:flutter/material.dart';
import 'package:real_beez/utils/app_colors.dart';

class CommonText extends StatelessWidget {
  final String text;
  final bool isBold;
  final Color color;
  final double fontSize;
  final TextAlign textAlign;

  const CommonText({
    super.key,
    required this.text,
    this.isBold = false,
    this.color = AppColors.textDark,
    this.fontSize = 14,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}
