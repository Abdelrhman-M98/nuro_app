import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nervix_app/Core/services/app_preferences.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

class MedicalDisclaimerScreen extends StatelessWidget {
  const MedicalDisclaimerScreen({super.key, this.reviewOnly = false});

  /// When true (e.g. opened from Profile), show Close only — acceptance was already recorded.
  final bool reviewOnly;

  static List<String> _getPoints(BuildContext context) => [
    context.t('Nervix is designed to assist with monitoring contextual information. It does not diagnose, treat, or prevent any medical condition.', 'تم تصميم نيرفيكس للمساعدة في مراقبة المعلومات السياقية. هو لا يشخص أو يعالج أو يمنع أي حالة طبية.'),
    context.t('Readings and alerts are informational. False positives or missed events can occur. Do not rely solely on the app for critical decisions.', 'القراءات والتنبيهات هي لأغراض إعلامية فقط. قد تحدث تنبيهات خاطئة أو يتم تفويت بعض الأحداث. لا تعتمد فقط على التطبيق في القرارات المصيرية.'),
    context.t('Background behavior and notifications may vary by device and operating system policies. Monitoring may pause or be limited when the app is not active.', 'سلوك التطبيق في الخلفية والإشعارات قد يختلف حسب نوع الجهاز وسياسات نظام التشغيل. المراقبة قد تتوقف أو تتأثر عندما لا يكون التطبيق نشطاً.'),
    context.t('Always follow your clinician\'s advice. Use local emergency services in life-threatening situations.', 'اتبع دائماً نصيحة طبيبك. استخدم خدمات الطوارئ المحلية في الحالات التي تهدد الحياة.'),
    context.t('By continuing, you acknowledge these limits and agree to use the app responsibly.', 'بموافقتك وإكمالك، فإنك تقر بهذه الحدود وتوافق على استخدام التطبيق بمسؤولية.'),
  ];

  @override
  Widget build(BuildContext context) {
    final points = _getPoints(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: context.isDarkMode ? kDarkGradient : kLightGradient,
        ),

        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 12.h),
                Icon(Icons.medical_information_outlined,
                    size: 52.sp, color: kAccentColor),
                SizedBox(height: 16.h),
                Text(
                  context.t('Important notice', 'تنبيه هام'),
                  textAlign: TextAlign.center,
                  style: FontStyles.getRoboto24(context).copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 10.h),
                Text(
                  context.t('Please read before using Nervix', 'يرجى القراءة قبل استخدام نيرفيكس'),
                  textAlign: TextAlign.center,
                  style: FontStyles.getRoboto14(context).copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),

                SizedBox(height: 22.h),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    radius: Radius.circular(8.r),
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: points.length,
                      separatorBuilder: (context, _) => SizedBox(height: 14.h),
                      itemBuilder: (context, i) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Icon(Icons.check_circle_outline,
                                  color: kAccentColor, size: 20.sp),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                points[i],
                                style: FontStyles.getRoboto14(context).copyWith(
                                  color: context.colorScheme.onSurface.withValues(alpha: 0.9),
                                  height: 1.45,
                                ),
                              ),

                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                SizedBox(
                  height: 54.h,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: kAccentColor,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    onPressed: () async {
                      if (reviewOnly) {
                        if (context.mounted) context.pop();
                        return;
                      }
                      await AppPreferences.setMedicalDisclaimerAccepted();
                      if (context.mounted) {
                        context.go(AppRouter.kLoginView);
                      }
                    },
                    child: Text(
                      reviewOnly ? context.t('Close', 'إغلاق') : context.t('I understand and continue', 'أفهم ذلك وأود الاستمرار'),
                      style: FontStyles.getRoboto16(context).copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),

                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
