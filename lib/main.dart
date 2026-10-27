import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/router/app_router.dart';
import 'core/di/injection_container.dart';
import 'core/theme/theme_cubit.dart';
import 'core/utils/bloc_observer.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/favorites/data/models/favorite_item_model.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/notifications/data/datasources/local_notifications_data_source.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

await Hive.initFlutter();
Hive.registerAdapter(FavoriteItemModelAdapter()); // قبل أي openBox
final favoritesBox = await Hive.openBox<FavoriteItemModel>('favorites_v2');

  // تهيئة الـ Firebase باستخدام الإعدادات الخاصة بالمنصة الحالية
 FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler); // قبل runApp
await sl<LocalNotificationsDataSource>().init(
  onTap: (payload) {
    final t = NotificationTarget.parse(payload);
    if (t == null) return;
    router.push(switch (t.kind) {
      NotificationTargetKind.session => '/session-details/${t.id}',
      NotificationTargetKind.material => '/material-details/${t.id}',
      NotificationTargetKind.article => '/article-details/${t.id}',
    });
  },
);
);

  // Initialize localization
  await EasyLocalization.ensureInitialized();

  // Set up BLoC observer for debugging (قبل إنشاء أي Cubit)
  Bloc.observer = AppBlocObserver();

  // Initialize dependency injection (يتضمن تهيئة Hive وتسجيل الـ Adapters)
  await initDependencies();

  // Get the auth cubit from service locator
  final authCubit = sl<AuthCubit>();

  // Check authentication state on startup
  authCubit.checkAuthStatus();

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
      // FavoritesCubit واحد (Singleton) لكل التطبيق، فوق الـ MaterialApp والـ Router.
      // BlocProvider.value ما بيعمل close() للـ Cubit عند التخلص منه.
      child: BlocProvider<FavoritesCubit>.value(
        value: sl<FavoritesCubit>(),
        child: ZakatAlIlmApp(
          authCubit: authCubit,
          authStateStream: authStateStream,
          authStateTracker: authStateTracker,
          themeCubit: themeCubit,
        ),
      ),
    ),
  );
}
