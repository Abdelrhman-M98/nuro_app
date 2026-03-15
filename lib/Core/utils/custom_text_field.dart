import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: FontStyles.roboto12.copyWith(color: kOnSurfaceColor),
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: kSurfaceColor,
        labelText: label,
        labelStyle: FontStyles.roboto12.copyWith(color: kOnSurfaceVariantColor),
        hintStyle: FontStyles.roboto12.copyWith(color: kOnSurfaceVariantColor),
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        prefixIcon: Padding(
          padding: EdgeInsets.only(right: 16.w, left: 16.w, top: 14.h, bottom: 14.h),
          child: FaIcon(icon, color: kAccentColor, size: 18.sp),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: kSurfaceLightColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: kAccentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: kErrorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: kErrorColor, width: 1.5),
        ),
      ),
    );
  }
}
