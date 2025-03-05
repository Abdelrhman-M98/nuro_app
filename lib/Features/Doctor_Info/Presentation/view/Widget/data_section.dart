import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_app/Core/utils/const.dart';
import 'package:neuro_app/Features/Doctor_Info/Presentation/view/Widget/action_buttons.dart';
import 'package:neuro_app/Features/Doctor_Info/Presentation/view/Widget/info_row.dart';

class DataSection extends StatelessWidget {
  const DataSection({super.key, this.onPressedAudio, this.onPressedDownload});
  final void Function()? onPressedAudio;
  final void Function()? onPressedDownload;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.r),
            topRight: Radius.circular(12.r),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 29.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                Text(
                  "Patient Info",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Roboto',
                    color: kPrimaryColor,
                  ),
                ),
                SizedBox(height: 16.h),
                InfoRow(title: "info required :", value: "info data"),
                SizedBox(height: 6.h),
                InfoRow(title: "info required :", value: "info data"),
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
      ),
    );
  }
}
