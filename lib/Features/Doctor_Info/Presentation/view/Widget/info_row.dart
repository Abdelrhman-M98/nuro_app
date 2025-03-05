import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_app/Core/utils/styles.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: FontStyles.roboto16.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: 37.w),
        Text(
          value,
          style: FontStyles.roboto16.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
