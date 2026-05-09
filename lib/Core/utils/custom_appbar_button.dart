import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

class CustomAppBarButton extends StatelessWidget {
  const CustomAppBarButton({super.key, required this.onPressed});
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surface,
      borderRadius: BorderRadius.circular(12.r),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: context.colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 48.w,
          height: 48.h,
          alignment: Alignment.center,
          child: Icon(Icons.chevron_left, color: kAccentColor, size: 28.sp),
        ),
      ),
    );
  }
}
