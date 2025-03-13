import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_app/Core/utils/const.dart';

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
        color: Colors.black,
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
      borderColor: Colors.white,
      fillColor: Colors.white,
      enabledBorderColor: Colors.white,
      focusedBorderColor: kPrimaryColor,
      onCodeChanged: (String code) {},
      onSubmit: (String verificationCode) {},
    );
  }
}
