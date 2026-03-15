import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';

class CustomPasswordField extends StatefulWidget {
  const CustomPasswordField({
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
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      style: FontStyles.roboto12.copyWith(color: kOnSurfaceColor),
      validator: widget.validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: kSurfaceColor,
        labelText: widget.label,
        labelStyle: FontStyles.roboto12.copyWith(color: kOnSurfaceVariantColor),
        hintStyle: FontStyles.roboto12.copyWith(color: kOnSurfaceVariantColor),
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        prefixIcon: Padding(
          padding: EdgeInsets.only(right: 16.w, left: 16.w, top: 14.h, bottom: 14.h),
          child: FaIcon(widget.icon, color: kAccentColor, size: 18.sp),
        ),
        suffixIcon: IconButton(
          icon: FaIcon(
            _obscure ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
            size: 16.sp,
            color: kOnSurfaceVariantColor,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
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
