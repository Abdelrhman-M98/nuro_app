import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';

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

    return SizedBox(
      height: 69.h,
      child: ElevatedButton(
        onPressed: onPressed ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          elevation: 3,
          shadowColor: buttonColor.withValues(alpha: 0.5),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17.r)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(radius: 26.r, backgroundImage: NetworkImage(imageUrl)),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontStyles.getRoboto16(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "$age ${context.t('Y.O', 'سنة')}",
                          style: FontStyles.getRoboto12(context).copyWith(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                        SizedBox(width: 7.w),
                        Expanded(
                          child: Text(
                            condition,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontStyles.getRoboto12(context).copyWith(color: Colors.white.withValues(alpha: 0.9)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15.w, left: 15.w),
                child: Text(
                  "$percentage%",
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
