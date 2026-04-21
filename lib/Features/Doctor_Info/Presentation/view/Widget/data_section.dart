import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Features/Doctor_Info/Presentation/view/Widget/action_buttons.dart';
import 'package:nervix_app/Features/Doctor_Info/Presentation/view/Widget/info_row.dart';
import 'package:nervix_app/Features/Home_view/data/models/user_model.dart';

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
                "Patient Analysis",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: kAccentColor,
                ),
              ),
              SizedBox(height: 12.h),
              InfoRow(title: "Status:", value: currentState),
              SizedBox(height: 6.h),
              const InfoRow(title: "Analysis:", value: "Monitoring Live"),
              SizedBox(height: 12.h),
              ActionButtons(user: user),
            ],
          ),
        ),
      ),
    );
  }
}
