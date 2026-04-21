import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/custom_appbar_button.dart';
import 'package:nervix_app/Core/utils/custom_button.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Features/Entry_View/presentation/forgot_password/forgot_password_cubit.dart';

class VerificationPasswordView extends StatefulWidget {
  const VerificationPasswordView({super.key, required this.email});

  final String email;

  @override
  State<VerificationPasswordView> createState() =>
      _VerificationPasswordViewState();
}

class _VerificationPasswordViewState extends State<VerificationPasswordView> {
  static const int _cooldownSeconds = 60;
  int _secondsLeft = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _cooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return '';
    final at = email.indexOf('@');
    if (at <= 1) return email;
    final local = email.substring(0, at);
    final domain = email.substring(at);
    final visible = local.length <= 2 ? local : '${local[0]}***${local[local.length - 1]}';
    return '$visible$domain';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.email.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: kBackgroundGradient),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppBarButton(
                    onPressed: () =>
                        GoRouter.of(context).go(AppRouter.kForgotPasswordView),
                  ),
                  SizedBox(height: 40.h),
                  Text('Missing email', style: FontStyles.roboto24),
                  SizedBox(height: 16.h),
                  Text(
                    'Go back and enter your email to receive a reset link.',
                    style: FontStyles.roboto16,
                  ),
                  SizedBox(height: 32.h),
                  CustomButton(
                    text: 'Back to forgot password',
                    onPressed: () =>
                        GoRouter.of(context).go(AppRouter.kForgotPasswordView),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reset link sent again. Check your inbox and spam.'),
              backgroundColor: Colors.green,
            ),
          );
          _startCooldown();
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
                        GoRouter.of(context).go(AppRouter.kForgotPasswordView),
                  ),
                  SizedBox(height: 32.h),
                  Text('Check your email', style: FontStyles.roboto24),
                  SizedBox(height: 12.h),
                  Text(
                    'We sent a password reset link to:',
                    style: FontStyles.roboto16,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _maskEmail(widget.email),
                    style: FontStyles.roboto16.copyWith(
                      color: kAccentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Open the email on your phone or computer. The link works '
                    'with all common providers (Gmail, Outlook, Yahoo, iCloud, '
                    'company mail, etc.). Check Spam / Junk if you do not see it.',
                    style: FontStyles.roboto12,
                  ),
                  SizedBox(height: 28.h),
                  Text(
                    'After you set a new password in the browser, return here '
                    'and sign in.',
                    style: FontStyles.roboto12.copyWith(color: kOnSurfaceVariantColor),
                  ),
                  SizedBox(height: 32.h),
                  BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                    builder: (context, state) {
                      final sending = state is ForgotPasswordSending;
                      final canResend = _secondsLeft == 0 && !sending;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_secondsLeft > 0)
                            Text(
                              'Resend available in ${_secondsLeft}s',
                              textAlign: TextAlign.center,
                              style: FontStyles.roboto14,
                            ),
                          SizedBox(height: 12.h),
                          CustomButton(
                            text: sending ? 'Sending…' : 'Resend email',
                            onPressed: canResend
                                ? () => context
                                    .read<ForgotPasswordCubit>()
                                    .sendResetEmail(widget.email)
                                : null,
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                  CustomButton(
                    text: 'Back to sign in',
                    onPressed: () =>
                        GoRouter.of(context).go(AppRouter.kLoginView),
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
