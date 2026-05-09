import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/patient_card_info.dart';
import 'package:nervix_app/Features/Doctor_Info/Presentation/view/Widget/dynamic_line_chart.dart';
import 'package:nervix_app/Features/Home_view/logic/home_cubit.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

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
            patientName: state.user.name ?? context.t('Guest', 'ضيف'),
            age: state.user.age ?? 25,
            condition: state.user.condition,
            imageUrl: state.user.profileImageUrl ?? '',
            profileImageBase64: state.user.profileImageBase64 ?? '',
            signalValue: state.latestSignal,
            gender: state.user.gender ?? context.t('Male', 'ذكر'),
            currentState: state.currentState,
          ),
        ),
        SizedBox(height: 24.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          height: 260.h,
          padding: EdgeInsets.only(top: 20.h, bottom: 12.h, left: 12.w, right: 20.w),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(20.r),

            border: Border.all(
              color: (state.currentState != 'Normal' ? Colors.red : Colors.green).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: DynamicLineChart(
            dataPoints: state.streamingHistory,
            currentState: state.currentState,
          ),
        ),
      ],
    );
  }
}
