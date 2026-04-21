import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nervix_app/Core/localization/app_localizations.dart';
import 'package:nervix_app/Core/services/journal_due_reminder_service.dart';
import 'package:nervix_app/Core/services/telemetry_service.dart';
import 'package:nervix_app/Core/utils/app_routes.dart';
import 'package:nervix_app/Core/utils/app_theme.dart';
import 'package:nervix_app/Features/Entry_View/Data/repository/auth_repo.dart';
import 'package:nervix_app/Features/Entry_View/presentation/auth/auth_cubit.dart';
import 'package:nervix_app/firebase_options.dart';
import 'package:nervix_app/Core/utils/notification_service.dart';
import 'dart:async';
import 'dart:ui';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await TelemetryService.init();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      TelemetryService.recordError(
        details.exception,
        details.stack ?? StackTrace.current,
        reason: 'FlutterError',
      );
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      TelemetryService.recordError(error, stack, reason: 'PlatformDispatcher');
      return true;
    };
    await NotificationService.init();

    final authRepository = AuthRepository();
    final authCubit = AuthCubit(authRepository);
    runApp(MyApp(authRepository: authRepository, authCubit: authCubit));
    JournalDueReminderService.instance.start();
  }, (error, stack) async {
    await TelemetryService.recordError(
      error,
      stack,
      reason: 'runZonedGuarded',
      fatal: true,
    );
  });
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final AuthCubit authCubit;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.authCubit,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        BlocProvider<AuthCubit>.value(value: authCubit),
      ],
      child: ScreenUtilInit(
        designSize: const Size(412, 917),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            theme: AppTheme.darkTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
