import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            context.t("OR", "أو"),
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
      ],
    );
  }
}
