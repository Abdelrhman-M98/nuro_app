import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';

class EntryBackground extends StatelessWidget {
  final bool isSignIn;
  final double pillWidth;

  const EntryBackground({
    super.key,
    required this.isSignIn,
    this.pillWidth = 145,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 300),
      alignment: isSignIn ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        width: pillWidth,
        height: 32.h,
        decoration: BoxDecoration(
          color: kSurfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: kAccentColor.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}
