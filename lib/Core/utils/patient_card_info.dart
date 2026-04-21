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
  });

  final String patientName;
  final int age;
  final String condition;
  final String imageUrl;
  final String profileImageBase64;
  final double signalValue;
  final String gender;
  final String currentState;

  static bool _showCondition(String c) {
    final t = c.trim().toLowerCase();
    return t.isNotEmpty && t != 'unknown';
  }

  static String _shortGender(String g) {
    final s = g.trim();
    if (s.isEmpty) return '—';
    final lower = s.toLowerCase();
    if (lower == 'male' || lower == 'm') return 'Male';
    if (lower == 'female' || lower == 'f' || lower == 'woman') {
      return 'Female';
    }
    return s[0].toUpperCase() + (s.length > 1 ? s.substring(1) : '');
  }

  @override
  Widget build(BuildContext context) {
    final bool isAbnormal = currentState.toLowerCase() == 'abnormal';
    final statusColor = isAbnormal ? const Color(0xFFFF6B6B) : const Color(0xFF4ADE80);
    final statusLabel = isAbnormal ? 'Attention' : 'Stable';
    final showCondition = _showCondition(condition);

    final avatarWidget = ProfileAvatarFromFields(
      profileImageUrl: imageUrl,
      profileImageBase64: profileImageBase64,
      genderFallback: gender,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kPrimaryColor,
            kPrimaryColor.withValues(alpha: 0.88),
            kSurfaceLightColor.withValues(alpha: 0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.85),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: isAbnormal ? 0.28 : 0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68.r,
            height: 68.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: statusColor.withValues(alpha: 0.65),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(child: avatarWidget),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        patientName.isNotEmpty ? patientName : 'Patient',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontStyles.roboto18.copyWith(
                          color: kOnBackgroundColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAbnormal
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 14.sp,
                            color: statusColor,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            statusLabel,
                            style: FontStyles.roboto12.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.cake_outlined, size: 14.sp, color: Colors.white54),
                    Text(
                      '$age yrs',
                      style: FontStyles.roboto14.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '·',
                      style: TextStyle(color: Colors.white38, fontSize: 14.sp),
                    ),
                    Icon(
                      gender.toLowerCase().contains('female') ||
                              gender.toLowerCase() == 'f'
                          ? Icons.female
                          : Icons.male,
                      size: 15.sp,
                      color: Colors.white54,
                    ),
                    Text(
                      _shortGender(gender),
                      style: FontStyles.roboto14.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (showCondition) ...[
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Icon(
                          Icons.medical_information_outlined,
                          size: 15.sp,
                          color: kAccentColor.withValues(alpha: 0.9),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          condition,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FontStyles.roboto12.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: kAccentColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sensors_rounded,
                        color: kAccentColor,
                        size: 22.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Neural signal (live)',
                              style: FontStyles.roboto12.copyWith(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              signalValue.toStringAsFixed(0),
                              style: FontStyles.roboto24.copyWith(
                                color: kAccentColor,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
