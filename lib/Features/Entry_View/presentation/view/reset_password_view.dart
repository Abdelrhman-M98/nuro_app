import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_app/Core/utils/app_routes.dart';
import 'package:neuro_app/Core/utils/custom_appbar_button.dart';
import 'package:neuro_app/Core/utils/custom_button.dart';
import 'package:neuro_app/Core/utils/custom_password_field.dart';
import 'package:neuro_app/Core/utils/styles.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 41.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBarButton(
                onPressed: () {
                  GoRouter.of(context).go(AppRouter.kVerificationPasswordView);
                },
              ),
              SizedBox(height: 55.h),
              Text("Forgot Password", style: FontStyles.roboto24),
              SizedBox(height: 15.h),
              Text(
                "Reset a strong password you can remember it",
                style: FontStyles.roboto16,
              ),
              SizedBox(height: 70.h),
              CustomPasswordField(
                controller: passwordController,
                label: "Password",
                icon: FontAwesomeIcons.lock,
                validator: (value) {},
              ),
              SizedBox(height: 35.h),
              CustomPasswordField(
                controller: confirmPasswordController,
                label: "Confirm Password",
                icon: FontAwesomeIcons.lock,
                validator: (value) {},
              ),
              SizedBox(height: 59.h),
              CustomButton(text: "Reset Password", onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
