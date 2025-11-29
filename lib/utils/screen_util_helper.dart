import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenUtilHelper {
  static bool get isInitialized {
    try {
      // ignore: unnecessary_null_comparison
      return ScreenUtil().scaleHeight != null;
    } catch (e) {
      return false;
    }
  }

  static double getSafeHeight(double value) {
    if (isInitialized) {
      return value.h;
    }
    return value;
  }

  static double getSafeWidth(double value) {
    if (isInitialized) {
      return value.w;
    }
    return value;
  }

  static double getSafeFontSize(double value) {
    if (isInitialized) {
      return value.sp;
    }
    return value;
  }

  static double getSafeRadius(double value) {
    if (isInitialized) {
      return value.r;
    }
    return value;
  }
}