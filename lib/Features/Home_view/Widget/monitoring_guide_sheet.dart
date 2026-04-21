import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/services/app_preferences.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';

Future<void> showMonitoringGuideIfNeeded(BuildContext context) async {
  final seen = await AppPreferences.hasSeenMonitoringGuide();
  if (!context.mounted) return;
  if (seen) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _MonitoringGuideBody(),
  );
  await AppPreferences.setMonitoringGuideSeen();
}

Future<void> showMonitoringGuideManual(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _MonitoringGuideBody(),
  );
}

class _MonitoringGuideBody extends StatelessWidget {
  const _MonitoringGuideBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: kAccentColor.withValues(alpha: 0.35)),
      ),
      padding: EdgeInsets.fromLTRB(22.w, 12.h, 22.w, 24.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'How monitoring works',
              style: FontStyles.roboto18.copyWith(
                color: kOnBackgroundColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 14.h),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GuideLine(
                    icon: Icons.show_chart,
                    text:
                        'The chart shows recent neural signal values streamed live when your setup is connected.',
                  ),
                  SizedBox(height: 14.h),
                  _GuideLine(
                    icon: Icons.health_and_safety_outlined,
                    text:
                        'When status is abnormal, you get a visual highlight and an alert (sound or vibration based on your choice).',
                  ),
                  SizedBox(height: 14.h),
                  _GuideLine(
                    icon: Icons.volume_up_rounded,
                    text:
                        'Use the Sound / Silent buttons to choose audible alarm or vibrate-only notifications.',
                  ),
                  SizedBox(height: 14.h),
                  _GuideLine(
                    icon: Icons.cloud_download_rounded,
                    text:
                        'Export or share a PDF report from the cloud button when you need a summary for your doctor.',
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kAccentColor,
                foregroundColor: Colors.black87,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: FontStyles.roboto16.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideLine extends StatelessWidget {
  const _GuideLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: kAccentColor, size: 22.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: FontStyles.roboto14.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
