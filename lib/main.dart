import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
import 'features/notifications/domain/entities/notification_target.dart';
import 'features/notifications/services/fcm_background_handler.dart';
import 'features/notifications/services/notification_navigator.dart';
import 'features/notifications/services/notifications_session_coordinator.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase (حسب إعدادات المنصة الحالية)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // يجب أن يكون دالة top-level، وبعد initializeApp، وقبل runApp
  FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);

  // Hive: التهيئة ثم الـ Adapters، وقبل أي openBox
  await Hive.initFlutter();
  Hive.registerAdapter(FavoriteItemModelAdapter());
  final favoritesBox = await Hive.openBox<FavoriteItemModel>('favorites_v2');

  // Localization
  await EasyLocalization.ensureInitialized();

  // BLoC observer (قبل إنشاء أي Cubit)
  Bloc.observer = AppBlocObserver();

  // Dependency injection (يهيّئ Supabase ويسجّل الخدمات)
  await initDependencies();

  // الإشعارات: يجب أن تأتي بعد initDependencies (تحتاج Supabase و sl).
  // أي فشل هنا لا يجوز أن يمنع التطبيق من الإقلاع.
  try {
    await initNotifications(sl);
    await sl<LocalNotificationsDataSource>().init(
      onTap: (payload) => NotificationNavigator.open(NotificationTarget.parse(payload)),
    );
    // تفعيل الإشعارات عند الدخول وإيقافها عند الخروج تلقائياً
    sl<NotificationsSessionCoordinator>().listen();
  } catch (e) {
    debugPrint('[notifications] startup failed: $e');
  }

  // Auth
  final authCubit = sl<AuthCubit>();
  authCubit.checkAuthStatus();
  final authStateStream = Supabase.instance.client.auth.onAuthStateChange;
  final authStateTracker = AuthStateTracker();

  // Theme
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
