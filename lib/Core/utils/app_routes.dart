import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nervix_app/Features/Entry_View/Data/repository/auth_repo.dart';
import 'package:nervix_app/Features/Entry_View/presentation/forgot_password/forgot_password_cubit.dart';
import 'package:nervix_app/Features/All_patients/presentation/view/all_patients_view.dart';
import 'package:nervix_app/Features/Home_view/home_view.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/forgot_password_view.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/user_info.dart.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/entry_view.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/Skip/patient_info_view.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/reset_password_view.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/Skip/user_type_view.dart';
import 'package:nervix_app/Features/Entry_View/presentation/view/verification_password_view.dart';
import 'package:nervix_app/Features/Splash_View/presentation/splash_view.dart';
import 'package:nervix_app/Features/Verifying_Data/Presentation/view/verifying_data_view.dart';
import 'package:nervix_app/Features/Home_view/profile_screen.dart';
import 'package:nervix_app/Features/Home_view/medical_history_screen.dart';
import 'package:nervix_app/Features/Home_view/health_journal_screen.dart';
import 'package:nervix_app/Features/Legal/presentation/medical_disclaimer_screen.dart';
import 'package:nervix_app/Features/Legal/presentation/legal_document_screen.dart';
import 'package:nervix_app/Features/Legal/presentation/safety_onboarding_screen.dart';
import 'package:nervix_app/Core/legal/app_legal_content.dart';

abstract class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
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
  static const kProfileView = '/profileView';
  static const kMedicalHistoryView = '/medicalHistoryView';
  static const kMedicalDisclaimerView = '/medicalDisclaimer';
  static const kPrivacyPolicyView = '/privacy';
  static const kTermsOfServiceView = '/terms';
  static const kHealthJournalView = '/healthJournal';
  static const kSafetyOnboardingView = '/safetyOnboarding';

  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
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
        builder: (context, state) {
          return BlocProvider(
            create: (_) =>
                ForgotPasswordCubit(context.read<AuthRepository>()),
            child: const ForgotPasswordView(),
          );
        },
      ),
      GoRoute(
        path: kVerificationPasswordView,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return BlocProvider(
            create: (_) =>
                ForgotPasswordCubit(context.read<AuthRepository>()),
            child: VerificationPasswordView(email: email),
          );
        },
      ),
      GoRoute(
        path: kResetPasswordView,
        builder: (context, state) => ResetPasswordView(),
      ),
      GoRoute(
        path: kProfileView,
        builder: (context, state) {
          final onboarding =
              state.uri.queryParameters['onboarding'] == '1';
          return ProfileScreen(onboarding: onboarding);
        },
      ),
      GoRoute(path: kMedicalHistoryView, builder: (context, state) => const MedicalHistoryScreen()),
      GoRoute(
        path: kMedicalDisclaimerView,
        builder: (context, state) {
          final reviewOnly = state.extra == true;
          return MedicalDisclaimerScreen(reviewOnly: reviewOnly);
        },
      ),
      GoRoute(
        path: kPrivacyPolicyView,
        builder: (context, state) => const LegalDocumentScreen(
          title: 'Privacy Policy',
          paragraphs: AppLegalContent.privacySections,
        ),
      ),
      GoRoute(
        path: kTermsOfServiceView,
        builder: (context, state) => const LegalDocumentScreen(
          title: 'Terms of Service',
          paragraphs: AppLegalContent.termsSections,
        ),
      ),
      GoRoute(
        path: kHealthJournalView,
        builder: (context, state) => const HealthJournalScreen(),
      ),
      GoRoute(
        path: kSafetyOnboardingView,
        builder: (context, state) => const SafetyOnboardingScreen(),
      ),
    ],
  );
}
