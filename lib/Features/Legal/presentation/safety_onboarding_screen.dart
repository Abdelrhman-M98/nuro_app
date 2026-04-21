import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nervix_app/Core/services/app_preferences.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Core/utils/styles.dart';

class SafetyOnboardingScreen extends StatefulWidget {
  const SafetyOnboardingScreen({super.key});

  @override
  State<SafetyOnboardingScreen> createState() => _SafetyOnboardingScreenState();
}

class _SafetyOnboardingScreenState extends State<SafetyOnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const _pages = <({IconData icon, String title, String body})>[
    (
      icon: Icons.health_and_safety_outlined,
      title: 'Support tool only',
      body:
          'Nervix helps you monitor trends, but it does not diagnose or replace clinical care.',
    ),
    (
      icon: Icons.notifications_active_outlined,
      title: 'Alerts can vary',
      body:
          'Device settings and connectivity can affect alert timing. Keep notifications enabled.',
    ),
    (
      icon: Icons.emergency_outlined,
      title: 'Act quickly in emergencies',
      body:
          'If symptoms are severe, call your local emergency number immediately.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_index < _pages.length - 1) {
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
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, i) {
                    final page = _pages[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(page.icon, size: 76.sp, color: kAccentColor),
                        SizedBox(height: 20.h),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: FontStyles.roboto24.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: FontStyles.roboto14.copyWith(
                            color: Colors.white70,
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
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: _index == i ? 20.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _index == i ? kAccentColor : Colors.white24,
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
                  _index == _pages.length - 1 ? 'Continue' : 'Next',
                  style: FontStyles.roboto16.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
