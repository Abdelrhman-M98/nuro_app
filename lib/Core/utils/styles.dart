import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';

class AppTextStyles {
  static TextStyle titleLarge(BuildContext context) => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: kOnBackgroundColor,
      );

  static TextStyle titleMedium(BuildContext context) => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: kOnBackgroundColor,
      );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: kOnSurfaceColor,
      );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: kOnSurfaceVariantColor,
      );

  static TextStyle label(BuildContext context) => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: kOnSurfaceVariantColor,
      );

  static TextStyle accent(BuildContext context) => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: kAccentColor,
      );
}

// للتوافق مع الكود القديم
class FontStyles {
  static TextStyle get roboto24 => TextStyle(
        fontSize: 24.sp,
        color: kOnBackgroundColor,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get roboto18 => TextStyle(
        fontSize: 18.sp,
        color: kOnBackgroundColor,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get roboto16 => TextStyle(
        fontSize: 16.sp,
        color: kOnSurfaceVariantColor,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get roboto14 => TextStyle(
        fontSize: 14.sp,
        color: kOnBackgroundColor,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get roboto12 => TextStyle(
        fontSize: 12.sp,
        color: kOnSurfaceColor,
        fontWeight: FontWeight.w500,
      );
}
