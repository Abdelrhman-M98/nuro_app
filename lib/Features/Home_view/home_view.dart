import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:nervix_app/Core/utils/const.dart';
import 'package:nervix_app/Features/Home_view/Widget/home_view_body.dart';
import 'package:nervix_app/Features/Home_view/logic/home_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      // Trigger a persistence notification when app goes to background
      NotificationService.showStatusNotification(
        title: "Nervix Background Guard",
        body: "Neural monitoring is actively running in the background.",
      );
    }
  }

  void _launchWhatsApp() async {
    const phone = "+20123456789"; // Example doctor number
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _launchWhatsApp(),
          backgroundColor: Colors.green,
          label: const Text("Contact Doctor"),
          icon: const Icon(Icons.chat),
        ),
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
              borderRadius: BorderRadius.circular(40.0.r), // Dynamic rounded corners for modern devices
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
