import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nervix_app/Core/utils/app_assets.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Features/Splash_View/presentation/widget/signal_wave_painter.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _navigate();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _logoController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: kBackgroundGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // موجات الإشارة في الأعلى
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: MediaQuery.sizeOf(context).height * 0.45,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, _) {
                    return CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: SignalWavePainter(
                        phase: _waveController.value * 2 * math.pi,
                        waveColor: kAccentColor,
                        alpha: 0.5,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                final scale = 0.85 + 0.2 * _pulseController.value;
                final opacity = 0.15 * (1 - _pulseController.value);
                return Container(
                  width: 220.w * scale,
                  height: 220.h * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: kAccentColor.withValues(alpha: opacity),
                      width: 2,
                    ),
                  ),
                );
              },
            ),
          ),
          // اللوجو مع توهج خفيف
          Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, _) {
                return Opacity(
                  opacity: _logoController.value,
                  child: Transform.scale(
                    scale: _logoController.value,
                    child: Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withValues(alpha: 0.4),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: kAccentColor.withValues(alpha: 0.2),
                            blurRadius: 60,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        AppAssets.kSplashImage,
                        width: 160.w,
                        height: 160.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // النص التحتي
          Positioned(
            left: 24,
            right: 24,
            bottom: 80.h,
            child: AnimatedBuilder(
              animation: _textController,
              builder: (context, _) {
                return Opacity(
                  opacity: _textController.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Brain Signal Monitoring',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Alert when epilepsy matters',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kAccentColor.withValues(alpha: 0.9),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _initAnimations() {
    // موجات الإشارة تتحرك باستمرار
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // ظهور اللوجو مع scale و fade
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoController.forward();

    // حلقة النبض (مرة واحدة ثم تتلاشى)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseController.forward();

    // النص يظهر بعد اللوجو
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _textController.forward();
    });
  }

  void _navigate() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      GoRouter.of(context).push(AppRouter.kLoginView);
    });
  }
}
