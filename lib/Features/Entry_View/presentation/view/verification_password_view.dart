import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_app/Core/utils/app_routes.dart';
import 'package:neuro_app/Core/utils/custom_appbar_button.dart';
import 'package:neuro_app/Core/utils/custom_button.dart';
import 'package:neuro_app/Core/utils/styles.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/widget/custom_otp_widget.dart';

class VerificationPasswordView extends StatelessWidget {
  const VerificationPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 41.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBarButton(
                onPressed: () {
                  GoRouter.of(context).go(AppRouter.kForgotPasswordView);
                },
              ),
              SizedBox(height: 55.h),
              Text("Forgot Password", style: FontStyles.roboto24),
              SizedBox(height: 15.h),
              Text(
                "we sent code to your phone number +201286952813",
                style: FontStyles.roboto16,
              ),
              SizedBox(height: 55.h),
              CustomOtpWidget(),
              SizedBox(height: 33.h),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "00:50",
                  style: FontStyles.roboto16.copyWith(fontSize: 40.sp),
                ),
              ),
              SizedBox(height: 107.h),
              CustomButton(
                text: "Verify",
                onPressed: () {
                  GoRouter.of(context).go(AppRouter.kResetPasswordView);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
