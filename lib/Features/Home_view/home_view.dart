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
import 'package:nervix_app/Core/localization/translation_extension.dart';
import 'package:nervix_app/Core/utils/theme_extensions.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  bool _actionsExpanded = false;
  late final HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    _homeCubit = HomeCubit()..init();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _homeCubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      NotificationService.showStatusNotification(
        title: context.t("Nervix Background Guard", "حارس نيرفيكس في الخلفية"),
        body: context.t("Neural monitoring is actively running in the background.", "مراقبة النشاط العصبي جارية بفعالية في الخلفية."),
      );
      return;
    }
    if (state == AppLifecycleState.resumed && mounted) {
      final homeState = _homeCubit.state;
      if (homeState is HomeLoaded &&
          homeState.currentState != 'Normal') {
        NotificationService.ensureEmergencyAlarmActive();
      }
    }
  }

  void _launchWhatsApp() async {
    const phone = "+20123456789";
    final url = Uri.parse(
      "https://wa.me/$phone?text=Emergency alert from Nervix!",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _launchEmergencyCall() async {
    final uri = Uri.parse(kEmergencyTelUri);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _toggleActions() {
    setState(() => _actionsExpanded = !_actionsExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeCubit,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              tooltip: context.t('Health notes', 'مذكرات الصحة'),
              onPressed:
                  () => GoRouter.of(context).push(AppRouter.kHealthJournalView),
              icon: Icon(
                Icons.edit_note_rounded,
                color: context.colorScheme.onSurface,
                size: 28,
              ),
            ),
            IconButton(
              tooltip: context.t('Abnormal activity log', 'سجل النشاط غير الطبيعي'),
              onPressed:
                  () =>
                      GoRouter.of(context).push(AppRouter.kMedicalHistoryView),
              icon: Icon(Icons.history, color: context.colorScheme.onSurface, size: 28),
            ),
            IconButton(
              tooltip: context.t('Profile', 'الملف الشخصي'),
              onPressed:
                  () => GoRouter.of(context).push(AppRouter.kProfileView),
              icon: Icon(
                Icons.account_circle_outlined,
                color: context.colorScheme.onSurface,
                size: 28,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 6.h, right: 10.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                crossFadeState:
                    _actionsExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                firstChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _FloatingActionPill(
                      label: context.t('Emergency', 'الطوارئ'),
                      icon: Icons.phone_in_talk_rounded,
                      gradientColors: const [
                        Color(0xFFFF6B6B),
                        Color(0xFFEF5350),
                        Color(0xFFD32F2F),
                      ],
                      shadowColor: Colors.redAccent.withValues(alpha: 0.4),
                      onTap: _launchEmergencyCall,
                    ),
                    SizedBox(height: 10.h),
                    _FloatingActionPill(
                      label: context.t('Contact', 'التواصل'),
                      icon: Icons.forum_rounded,
                      gradientColors: const [
                        Color(0xFF2FE576),
                        Color(0xFF25D366),
                        Color(0xFF128C7E),
                      ],
                      shadowColor: const Color(
                        0xFF25D366,
                      ).withValues(alpha: 0.45),
                      onTap: _launchWhatsApp,
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
                secondChild: const SizedBox.shrink(),
              ),
              FloatingActionButton(
                heroTag: 'quick_actions_fab',
                onPressed: _toggleActions,
                backgroundColor: kAccentColor,
                foregroundColor: Colors.white,
                child: Icon(
                  _actionsExpanded ? Icons.close_rounded : Icons.add_rounded,
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        extendBodyBehindAppBar: true,
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            bool isAbnormal = false;
            if (state is HomeLoaded) {
              isAbnormal = state.currentState != 'Normal';
            }
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: context.isDarkMode ? kDarkGradient : kLightGradient,
                  ),
                  child: const SafeArea(child: HomeViewBody()),
                ),
                if (isAbnormal)
                  Semantics(
                    label:
                        'Alert. Abnormal neural activity may be indicated. Visual warning active.',
                    liveRegion: true,
                    child: const FlashingOverlay(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FloatingActionPill extends StatelessWidget {
  const _FloatingActionPill({
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.shadowColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final Color shadowColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      shadowColor: shadowColor,
      borderRadius: BorderRadius.circular(20.r),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 13.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 22.sp),
                SizedBox(width: 10.w),
                Text(
                  label,
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
