import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_app/Core/utils/const.dart';
import 'package:neuro_app/Core/utils/styles.dart';

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 144.w,
      height: 52.h,
      decoration: BoxDecoration(
        border: Border.all(color: kPrimaryColor),
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/google_icon.png"),
          SizedBox(width: 13.w),
          Text(
            "Google",
            style: FontStyles.roboto16.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
