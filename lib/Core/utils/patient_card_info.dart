import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Core/utils/profile_avatar_widget.dart';

class PatientsCardInfo extends StatelessWidget {
  const PatientsCardInfo({
    super.key,
    required this.patientName,
    required this.age,
    required this.condition,
    required this.imageUrl,
    this.profileImageBase64 = '',
    required this.signalValue,
    required this.gender,
    required this.currentState,
    this.onPressed,
  });

  final String patientName;
  final int age;
  final String condition;
  final String imageUrl;
  final String profileImageBase64;
  final double signalValue;
  final String gender;
  final String currentState;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isAbnormal = currentState == 'abnormal';
    
    final avatarWidget = ProfileAvatarFromFields(
      profileImageUrl: imageUrl,
      profileImageBase64: profileImageBase64,
      genderFallback: gender,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isAbnormal ? Colors.red : Colors.green,
          width: 2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAbnormal ? Colors.red : Colors.green).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: ClipOval(child: avatarWidget),
          ),
          SizedBox(width: 14.w),
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
                  style: FontStyles.roboto18.copyWith(
                    color: kOnBackgroundColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      "$age Y.O",
                      style: FontStyles.roboto14.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text(
                      "Signal: ",
                      style: FontStyles.roboto14.copyWith(
                        color: kOnSurfaceVariantColor,
                      ),
                    ),
                    Text(
                      "${signalValue.toInt()}",
                      style: FontStyles.roboto16.copyWith(
                        color: kAccentColor,
                        fontWeight: FontWeight.bold,
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
