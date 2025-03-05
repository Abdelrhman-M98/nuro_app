import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_app/Core/utils/app_routes.dart';
import 'package:neuro_app/Core/utils/custom_appbar_button.dart';
import 'package:neuro_app/Core/utils/custom_button.dart';

class PatientInfoView extends StatelessWidget {
  const PatientInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 45.w),
          child: Column(
            children: [
              CustomAppBarButton(
                onPressed: () {
                  GoRouter.of(context).go(AppRouter.kUserTypeView);
                },
              ),
              CustomButton(
                text: "Verify Data",
                onPressed: () {
                  GoRouter.of(context).go(AppRouter.kVerifyDataView);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
