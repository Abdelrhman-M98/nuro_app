import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';

class PatientsCardInfo extends StatelessWidget {
  const PatientsCardInfo({
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
  final String percentage;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: kAccentColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: kSurfaceLightColor,
            backgroundImage: NetworkImage(imageUrl),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  patientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FontStyles.roboto16.copyWith(
                    color: kOnBackgroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Text(
                      "$age Y.O",
                      style: FontStyles.roboto12.copyWith(
                        color: kOnBackgroundColor.withValues(alpha: 0.9),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        condition,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontStyles.roboto12.copyWith(
                          color: kOnBackgroundColor.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "$percentage%",
                      style: FontStyles.roboto12.copyWith(
                        color: kAccentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
