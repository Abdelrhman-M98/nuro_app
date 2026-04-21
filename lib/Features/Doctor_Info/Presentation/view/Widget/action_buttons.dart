import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/notification_service.dart';
import 'package:nervix_app/Core/utils/pdf_generator.dart';
import 'package:nervix_app/Features/Home_view/data/models/user_model.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: NotificationService.emergencySoundEnabled,
      builder: (context, soundOn, _) {
        return Row(
          children: [
            Expanded(
              child: _ChartControlButton(
                tooltip: soundOn
                    ? 'Sound on — tap for vibrate-only alerts'
                    : 'Vibrate only — tap to turn alarm sound back on',
                icon: soundOn
                    ? Icons.volume_up_rounded
                    : Icons.vibration_rounded,
                subtitle: soundOn ? 'Sound' : 'Silent',
                isHighlighted: !soundOn,
                onPressed: () {
                  NotificationService.toggleEmergencySoundEnabled();
                },
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: _ChartControlButton(
                tooltip: 'Download or share PDF report',
                icon: Icons.cloud_download_rounded,
                subtitle: 'Report',
                isPrimary: true,
                onPressed: () async {
                  await PdfReportGenerator.shareReport(user);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChartControlButton extends StatelessWidget {
  const _ChartControlButton({
    required this.tooltip,
    required this.icon,
    required this.subtitle,
    required this.onPressed,
    this.isPrimary = false,
    this.isHighlighted = false,
  });

  final String tooltip;
  final IconData icon;
  final String subtitle;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final borderColor = isPrimary
        ? kAccentColor
        : (isHighlighted ? kAccentColor.withValues(alpha: 0.85) : kPrimaryColor);
    final bg = isPrimary
        ? kAccentColor.withValues(alpha: 0.18)
        : (isHighlighted
            ? kAccentColor.withValues(alpha: 0.12)
            : kBackgroundColor.withValues(alpha: 0.45));
    final iconColor = isPrimary ? kAccentColor : Colors.white;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.r),
          child: Ink(
            height: 76.h,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 26.sp),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
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
