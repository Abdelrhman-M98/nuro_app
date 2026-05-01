import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 50.w, height: 1.h, color: kOnSurfaceVariantColor.withValues(alpha: 0.5)),
        SizedBox(width: 10.w),
        Text(context.t("Or continue with", "أو تابع باستخدام"), style: FontStyles.roboto16),
        SizedBox(width: 10.w),
        Container(width: 50.w, height: 1.h, color: kOnSurfaceVariantColor.withValues(alpha: 0.5)),
      ],
    );
  }
}
