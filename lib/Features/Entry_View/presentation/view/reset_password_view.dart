import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/custom_appbar_button.dart';
import 'package:nervix_app/Core/utils/custom_button.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: context.isDarkMode ? kDarkGradient : kLightGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBarButton(
                  onPressed: () =>
                      GoRouter.of(context).go(AppRouter.kLoginView),
                ),
                SizedBox(height: 40.h),
                Text(context.t('Reset via email', 'إعادة التعيين عبر البريد'), style: FontStyles.getRoboto24(context).copyWith(color: context.colorScheme.onSurface)),
                SizedBox(height: 16.h),
                Text(
                  context.t(
                    'Nervix sends a secure link to your email. Open that link in '
                    'your browser to choose a new password. You do not reset the '
                    'password on this screen.',
                    'يرسل نيرفيك رابطاً آمناً إلى بريدك الإلكتروني. افتح هذا الرابط في '
                    'متصفحك لاختيار كلمة مرور جديدة. لا يتم إعادة تعيين '
                    'كلمة المرور في هذه الشاشة.'
                  ),
                  style: FontStyles.getRoboto16(context).copyWith(color: context.colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
                SizedBox(height: 32.h),
                CustomButton(
                  text: context.t('Request a new link', 'طلب رابط جديد'),
                  onPressed: () =>
                      GoRouter.of(context).go(AppRouter.kForgotPasswordView),
                ),
                SizedBox(height: 16.h),
                CustomButton(
                  text: context.t('Back to sign in', 'العودة لتسجيل الدخول'),
                  onPressed: () =>
                      GoRouter.of(context).go(AppRouter.kLoginView),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
