import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/di/injection_container.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../../features/articles/presentation/bloc/article_cubit.dart';
import '../../features/content_creation/presentation/views/create_session_view.dart';
import '../../features/notifications/presentation/views/notifications_view.dart';
import '../../features/onboarding/presentation/views/onboarding_view.dart';
import '../../features/sessions/presentation/views/session_details_view.dart';
import '../../features/profile/presentation/views/profile_view.dart';
import '../../features/search/presentation/views/search_view.dart';
import '../../features/shell/presentation/views/main_shell.dart';
import '../../features/splash/presentation/views/splash_view.dart';
import '../../features/study_tools/presentation/bloc/study_tool_cubit.dart';
import '../../features/study_tools/presentation/views/study_tools_view.dart';

/// Application route names.
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

/// Tracks authentication state for GoRouter refresh.
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

/// GoRouter configuration with auth state listener.
class AppRouter {
  AppRouter._();

  /// Creates the router with auth state refresh capability.
  static GoRouter createRouter(
    Stream<AuthState> authStateStream,
    AuthStateTracker authStateTracker,
  ) {
    authStateStream.listen((state) {
      authStateTracker.setAuthenticated(state.session?.user != null);
    });

    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: authStateTracker,
      redirect: (context, state) {
        final isAuthenticated = authStateTracker.isAuthenticated;
        final isOnSplash = state.matchedLocation == AppRoutes.splash;
        final isOnLogin = state.matchedLocation == AppRoutes.login;
        final isOnRegister = state.matchedLocation == AppRoutes.register;
        final isOnOnboarding = state.matchedLocation == AppRoutes.onboarding;

        // Splash decides its own destination after the auth check.
        if (isOnSplash) return null;

        if (!isAuthenticated) {
          // Public routes stay accessible to guests.
          if (isOnLogin || isOnRegister || isOnOnboarding) return null;
          // Every other route requires authentication.
          return AppRoutes.login;
        }

        // Authenticated users never see the auth/onboarding gates.
        if (isOnLogin || isOnRegister || isOnOnboarding) {
          return AppRoutes.home;
        }

        // Authenticated on an allowed route — preserve the screen.
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
        GoRoute(
          path: AppRoutes.createSession,
          builder: (context, state) => const CreateSessionView(),
        ),
        GoRoute(
          path: AppRoutes.sessionDetails,
          builder: (context, state) => SessionDetailsView(
            sessionId: state.pathParameters['id'] ?? '',
            isPublisherView: state.uri.queryParameters['isPublisher'] == 'true',
          ),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          builder: (context, state) => const NotificationsView(),
        ),
        GoRoute(
          path: AppRoutes.studyTools,
          builder: (context, state) => BlocProvider.value(
            value: sl<StudyToolCubit>(),
            child: const StudyToolsView(),
          ),
        ),
      ],
    );
  }
}
