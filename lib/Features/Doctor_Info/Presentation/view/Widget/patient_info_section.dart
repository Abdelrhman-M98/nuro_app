import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_app/Core/utils/app_routes.dart';
import 'package:neuro_app/Core/utils/custom_appbar_button.dart';
import 'package:neuro_app/Core/utils/patient_card_info.dart';
import 'package:neuro_app/Features/Doctor_Info/Presentation/view/Widget/dynamic_line_chart.dart';

class PatientInfoSection extends StatelessWidget {
  const PatientInfoSection({super.key, required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(12.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: SizedBox(
          height: 655.5.h,
          child: SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    CustomAppBarButton(
                      onPressed: () {
                        GoRouter.of(context).go(AppRouter.kAllPatientsView);
                      },
                    ),
                    SizedBox(width: 30.w),
                    PatientsCardInfo(
                      patientName: 'Mohamed Ali',
                      age: '25',
                      condition: 'Diabetics - Heart',
                      imageUrl: imageUrl,
                      percentage: '92',
                    ),
                  ],
                ),
                SizedBox(height: 39.h),
                SizedBox(
                  width: 381.w,
                  height: 445.h,
                  child: DynamicLineChart(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
