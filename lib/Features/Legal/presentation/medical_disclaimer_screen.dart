import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nervix_app/Core/services/app_preferences.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';

class MedicalDisclaimerScreen extends StatelessWidget {
  const MedicalDisclaimerScreen({super.key, this.reviewOnly = false});

  /// When true (e.g. opened from Profile), show Close only — acceptance was already recorded.
  final bool reviewOnly;

  static const List<String> _points = [
    'Nervix is designed to assist with monitoring contextual information. It does not diagnose, treat, or prevent any medical condition.',
    'Readings and alerts are informational. False positives or missed events can occur. Do not rely solely on the app for critical decisions.',
    'Background behavior and notifications may vary by device and operating system policies. Monitoring may pause or be limited when the app is not active.',
    'Always follow your clinician\'s advice. Use local emergency services in life-threatening situations.',
    'By continuing, you acknowledge these limits and agree to use the app responsibly.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
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
                  'Important notice',
                  textAlign: TextAlign.center,
                  style: FontStyles.roboto24.copyWith(
                    color: kOnBackgroundColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Please read before using Nervix',
                  textAlign: TextAlign.center,
                  style: FontStyles.roboto14.copyWith(
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 22.h),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    radius: Radius.circular(8.r),
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _points.length,
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
                                _points[i],
                                style: FontStyles.roboto14.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
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
                      reviewOnly ? 'Close' : 'I understand and continue',
                      style: FontStyles.roboto16.copyWith(
                        fontWeight: FontWeight.w800,
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
