import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Features/Doctor_Info/Presentation/view/Widget/action_buttons.dart';
import 'package:nervix_app/Features/Doctor_Info/Presentation/view/Widget/info_row.dart';

class DataSection extends StatelessWidget {
  const DataSection({super.key, this.onPressedAudio, this.onPressedDownload});
  final void Function()? onPressedAudio;
  final void Function()? onPressedDownload;

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
                "Patient Info",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: kAccentColor,
                ),
              ),
              SizedBox(height: 12.h),
              InfoRow(title: "Info required:", value: "Info data"),
              SizedBox(height: 6.h),
              InfoRow(title: "Info required:", value: "Info data"),
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerRight,
                child: ActionButtons(
                  onPressedAudio: onPressedAudio,
                  onPressedDownload: onPressedDownload,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
