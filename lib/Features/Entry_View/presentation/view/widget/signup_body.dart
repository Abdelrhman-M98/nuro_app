// ignore_for_file: avoid_print, body_might_complete_normally_nullable

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

class SignupBody extends StatefulWidget {
  const SignupBody({super.key});

  @override
  State<SignupBody> createState() => _SignupBodyState();
}

class _SignupBodyState extends State<SignupBody> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  void validateForm() {
    if (formKey.currentState!.validate()) {
      print("Form is valid!");
      GoRouter.of(context).go(AppRouter.kUserTypeView);
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
              child: Text("Hello There", style: FontStyles.roboto24),
            ),
            SizedBox(height: 14.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Nice to see you first time",
                style: FontStyles.roboto16,
              ),
            ),
            SizedBox(height: 35.h),

            Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: usernameController,
                    label: "name",
                    icon: FontAwesomeIcons.solidUser,
                    validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return "Username is required";
                      //   } else if (value.length < 4) {
                      //     return "Username must be at least 4 characters";
                      //   }
                      //   return null;
                    },
                  ),
                  SizedBox(height: 19.h),
                  CustomTextField(
                    controller: usernameController,
                    label: "Username",
                    icon: FontAwesomeIcons.solidCircleUser,
                    validator: (value) {
                      // if (value == null || value.isEmpty) {
                      //   return "Username is required";
                      // } else if (value.length < 4) {
                      //   return "Username must be at least 4 characters";
                      // }
                      // return null;
                    },
                  ),
                  SizedBox(height: 19.h),
                  CustomTextField(
                    controller: usernameController,
                    label: "phone",
                    icon: FontAwesomeIcons.squarePhone,
                    validator: (value) {
                      // if (value == null || value.isEmpty) {
                      //   return "Username is required";
                      // } else if (value.length < 4) {
                      //   return "Username must be at least 4 characters";
                      // }
                      // return null;
                    },
                  ),
                  SizedBox(height: 19.h),
                  CustomPasswordField(
                    controller: passwordController,
                    label: "Password",
                    icon: FontAwesomeIcons.lock,
                    validator: (value) {
                      // if (value == null || value.isEmpty) {
                      //   return "Password is required";
                      // } else if (value.length < 6) {
                      //   return "Password must be at least 6 characters";
                      // }
                      // return null;
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 33.h),
            CustomButton(onPressed: validateForm, text: "Register Now"),
            SizedBox(height: 67.h),
            CustomDivider(),
            SizedBox(height: 29.h),
            GoogleButton(),
          ],
        ),
      ),
    );
  }
}
