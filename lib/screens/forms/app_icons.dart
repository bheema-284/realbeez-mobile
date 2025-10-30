import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  static Widget arrowRight({double size = 24, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/arrow_right.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  static Widget user({double size = 24, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/user.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }
}
