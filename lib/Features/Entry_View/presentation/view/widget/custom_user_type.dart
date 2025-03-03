import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_app/Core/utils/const.dart';
import 'package:neuro_app/Core/utils/styles.dart';

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17.r),
          ),
          color: isSelected ? kPrimaryColor : Colors.white,
          onPressed: onPressed,
          child: Row(
            children: [
              Image.asset(imagePath, width: 31.w, height: 31.h),
              SizedBox(width: 16.w),
              Text(
                userType,
                style: FontStyles.roboto16.copyWith(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
