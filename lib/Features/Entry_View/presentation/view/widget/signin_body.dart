// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_app/Core/utils/app_routes.dart';
import 'package:neuro_app/Core/utils/custom_button.dart';
import 'package:neuro_app/Core/utils/custom_divider.dart';
import 'package:neuro_app/Core/utils/custom_password_field.dart';
import 'package:neuro_app/Core/utils/custom_text_field.dart';
import 'package:neuro_app/Core/utils/google_button.dart';
import 'package:neuro_app/Core/utils/styles.dart';
import 'package:neuro_app/Core/utils/custom_text_button.dart';

class SigninBody extends StatefulWidget {
  const SigninBody({super.key});

  @override
  State<SigninBody> createState() => _SigninBodyState();
}

class _SigninBodyState extends State<SigninBody> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void validateForm() {
    if (formKey.currentState!.validate()) {
      print("Form is valid!");
    } else {
      print("Form has errors!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 48.w),
        child: Column(
          children: [
            SizedBox(height: 31.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Welcome Back", style: FontStyles.roboto24),
            ),
            SizedBox(height: 14.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Nice to see you again", style: FontStyles.roboto16),
            ),
            SizedBox(height: 75.h),

            Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: usernameController,
                    label: "Username",
                    icon: FontAwesomeIcons.solidUser,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Username is required";
                      } else if (value.length < 4) {
                        return "Username must be at least 4 characters";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 34.h),
                  CustomPasswordField(
                    controller: passwordController,
                    label: "Password",
                    icon: FontAwesomeIcons.lock,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      } else if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 25.h),
            Align(
              alignment: Alignment.centerRight,
              child: CustomTextButton(
                text: "Forgot Password?",
                onPressed: () {
                  GoRouter.of(context).go(AppRouter.kForgotPasswordView);
                },
              ),
            ),
            SizedBox(height: 25.h),
            CustomButton(onPressed: validateForm, text: "Login"),
            SizedBox(height: 96.h),
            CustomDivider(),
            SizedBox(height: 46.h),
            GoogleButton(),
          ],
        ),
      ),
    );
  }
}
