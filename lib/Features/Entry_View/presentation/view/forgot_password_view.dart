import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Features/Entry_View/presentation/auth/auth_cubit.dart';
import 'package:nervix_app/Features/Entry_View/presentation/auth/auth_state.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/widget/custom_button.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/widget/custom_text_field.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(context.t('Reset Password', 'إعادة تعيين كلمة المرور')),
        backgroundColor: kBackgroundColor,
        elevation: 0,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.t('Password reset link sent to your email!', 'تم إرسال رابط إعادة التعيين لبريدك!')),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is PasswordResetFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 48.h),
                Text(
                  context.t("Forgot Password?", "نسيت كلمة المرور؟"),
                  style: FontStyles.roboto24.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  context.t("Enter your email to receive a password reset link.", "أدخل بريدك الإلكتروني لتلقي رابط إعادة تعيين كلمة المرور."),
                  style: FontStyles.roboto14.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48.h),
                CustomTextField(
                  controller: _emailController,
                  hintText: context.t("Email Address", "البريد الإلكتروني"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return context.t("Email is required", "البريد الإلكتروني مطلوب");
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                      return context.t("Enter a valid email", "أدخل بريداً إلكترونياً صحيحاً");
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32.h),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return CustomButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthCubit>().sendPasswordResetEmail(
                                      _emailController.text.trim(),
                                    );
                              }
                            },
                      text: state is AuthLoading 
                        ? context.t("Sending...", "جاري الإرسال...") 
                        : context.t("Send Reset Link", "إرسال رابط التعيين"),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
