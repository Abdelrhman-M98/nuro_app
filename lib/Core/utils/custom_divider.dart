import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_app/Core/utils/styles.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 50.w, height: 1.h, color: Colors.grey),
        SizedBox(width: 10.w),
        Text("Or Continue in with", style: FontStyles.roboto16),
        SizedBox(width: 10.w),
        Container(width: 50.w, height: 1.h, color: Colors.grey),
      ],
    );
  }
}
