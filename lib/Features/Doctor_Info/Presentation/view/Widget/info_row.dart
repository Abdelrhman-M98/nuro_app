import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

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
          style: FontStyles.getRoboto16(context).copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.54),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            value,
            style: FontStyles.getRoboto16(context).copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
