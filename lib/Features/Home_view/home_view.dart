import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Features/Home_view/Widget/home_view_body.dart';
import 'package:nervix_app/Features/Home_view/logic/home_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/utils/styles.dart';
import 'package:nervix_app/Core/utils/notification_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      NotificationService.showStatusNotification(
        title: "Nervix Background Guard",
        body: "Neural monitoring is actively running in the background.",
      );
    }
  }

  void _launchWhatsApp() async {
    const phone = "+20123456789";
    final url = Uri.parse("https://wa.me/$phone?text=Emergency alert from Nervix!");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..init(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () => GoRouter.of(context).push(AppRouter.kMedicalHistoryView),
              icon: const Icon(
                Icons.history,
                color: Colors.white,
                size: 28,
              ),
            ),
            IconButton(
              onPressed: () => GoRouter.of(context).push(AppRouter.kProfileView),
              icon: const Icon(
                Icons.account_circle_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 6.h, right: 2.w),
          child: Material(
            elevation: 10,
            shadowColor: const Color(0xFF25D366).withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20.r),
            color: Colors.transparent,
            child: InkWell(
              onTap: _launchWhatsApp,
              borderRadius: BorderRadius.circular(20.r),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2FE576),
                      Color(0xFF25D366),
                      Color(0xFF128C7E),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 13.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.forum_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Contact',
                        style: FontStyles.roboto16.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        extendBodyBehindAppBar: true,
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            bool isAbnormal = false;
            if (state is HomeLoaded) {
              isAbnormal = state.currentState.toLowerCase() == 'abnormal';
            }
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(gradient: kBackgroundGradient),
                  child: const SafeArea(child: HomeViewBody()),
                ),
                if (isAbnormal) const FlashingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class FlashingOverlay extends StatefulWidget {
  const FlashingOverlay({super.key});

  @override
  State<FlashingOverlay> createState() => _FlashingOverlayState();
}

class _FlashingOverlayState extends State<FlashingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.0.r),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.5 * _controller.value),
                width: 8 + (4 * _controller.value),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3 * _controller.value),
                  blurRadius: 15.0.r,
                  spreadRadius: 5.0.r,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.red.withValues(alpha: 0.15 * _controller.value),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.red.withValues(alpha: 0.15 * _controller.value),
                  ],
                  stops: const [0, 0.2, 0.8, 1],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
