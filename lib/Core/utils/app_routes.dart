import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_app/Features/Entry_View/presentation/view/entry_view.dart';
import 'package:neuro_app/Features/Splash_View/presentation/splash_view.dart';

abstract class AppRouter {
  static const kLoginView = '/loginView';
  static const kBookDetailsView = '/bookDetailsView';
  static const kSearchView = '/searchView';

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
      // GoRoute(
      //   path: kBookDetailsView,
      //   builder: (context, state) => BlocProvider(
      //     create: (context) => SimilarBooksCubit(getIt.get<HomeRepoImpl>()),
      //     child: BookDetailsView(
      //       book: state.extra as BookModel,
      //     ),
      //   ),
      // ),
      // GoRoute(
      //   path: kSearchView,
      //   builder: (context, state) => SearchView(),
      // ),
    ],
  );
}
