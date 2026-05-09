import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: context.colorScheme.onSurface.withValues(alpha: 0.1), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            context.t("OR", "أو"),
            style: TextStyle(
              color: context.colorScheme.onSurface.withValues(alpha: 0.38),
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Divider(color: context.colorScheme.onSurface.withValues(alpha: 0.1), thickness: 1)),
      ],
    );
  }
}
