import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/router/app_router.dart';
import 'core/di/injection_container.dart';
import 'core/theme/theme_cubit.dart';
import 'core/utils/bloc_observer.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize localization
  await EasyLocalization.ensureInitialized();

  // Initialize dependency injection
  await initDependencies();

  // Set up BLoC observer for debugging
  Bloc.observer = AppBlocObserver();

  // Get the auth bloc from service locator
  final authBloc = sl<AuthBloc>();

  // Check authentication state on startup
  authBloc.add(const AuthCheckRequested());

  // Create auth state stream for GoRouter refresh
  final authStateStream = Supabase.instance.client.auth.onAuthStateChange;

  // Create auth state tracker
  final authStateTracker = AuthStateTracker();

  // Get theme cubit from service locator
  final themeCubit = sl<ThemeCubit>();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: ZakatAlIlmApp(
        authBloc: authBloc,
        authStateStream: authStateStream,
        authStateTracker: authStateTracker,
        themeCubit: themeCubit,
      ),
    ),
  );
}
