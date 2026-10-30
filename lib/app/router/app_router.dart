import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/di/injection_container.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../../features/articles/presentation/bloc/article_cubit.dart';
import '../../features/notifications/presentation/views/notifications_view.dart';
import '../../features/auth/presentation/views/onboarding_view.dart';
import '../../features/sessions/presentation/views/session_details_view.dart';
import '../../features/profile/presentation/views/profile_view.dart';
import '../../features/search/presentation/views/search_view.dart';
import '../../features/shell/presentation/views/main_shell.dart';
import '../../features/auth/presentation/views/splash_view.dart';
import '../../features/notifications/services/notification_navigator.dart';

class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String profileDetail = '/profile/:id';
  static const String createSession = '/create-session';
  static const String createArticle = '/create-article';
  static const String createMaterial = '/create-material';
  static const String sessionDetails = '/session-details/:id';
  static const String notifications = '/notifications';
  static const String studyTools = '/study-tools';
}

class AuthStateTracker extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void setAuthenticated(bool value) {
    if (_isAuthenticated != value) {
      _isAuthenticated = value;
      notifyListeners();
    }
  }
}

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(
    Stream<AuthState> authStateStream,
    AuthStateTracker authStateTracker,
  ) {
    authStateStream.listen((state) {
      authStateTracker.setAuthenticated(state.session?.user != null);
    });

    // 👇 1. تعريف الراوتر كمتغير بدلاً من إرجاعه مباشرة
    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: authStateTracker,
      redirect: (context, state) {
        final isAuthenticated = authStateTracker.isAuthenticated;
        final isOnSplash = state.matchedLocation == AppRoutes.splash;
        final isOnLogin = state.matchedLocation == AppRoutes.login;
        final isOnRegister = state.matchedLocation == AppRoutes.register;
        final isOnOnboarding = state.matchedLocation == AppRoutes.onboarding;

        if (isOnSplash) return null;

        if (!isAuthenticated) {
          // 👇 قمت بتصحيح خطأ إملائي هنا (كانت تفتقد علامة ||)
          if (isOnLogin || isOnRegister || isOnOnboarding) return null;
          return AppRoutes.login;
        }

        if (isOnLogin || isOnRegister || isOnOnboarding) {
          return AppRoutes.home;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashView(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingView(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterView(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => BlocProvider.value(
            value: sl<ArticleCubit>(),
            child: const MainShell(),
          ),
        ),
        GoRoute(
          path: AppRoutes.search,
          builder: (context, state) => const SearchView(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileView(),
        ),
        GoRoute(
          path: AppRoutes.profileDetail,
          builder: (context, state) =>
              ProfileView(userId: state.pathParameters['id']),
        ),
        // GoRoute(
        //   path: AppRoutes.createSession,
        //   builder: (context, state) => const CreateSessionView(),
        // ),
        GoRoute(
          path: AppRoutes.sessionDetails,
          builder: (context, state) => SessionDetailsView(
            sessionId: state.pathParameters['id'] ?? '',
            isPublisherView: state.uri.queryParameters['isPublisher'] == 'true',
          ),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          builder: (context, state) =>
              const NotificationsPage(), // 👈 غيرها إلى Page
        ),
     
      ],
    );

    // 👇 2. ربط الـ Navigator بالراوتر
    NotificationNavigator.attach(router);

    // 👇 3. إرجاع الراوتر
    return router;
  }
}

