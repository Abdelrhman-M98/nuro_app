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
import 'package:neuro_app/Core/utils/custom_text_button.dart';
import 'package:neuro_app/Features/Entry_View/presentation/auth/auth_cubit.dart';
import 'package:neuro_app/Features/Entry_View/presentation/auth/auth_state.dart';

class SigninBody extends StatefulWidget {
  const SigninBody({super.key});

  @override
  State<SigninBody> createState() => _SigninBodyState();
}

class _SigninBodyState extends State<SigninBody> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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

        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login Successful!"),
              backgroundColor: Colors.green,
            ),
          );
          GoRouter.of(context).go(AppRouter.kHomeView);
        } else if (state is AuthFailure) {
          SnackBar(content: Text(state.error), backgroundColor: Colors.red);
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
                child: Text("Welcome Back", style: FontStyles.roboto24),
              ),
              SizedBox(height: 14.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Nice to see you again",
                  style: FontStyles.roboto16,
                ),
              ),
              SizedBox(height: 75.h),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: emailController,
                      label: "Email",
                      icon: FontAwesomeIcons.envelope,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        } else if (!RegExp(
                          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                        ).hasMatch(value)) {
                          return "Enter a valid email";
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

              CustomButton(onPressed: _validateForm, text: "Login"),
              SizedBox(height: 96.h),
              CustomDivider(),
              SizedBox(height: 46.h),

              GoogleButton(onPressed: _signInWithGoogle),
            ],
          ),
        ),
      ),
    );
  }

  void _validateForm() {
    if (formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      context.read<AuthCubit>().login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    }
  }

  void _signInWithGoogle() {
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().loginWithGoogle();
  }
}
