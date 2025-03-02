import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neuro_app/Core/utils/styles.dart';

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
  CustomPasswordFieldState createState() => CustomPasswordFieldState();
}

class CustomPasswordFieldState extends State<CustomPasswordField> {
  bool isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: !isPasswordVisible,
      style: FontStyles.roboto12,
      validator: widget.validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: widget.label,
        labelStyle: FontStyles.roboto12,
        hintStyle: FontStyles.roboto12,
        contentPadding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),

        prefixIcon: Padding(
          padding: EdgeInsets.only(
            right: 27.w,
            left: 22.w,
            top: 19.h,
            bottom: 19.h,
          ),
          child: FaIcon(widget.icon, color: Color(0xFF919191), size: 19.sp),
        ),

        suffixIcon: IconButton(
          icon: Padding(
            padding: EdgeInsets.only(right: 21.w),
            child: Icon(
              isPasswordVisible
                  ? FontAwesomeIcons.eye
                  : FontAwesomeIcons.eyeSlash,
              size: 16.sp,
              color: isPasswordVisible ? Colors.blue : Colors.grey,
            ),
          ),
          onPressed: _togglePasswordVisibility,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17.r),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17.r),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17.r),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17.r),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17.r),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
