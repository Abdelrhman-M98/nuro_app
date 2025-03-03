import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/doctor_info_view.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/entry_view.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/patient_info_view.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/user_type_view.dart';
import 'package:neuro_app/Features/Splash_View/presentation/splash_view.dart';

abstract class AppRouter {
  static const kLoginView = '/loginView';
  static const kUserTypeView = '/userTypeView';
  static const kPatientInfoView = '/patientInfoView';
  static const kDoctorInfoView = '/doctorInfoView';

  static final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => SplashView()),
      GoRoute(
        path: AppRouter.kLoginView,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: EntryView(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(path: kUserTypeView, builder: (context, state) => UserTypeView()),
      GoRoute(
        path: kPatientInfoView,
        builder: (context, state) => PatientInfoView(),
      ),
      GoRoute(
        path: kDoctorInfoView,
        builder: (context, state) => DoctorInfoView(),
      ),
    ],
  );
}
