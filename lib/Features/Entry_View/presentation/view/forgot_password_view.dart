import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/custom_appbar_button.dart';
import 'package:nervix_app/Core/utils/custom_button.dart';
import 'package:nervix_app/Core/utils/custom_text_field.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Features/Entry_View/presentation/forgot_password/forgot_password_cubit.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: kErrorColor,
            ),
          );
        } else if (state is ForgotPasswordEmailSent) {
          GoRouter.of(context).go(
            AppRouter.kVerificationPasswordView,
            extra: state.email,
          );
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: kBackgroundGradient),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppBarButton(
                    onPressed: () =>
                        GoRouter.of(context).go(AppRouter.kLoginView),
                  ),
                  SizedBox(height: 32.h),
                  Text('Forgot password', style: FontStyles.roboto24),
                  SizedBox(height: 12.h),
                  Text(
                    'Enter the email you use with Nervix. We will send you a '
                    'link to reset your password (works with Gmail, Outlook, '
                    'iCloud, and other providers).',
                    style: FontStyles.roboto16,
                  ),
                  SizedBox(height: 36.h),
                  Form(
                    key: _formKey,
                    child: CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: FontAwesomeIcons.envelope,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        ).hasMatch(value.trim())) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 40.h),
                  BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                    builder: (context, state) {
                      final loading = state is ForgotPasswordSending;
                      return CustomButton(
                        text: loading ? 'Sending…' : 'Send reset link',
                        onPressed: loading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();
                                  context.read<ForgotPasswordCubit>().sendResetEmail(
                                        _emailController.text,
                                      );
                                }
                              },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
