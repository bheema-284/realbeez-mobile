import 'package:flutter/material.dart';
import 'package:real_beez/utils/app_colors.dart';
import 'package:real_beez/screens/forms/common_text.dart';

class LandingLayout extends StatelessWidget {
  final String title;
  final String? subtitle; // 👈 added subtitle
  final Widget belowLogo;
  final bool showBack;
  final double logoTopFactor;
  final double logoWidthFactor;

  const LandingLayout({
    super.key,
    required this.title,
    this.subtitle, // 👈 optional
    required this.belowLogo,
    this.showBack = false,
    this.logoTopFactor = 0.25,
    this.logoWidthFactor = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                color: AppColors.textDark,
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        centerTitle: true,
        title: Column(
          children: [
            CommonText(
              text: title,
              isBold: true,
              fontSize: 16,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null)
              CommonText(
                text: subtitle!,
                fontSize: 14,
                color: AppColors.greyText,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final top = constraints.maxHeight * logoTopFactor;
          final logoWidth = constraints.maxWidth * logoWidthFactor;

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: top),
                    Center(
                      child: Image.asset(
                        'assets/logo/logo.png',
                        width: logoWidth,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: belowLogo,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
