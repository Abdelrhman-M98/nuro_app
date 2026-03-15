import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/app_assets.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 144.w,
        height: 52.h,
        decoration: BoxDecoration(
          color: kSurfaceColor,
          border: Border.all(color: kAccentColor.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.kGoogleIcon, width: 22.w, height: 22.h),
            SizedBox(width: 10.w),
            Text(
              "Google",
              style: FontStyles.roboto16.copyWith(
                color: kOnBackgroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
