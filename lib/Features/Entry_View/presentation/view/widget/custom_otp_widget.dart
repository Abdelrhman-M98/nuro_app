import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

class CustomOtpWidget extends StatelessWidget {
  const CustomOtpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return OtpTextField(
      showFieldAsBox: true,
      borderRadius: BorderRadius.circular(17.r),
      numberOfFields: 4,
      fieldWidth: 60.w,
      fieldHeight: 60.h,
      textStyle: TextStyle(
        fontSize: 35.sp,
        color: context.colorScheme.onSurface,
        fontFamily: "Roboto",
        height: 1.h,
      ),
      margin: EdgeInsets.all(10.h),
      keyboardType: TextInputType.number,
      alignment: Alignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      filled: true,
      autoFocus: true,
      borderColor: context.colorScheme.onSurface.withValues(alpha: 0.1),
      fillColor: context.colorScheme.surface,
      enabledBorderColor: context.colorScheme.onSurface.withValues(alpha: 0.1),
      focusedBorderColor: kPrimaryColor,
      onCodeChanged: (String code) {},
      onSubmit: (String verificationCode) {},
    );
  }
}
