import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neuro_app/Core/utils/app_assets.dart';
import 'package:neuro_app/Core/utils/const.dart';
import 'package:neuro_app/Core/utils/custom_appbar_button.dart';
import 'package:neuro_app/Features/Verifying_Data/Presentation/view/Widgets/success_validate_widget.dart';
import 'package:neuro_app/Features/Verifying_Data/Presentation/view/Widgets/wait_data_validate_widget.dart';

class VerifyingDataView extends StatelessWidget {
  const VerifyingDataView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isVerified = true;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.kHospitalIcon, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: kPrimaryColor.withOpacity(0.62)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 45.w,
                    vertical: 16.h,
                  ),
                  child: Row(children: [CustomAppBarButton(onPressed: () {})]),
                ),
                isVerified ? SuccessValidation() : WaitDataValidation(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
