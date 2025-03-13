import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_app/Core/utils/app_routes.dart';
import 'package:neuro_app/Core/utils/custom_appbar_button.dart';
import 'package:neuro_app/Core/utils/custom_button.dart';
import 'package:neuro_app/Core/utils/custom_text_field.dart';
import 'package:neuro_app/Core/utils/styles.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 41.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBarButton(
                onPressed: () {
                  GoRouter.of(context).go(AppRouter.kLoginView);
                },
              ),
              SizedBox(height: 55.h),
              Text("Forgot Password", style: FontStyles.roboto24),
              SizedBox(height: 15.h),
              Text(
                "write your username and we will send verification code on your registered account",
                style: FontStyles.roboto16,
              ),
              SizedBox(height: 55.h),
              CustomTextField(
                controller: controller,
                label: "Email",
                icon: FontAwesomeIcons.envelope,
              ),
              SizedBox(height: 178.h),
              CustomButton(
                text: "Send OTP",
                onPressed: () {
                  GoRouter.of(context).go(AppRouter.kVerificationPasswordView);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
