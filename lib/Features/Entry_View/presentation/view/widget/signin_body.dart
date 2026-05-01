import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Features/Entry_View/presentation/auth/auth_cubit.dart';
import 'package:nervix_app/Features/Entry_View/presentation/auth/auth_state.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/widget/custom_button.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/widget/custom_divider.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/widget/custom_password_field.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/widget/custom_text_field.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/widget/google_button.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';

class SigninBody extends StatefulWidget {
  const SigninBody({super.key, required this.onToggleMode});
  final VoidCallback onToggleMode;

  @override
  State<SigninBody> createState() => _SigninBodyState();
}

class _SigninBodyState extends State<SigninBody> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          if (state.hasCompletedProfile) {
            GoRouter.of(context).go(AppRouter.kHomeView);
          } else {
            GoRouter.of(context).go(AppRouter.kProfileCompletionView);
          }
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60.h),
              Text(
                context.t("Welcome Back", "أهلاً بك مجدداً"),
                style: FontStyles.roboto24.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                context.t("Sign in to continue your monitoring", "سجل دخولك لمتابعة التقارير"),
                style: FontStyles.roboto14.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),
              
              CustomTextField(
                controller: _emailController,
                hintText: context.t("Email Address", "البريد الإلكتروني"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return context.t("Email is required", "البريد الإلكتروني مطلوب");
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return context.t("Enter a valid email address", "أدخل بريداً إلكترونياً صحيحاً");
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              
              CustomPasswordField(
                controller: _passwordController,
                hintText: context.t("Password", "كلمة المرور"),
                validator: (value) {
                  if (value == null || value.isEmpty) return context.t("Password is required", "كلمة المرور مطلوبة");
                  return null;
                },
              ),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => GoRouter.of(context).push(AppRouter.kForgotPasswordView),
                  child: Text(
                    context.t("Forgot Password?", "نسيت كلمة المرور؟"),
                    style: TextStyle(color: kAccentColor, fontSize: 13.sp),
                  ),
                ),
              ),
              
              SizedBox(height: 24.h),
              
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return CustomButton(
                    onPressed: state is AuthLoading ? null : _onLoginPressed,
                    text: state is AuthLoading 
                        ? context.t("Signing in...", "جاري تسجيل الدخول...") 
                        : context.t("Sign In", "تسجيل الدخول"),
                  );
                },
              ),
              
              SizedBox(height: 40.h),
              const CustomDivider(),
              SizedBox(height: 32.h),
              
              GoogleButton(onPressed: () => context.read<AuthCubit>().signInWithGoogle()),
              
              SizedBox(height: 48.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.t("Don't have an account?", "ليس لديك حساب؟"), style: TextStyle(color: Colors.white70, fontSize: 13.sp)),
                  TextButton(
                    onPressed: widget.onToggleMode,
                    child: Text(context.t("Sign Up", "إنشاء حساب"), style: TextStyle(color: kAccentColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
