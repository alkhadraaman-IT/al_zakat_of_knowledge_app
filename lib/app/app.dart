import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/theme_cubit.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root application widget — Stitch Design System.
/// Theme is managed via ThemeCubit for dynamic light/dark toggling.
/// GoRouter instance is created ONCE outside BlocBuilder to prevent navigation resets.
class ZakatAlIlmApp extends StatelessWidget {
  final AuthCubit authCubit;
  final Stream<AuthState> authStateStream;
  final AuthStateTracker authStateTracker;
  final ThemeCubit themeCubit;

  const ZakatAlIlmApp({
    super.key,
    required this.authCubit,
    required this.authStateStream,
    required this.authStateTracker,
    required this.themeCubit,
  });

  @override
  Widget build(BuildContext context) {
    // Create GoRouter ONCE — outside BlocBuilder to prevent navigation resets
    final router = AppRouter.createRouter(authStateStream, authStateTracker);

    return BlocProvider.value(
      value: authCubit,
      child: BlocProvider.value(
        value: themeCubit,
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return BlocBuilder<ThemeCubit, ThemeModeState>(
              builder: (context, themeState) {
                return MaterialApp.router(
                  title: 'زكاة العلم',
                  debugShowCheckedModeBanner: false,
                  // ── Theme driven by ThemeCubit ──────────────────
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeState == ThemeModeState.dark
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  // ── Localization & RTL ─────────────────────────
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  // ── Routing (static — no reset on theme change) ─
                  routerConfig: router,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
