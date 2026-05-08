import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Features/Doctor_Info/Presentation/view/Widget/action_buttons.dart';
import 'package:nervix_app/Features/Doctor_Info/Presentation/view/Widget/info_row.dart';
import 'package:nervix_app/Features/Home_view/data/models/user_model.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';

class DataSection extends StatelessWidget {
  const DataSection({
    super.key,
    required this.currentState,
    required this.user,
  });

  final String currentState;
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Card(
        margin: EdgeInsets.zero,
        color: kSurfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t("Patient Analysis", "تحليل حالة المريض"),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: kAccentColor,
                ),
              ),
              SizedBox(height: 12.h),
              InfoRow(
                title: context.t("Status:", "الحالة:"), 
                value: currentState == 'Normal' 
                    ? context.t("Normal", "طبيعي") 
                    : currentState
              ),
              SizedBox(height: 6.h),
              InfoRow(
                title: context.t("Analysis:", "التحليل:"), 
                value: context.t("Monitoring Live", "مراقبة مباشرة")
              ),
              SizedBox(height: 12.h),
              ActionButtons(user: user),
            ],
          ),
        ),
      ),
    );
  }
}
