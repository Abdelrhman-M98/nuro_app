import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_app/Core/utils/styles.dart';

class PatientsCardButton extends StatelessWidget {
  const PatientsCardButton({
    super.key,
    required this.patientName,
    required this.age,
    required this.condition,
    required this.imageUrl,
    required this.percentage,
    this.onPressed,
  });
  final String patientName;
  final String age;
  final String condition;
  final String imageUrl;
  final int percentage;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final Color buttonColor;
    if (percentage <= 30) {
      buttonColor = Color(0XFF3CC567);
    } else if (percentage <= 88) {
      buttonColor = Color(0XFFFFBE32);
    } else {
      buttonColor = Color(0XFFFF0000);
    }

    return MaterialButton(
      splashColor: Colors.transparent,
      padding: EdgeInsets.zero,
      onPressed: onPressed ?? () {},
      color: buttonColor,

      height: 69.h,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(radius: 30.r, backgroundImage: NetworkImage(imageUrl)),
            SizedBox(width: 18.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontStyles.roboto16.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "$age Y.O",
                      style: FontStyles.roboto12.copyWith(color: Colors.white),
                    ),
                    SizedBox(width: 7.w),
                    Text(
                      condition,
                      style: FontStyles.roboto12.copyWith(color: Colors.white),
                    ),
                    SizedBox(width: 7.w),
                  ],
                ),
              ],
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(right: 29.w),
              child: Text(
                "$percentage%",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
