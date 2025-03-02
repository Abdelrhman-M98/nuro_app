import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_app/Core/utils/styles.dart';

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
          style:
              isActive
                  ? FontStyles.roboto12
                  : FontStyles.roboto12.copyWith(color: Colors.grey),
        ),
      ),
    );
  }
}
