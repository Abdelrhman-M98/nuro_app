import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

class EntryButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const EntryButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44.h,
        alignment: Alignment.center,
        child: Text(
          text,
          style: FontStyles.getRoboto12(context).copyWith(
            color: isActive ? context.colorScheme.onSurface : context.colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
