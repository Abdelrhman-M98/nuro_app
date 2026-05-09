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
import 'package:nervix_app/Core/utils/theme_extensions.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/widget/custom_text_field.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/widget/google_button.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';

class SignupBody extends StatefulWidget {
  const SignupBody({super.key, required this.onToggleMode});
  final VoidCallback onToggleMode;

  @override
  State<SignupBody> createState() => _SignupBodyState();
}

class _SignupBodyState extends State<SignupBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignupPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUpWithEmail(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  String? _validatePassword(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return context.t("Password is required", "كلمة المرور مطلوبة");
    if (value.length < 8) return context.t("Min 8 characters required", "يجب أن تكون 8 أحرف على الأقل");
    if (!RegExp(r'[0-9]').hasMatch(value)) return context.t("At least one number required", "يجب أن تحتوي على رقم واحد على الأقل");
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) return context.t("At least one symbol required", "يجب أن تحتوي على رمز واحد على الأقل");
    return null;
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
              SizedBox(height: 40.h),
              Text(
                context.t("Create Account", "إنشاء حساب"),
                style: FontStyles.getRoboto24(context).copyWith(color: context.colorScheme.onSurface, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                context.t("Start your journey with us now", "ابدأ رحلتك معنا الآن"),
                style: FontStyles.getRoboto14(context).copyWith(color: context.colorScheme.onSurface.withValues(alpha: 0.7)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              
              CustomTextField(
                controller: _nameController,
                hintText: context.t("Full Name", "الاسم بالكامل"),
                validator: (v) => (v == null || v.isEmpty) ? context.t("Name is required", "الاسم مطلوب") : null,
              ),
              SizedBox(height: 20.h),
              
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
                validator: (v) => _validatePassword(v, context),
              ),
              SizedBox(height: 20.h),
              
              CustomPasswordField(
                controller: _confirmPasswordController,
                hintText: context.t("Confirm Password", "تأكيد كلمة المرور"),
                validator: (v) => v != _passwordController.text ? context.t("Passwords do not match", "كلمات المرور غير متطابقة") : null,
              ),
              
              SizedBox(height: 32.h),
              
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return CustomButton(
                    onPressed: state is AuthLoading ? null : _onSignupPressed,
                    text: state is AuthLoading 
                        ? context.t("Creating account...", "جاري إنشاء الحساب...") 
                        : context.t("Sign Up", "إنشاء حساب"),
                  );
                },
              ),
              
              SizedBox(height: 40.h),
              const CustomDivider(),
              SizedBox(height: 32.h),
              
              GoogleButton(onPressed: () => context.read<AuthCubit>().signInWithGoogle()),
              
              SizedBox(height: 40.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.t("Already have an account?", "لديك حساب بالفعل؟"), style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13.sp)),
                  TextButton(
                    onPressed: widget.onToggleMode,
                    child: Text(context.t("Sign In", "تسجيل الدخول"), style: TextStyle(color: kAccentColor, fontWeight: FontWeight.bold)),
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
