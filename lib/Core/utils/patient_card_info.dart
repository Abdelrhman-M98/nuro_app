import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';
import 'package:nervix_app/Core/utils/profile_avatar_widget.dart';
import 'package:nervix_app/Core/utils/disease_translator.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

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

  String _shortGender(BuildContext context, String g) {
    final s = g.trim();
    if (s.isEmpty) return '—';
    final lower = s.toLowerCase();
    if (lower == 'male' || lower == 'm') return context.t('Male', 'ذكر');
    if (lower == 'female' || lower == 'f' || lower == 'woman') {
      return context.t('Female', 'أنثى');
    }
    return s[0].toUpperCase() + (s.length > 1 ? s.substring(1) : '');
  }

  @override
  Widget build(BuildContext context) {
    final bool isAbnormal = currentState != 'Normal';
    final statusColor = isAbnormal ? const Color(0xFFFF6B6B) : const Color(0xFF4ADE80);
    final statusLabel = isAbnormal ? context.t('Attention', 'انتباه') : context.t('Stable', 'مستقر');
    final showCondition = _showCondition(condition);

    final avatarWidget = ProfileAvatarFromFields(
      profileImageUrl: imageUrl,
      profileImageBase64: profileImageBase64,
      genderFallback: gender,
    );

    final bool isDark = context.isDarkMode;
    final primaryColor = context.colorScheme.primary;
    final onSurface = context.colorScheme.onSurface;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? context.colorScheme.surface : const Color(0xFFEDF2FF), // Distinct light Indigo tint
        gradient: isDark 
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withValues(alpha: 0.12),
                primaryColor.withValues(alpha: 0.05),
              ],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF5F9FF), // Very soft blue
                Color(0xFFE0E7FF), // Distinct but light indigo hint
              ],
            ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isAbnormal 
            ? statusColor.withValues(alpha: 0.4) 
            : (isDark ? Colors.white.withValues(alpha: 0.06) : primaryColor.withValues(alpha: 0.18)),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : primaryColor).withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 28,
            offset: const Offset(0, 10),
            spreadRadius: -2,
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
                color: statusColor.withValues(alpha: 0.4),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : primaryColor).withValues(alpha: 0.1),
                  blurRadius: 12,
                  spreadRadius: 2,
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
                        patientName.isNotEmpty && patientName != 'User' ? patientName : context.t('User', 'مستخدم'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FontStyles.getRoboto18(context).copyWith(
                          color: onSurface,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.25),
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
                            style: FontStyles.getRoboto12(context).copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
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
                    Icon(Icons.cake_outlined, size: 14.sp, color: onSurface.withValues(alpha: 0.5)),
                    Text(
                      '$age ${context.t('yrs', 'سنة')}',
                      style: FontStyles.getRoboto14(context).copyWith(
                        color: onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '·',
                      style: TextStyle(color: onSurface.withValues(alpha: 0.3), fontSize: 14.sp),
                    ),
                    Icon(
                      gender.toLowerCase().contains('female') ||
                              gender.toLowerCase() == 'f'
                          ? Icons.female
                          : Icons.male,
                      size: 15.sp,
                      color: onSurface.withValues(alpha: 0.5),
                    ),
                    Text(
                      _shortGender(context, gender),
                      style: FontStyles.getRoboto14(context).copyWith(
                        color: onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
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
                          DiseaseTranslator.translate(context, condition),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FontStyles.getRoboto12(context).copyWith(
                            color: onSurface.withValues(alpha: 0.65),
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
                    color: isDark 
                        ? Colors.black.withValues(alpha: 0.12)
                        : primaryColor.withValues(alpha: 0.08), // Slightly darker for contrast
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: isDark ? 0.08 : 0.12),
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
                              context.t('Neural signal (live)', 'الإشارة العصبية (مباشر)'),
                              style: FontStyles.getRoboto12(context).copyWith(
                                color: onSurface.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              signalValue.toStringAsFixed(0),
                              style: FontStyles.getRoboto24(context).copyWith(
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
