import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nervix_app/Core/services/app_preferences.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

class SafetyOnboardingScreen extends StatefulWidget {
  const SafetyOnboardingScreen({super.key});

  @override
  State<SafetyOnboardingScreen> createState() => _SafetyOnboardingScreenState();
}

class _SafetyOnboardingScreenState extends State<SafetyOnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  List<({IconData icon, String title, String body})> _getPages(BuildContext context) => [
    (
      icon: Icons.health_and_safety_outlined,
      title: context.t('Support tool only', 'أداة مساعدة فقط'),
      body: context.t(
          'Nervix helps you monitor trends, but it does not diagnose or replace clinical care.',
          'نيرفيكس يساعدك في مراقبة الاتجاهات، ولكنه لا يشخص الحالة أو يحل محل الرعاية الطبية.'),
    ),
    (
      icon: Icons.notifications_active_outlined,
      title: context.t('Alerts can vary', 'التنبيهات قد تختلف'),
      body: context.t(
          'Device settings and connectivity can affect alert timing. Keep notifications enabled.',
          'إعدادات الجهاز والاتصال قد تؤثر على توقيت التنبيه. يرجى إبقاء الإشعارات مفعلة.'),
    ),
    (
      icon: Icons.emergency_outlined,
      title: context.t('Act quickly in emergencies', 'تصرف بسرعة في الطوارئ'),
      body: context.t(
          'If symptoms are severe, call your local emergency number immediately.',
          'إذا كانت الأعراض شديدة، اتصل برقم الطوارئ المحلي فوراً.'),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final pages = _getPages(context);
    if (_index < pages.length - 1) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return;
    }
    await AppPreferences.setSafetyOnboardingSeen();
    if (!mounted) return;
    context.go(AppRouter.kMedicalDisclaimerView);
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, i) {
                    final page = pages[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(page.icon, size: 76.sp, color: kAccentColor),
                        SizedBox(height: 20.h),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: FontStyles.getRoboto24(context).copyWith(
                            color: context.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: 14.h),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: FontStyles.getRoboto14(context).copyWith(
                            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                            height: 1.45,
                          ),
                        ),

                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: _index == i ? 20.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _index == i ? kAccentColor : context.colorScheme.onSurface.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(99.r),

                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              FilledButton(
                onPressed: _continue,
                style: FilledButton.styleFrom(
                  backgroundColor: kAccentColor,
                  foregroundColor: Colors.black87,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Text(
                  _index == pages.length - 1 ? context.t('Continue', 'استمرار') : context.t('Next', 'التالي'),
                  style: FontStyles.getRoboto16(context).copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }
}
