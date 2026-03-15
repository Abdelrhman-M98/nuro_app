import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/custom_appbar_button.dart';
import 'package:nervix_app/Core/utils/patient_card_info.dart';
import 'package:nervix_app/Features/Doctor_Info/Presentation/view/Widget/dynamic_line_chart.dart';

class PatientInfoSection extends StatelessWidget {
  const PatientInfoSection({super.key, required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      color: kSurfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CustomAppBarButton(
                  onPressed: () =>
                      GoRouter.of(context).go(AppRouter.kAllPatientsView),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PatientsCardInfo(
                    patientName: 'Mohamed Ali',
                    age: '25',
                    condition: 'Diabetics - Heart',
                    imageUrl: imageUrl,
                    percentage: '92',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 220.h,
              child: const DynamicLineChart(),
            ),
          ],
        ),
      ),
    );
  }
}
