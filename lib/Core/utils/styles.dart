import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyles {
  static TextStyle titleLarge(BuildContext context) => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle titleMedium(BuildContext context) => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
  );

  static TextStyle label(BuildContext context) => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
  );

  static TextStyle accent(BuildContext context) => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.secondary,
  );
}

class FontStyles {
  static TextStyle getRoboto24(BuildContext context) => TextStyle(
    fontSize: 24.sp,
    color: Theme.of(context).colorScheme.onSurface,
    fontWeight: FontWeight.w700,
  );

  static TextStyle getRoboto18(BuildContext context) => TextStyle(
    fontSize: 18.sp,
    color: Theme.of(context).colorScheme.onSurface,
    fontWeight: FontWeight.w700,
  );

  static TextStyle getRoboto16(BuildContext context) => TextStyle(
    fontSize: 16.sp,
    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
    fontWeight: FontWeight.w600,
  );

  static TextStyle getRoboto14(BuildContext context) => TextStyle(
    fontSize: 14.sp,
    color: Theme.of(context).colorScheme.onSurface,
    fontWeight: FontWeight.w500,
  );

  static TextStyle getRoboto12(BuildContext context) => TextStyle(
    fontSize: 12.sp,
    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
    fontWeight: FontWeight.w500,
  );

  // Maintain static versions for migration, but encourage context-based ones
  static TextStyle get roboto24 => TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700);
  static TextStyle get roboto18 => TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700);
  static TextStyle get roboto16 => TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600);
  static TextStyle get roboto14 => TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500);
  static TextStyle get roboto12 => TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500);
}

