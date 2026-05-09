import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/localization/app_localizations.dart';
import 'package:nervix_app/Core/services/telemetry_service.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyStrip extends StatelessWidget {
  const EmergencyStrip({super.key});

  Future<void> _openEmergency() async {
    final uri = Uri.parse(kEmergencyTelUri);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      await TelemetryService.logEvent('emergency_call_opened');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Semantics(
        button: true,
        label: 'Emergency contact shortcut',
        child: Material(
          color: Colors.red.withValues(alpha: context.isDarkMode ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(14.r),
          child: InkWell(
            onTap: _openEmergency,
            borderRadius: BorderRadius.circular(14.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  Icon(Icons.emergency_share, color: Colors.red.shade300, size: 26.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.emergencyTitle,
                          style: FontStyles.getRoboto14(context).copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${l10n.emergencyHint} ($kEmergencyDisplayNumber)',
                          style: FontStyles.getRoboto12(context).copyWith(
                            color: Colors.red.withValues(alpha: 0.8),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.phone_in_talk, color: Colors.red.shade200),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
