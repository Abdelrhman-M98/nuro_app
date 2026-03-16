import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/patient_card_info.dart';
import 'package:nervix_app/Features/Doctor_Info/Presentation/view/Widget/dynamic_line_chart.dart';
import 'package:nervix_app/Features/Home_view/logic/home_cubit.dart';

class PatientInfoSection extends StatelessWidget {
  const PatientInfoSection({super.key, required this.state});
  final HomeLoaded state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: PatientsCardInfo(
            patientName: state.user.name,
            age: state.user.age,
            condition: state.user.condition,
            imageUrl: state.user.profileImageUrl,
            signalValue: state.latestSignal,
            gender: state.user.gender,
            currentState: state.currentState,
          ),
        ),
        SizedBox(height: 24.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          height: 250.h,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: kSurfaceColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: (state.currentState == 'abnormal' ? Colors.red : Colors.green).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: DynamicLineChart(
            dataPoints: state.signalHistory,
            currentState: state.currentState,
          ),
        ),
      ],
    );
  }
}
