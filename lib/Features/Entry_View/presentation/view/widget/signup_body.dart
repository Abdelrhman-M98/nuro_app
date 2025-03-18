import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:neuro_app/Features/Entry_View/presentation/auth/auth_cubit.dart';
import 'package:neuro_app/Features/Entry_View/presentation/auth/auth_state.dart';

class SignupBody extends StatefulWidget {
  const SignupBody({super.key});

  @override
  State<SignupBody> createState() => _SignupBodyState();
}

class _SignupBodyState extends State<SignupBody> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void validateAndRegister(BuildContext context) {
    if (formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      context.read<AuthCubit>().signUp(
        username: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (state is AuthLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => const Center(child: CircularProgressIndicator()),
          );
        } else {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        } else if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account Created Successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          GoRouter.of(context).go(AppRouter.kHomeView);
        }
      },
      child: SizedBox(
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
                  "Nice to see you for the first time!",
                  style: FontStyles.roboto16,
                ),
              ),
              SizedBox(height: 35.h),

              Form(
                key: formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: nameController,
                      label: "Full Name",
                      icon: FontAwesomeIcons.solidUser,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name is required";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 19.h),
                    CustomTextField(
                      controller: emailController,
                      label: "Email",
                      icon: FontAwesomeIcons.solidEnvelope,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        } else if (!RegExp(
                          r'^[^@]+@[^@]+\.[^@]+',
                        ).hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 19.h),
                    CustomTextField(
                      controller: phoneController,
                      label: "Phone",
                      icon: FontAwesomeIcons.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Phone is required";
                        } else if (!RegExp(r'^[0-9]{10,}$').hasMatch(value)) {
                          return "Enter a valid phone number";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 19.h),
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

              SizedBox(height: 33.h),
              CustomButton(
                onPressed: () => validateAndRegister(context),
                text: "Register Now",
              ),
              SizedBox(height: 67.h),
              CustomDivider(),
              SizedBox(height: 29.h),

              GoogleButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  context.read<AuthCubit>().loginWithGoogle();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
