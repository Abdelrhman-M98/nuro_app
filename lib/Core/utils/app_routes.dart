import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_app/Features/All_patients/presentation/view/all_patients_view.dart';
import 'package:neuro_app/Features/Home_view/home_view.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/forgot_password_view.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/user_info.dart.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/entry_view.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/Skip/patient_info_view.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/reset_password_view.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/Skip/user_type_view.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/verification_password_view.dart';
import 'package:neuro_app/Features/Splash_View/presentation/splash_view.dart';
import 'package:neuro_app/Features/Verifying_Data/Presentation/view/verifying_data_view.dart';

abstract class AppRouter {
  static const kLoginView = '/loginView';
  static const kUserTypeView = '/userTypeView';
  static const kPatientInfoView = '/patientInfoView';
  static const kUserInfoView = '/userInfoView';
  static const kHomeView = '/homeView';
  static const kAllPatientsView = '/allPatientsView';
  static const kVerifyDataView = '/verifyDataView';
  static const kForgotPasswordView = '/forgotPasswordView';
  static const kVerificationPasswordView = '/verificationPasswordView';
  static const kResetPasswordView = '/resetPasswordView';

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
      GoRoute(path: kUserInfoView, builder: (context, state) => UserInfoView()),
      GoRoute(path: kHomeView, builder: (context, state) => HomeView()),
      GoRoute(
        path: kAllPatientsView,
        builder: (context, state) => AllPatientsView(),
      ),
      GoRoute(
        path: kVerifyDataView,
        builder: (context, state) => VerifyingDataView(),
      ),
      GoRoute(
        path: kForgotPasswordView,
        builder: (context, state) => ForgotPasswordView(),
      ),
      GoRoute(
        path: kVerificationPasswordView,
        builder: (context, state) => VerificationPasswordView(),
      ),
      GoRoute(
        path: kResetPasswordView,
        builder: (context, state) => ResetPasswordView(),
      ),
    ],
  );
}
