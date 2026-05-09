import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

class CustomUserTypeButton extends StatelessWidget {
  const CustomUserTypeButton({
    super.key,
    required this.userType,
    required this.imagePath,
    required this.selectedUserType,
    required this.onPressed,
  });

  final String userType;
  final String imagePath;
  final ValueNotifier<String?> selectedUserType;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: selectedUserType,
      builder: (context, selected, child) {
        final bool isSelected = selected == userType;
        return MaterialButton(
          minWidth: 321.w,
          height: 69.h,
          color: isSelected ? kPrimaryColor : context.colorScheme.surface,
          elevation: isSelected ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17.r),
            side: BorderSide(
              color: isSelected ? Colors.transparent : context.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          onPressed: onPressed,
          child: Row(
            children: [
              Image.asset(imagePath, width: 31.w, height: 31.h),
              SizedBox(width: 16.w),
              Text(
                userType,
                style: FontStyles.getRoboto16(context).copyWith(
                  color: isSelected ? Colors.white : context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
