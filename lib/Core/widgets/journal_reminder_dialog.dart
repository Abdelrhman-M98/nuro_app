import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';

class JournalReminderDialog extends StatelessWidget {
  final String tag;
  final String note;
  final VoidCallback onDismiss;

  const JournalReminderDialog({
    super.key,
    required this.tag,
    required this.note,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required String tag,
    required String note,
    required VoidCallback onDismiss,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'JournalReminder',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: JournalReminderDialog(
            tag: tag,
            note: note,
            onDismiss: () {
              Navigator.of(context).pop();
              onDismiss();
            },
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0 * anim1.value,
            sigmaY: 5.0 * anim1.value,
          ),
          child: Transform.scale(
            scale: 0.8 + (0.2 * anim1.value),
            child: Opacity(
              opacity: anim1.value,
              child: child,
            ),
          ),
        );
      },
    );
  }

  Color _tagColor(String tag) {
    switch (tag.trim().toLowerCase()) {
      case 'sleep':
        return const Color(0xFF5C9DFF);
      case 'stress':
        return const Color(0xFFFF8A65);
      case 'medication':
        return const Color(0xFF66BB6A);
      case 'symptom':
        return const Color(0xFFBA68C8);
      default:
        return kAccentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _tagColor(tag);
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 0.85.sw,
        padding: EdgeInsets.all(2.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.5),
              color.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: kSurfaceColor,
            borderRadius: BorderRadius.circular(22.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.alarm_on_rounded, color: color, size: 28.sp),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reminder Due',
                            style: FontStyles.roboto18.copyWith(
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            tag.toUpperCase(),
                            style: FontStyles.roboto12.copyWith(
                              color: color,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
                child: Column(
                  children: [
                    Text(
                      note,
                      textAlign: TextAlign.center,
                      style: FontStyles.roboto16.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    ElevatedButton(
                      onPressed: onDismiss,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 54.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 8,
                        shadowColor: color.withValues(alpha: 0.5),
                      ),
                      child: Text(
                        'Acknowledged',
                        style: FontStyles.roboto16.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
