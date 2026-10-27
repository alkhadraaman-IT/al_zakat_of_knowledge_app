import 'dart:io';

import 'package:al_zakat_of_knowledge_app/features/notifications/data/datasources/fcm_data_source.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:http/io_client.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/articles/data/datasources/article_remote_datasource.dart';
import '../../features/articles/data/repositories/article_repository_impl.dart';
import '../../features/articles/domain/repositories/article_repository.dart';
import '../../features/articles/domain/usecases/create_article_usecase.dart';
import '../../features/articles/domain/usecases/get_articles_usecase.dart';
import '../../features/articles/domain/usecases/get_my_articles_usecase.dart';
import '../../features/articles/domain/usecases/get_categories_usecase.dart';
import '../../features/articles/presentation/bloc/article_cubit.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_profile_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/update_profile_usecase.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/favorites/data/datasources/favorites_local_datasource.dart';
import '../../features/favorites/data/models/favorite_item_model.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/domain/usecases/get_favorites_usecase.dart'
    show GetFavoritesUseCase;
import '../../features/favorites/domain/usecases/toggle_favorite_usecase.dart'
    show ToggleFavoriteUseCase;
import '../../features/favorites/presentation/cubit/favorites_cubit.dart';

// 👇 تم تصحيح أسماء الاستيرادات هنا (جمع بدلاً من مفرد)
import '../../features/notifications/data/datasources/device_tokens_remote_data_source.dart';
import '../../features/notifications/data/datasources/incoming_message_bus.dart';
import '../../features/notifications/data/datasources/local_notifications_data_source.dart';
import '../../features/notifications/data/datasources/notification_local_datasource.dart';
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../features/notifications/data/datasources/pending_messages_data_source.dart';
import '../../features/notifications/data/repositories/category_topics_repository_impl.dart';
import '../../features/notifications/data/repositories/notification_scheduler_impl.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/category_topics_repository.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/repositories/notification_scheduler.dart';
import '../../features/notifications/domain/usecases/cancel_session_notifications_usecase.dart';
import '../../features/notifications/domain/usecases/delete_notification_usecase.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/domain/usecases/handle_incoming_notification_usecase.dart';
import '../../features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import '../../features/notifications/domain/usecases/save_local_notification_usecase.dart';
import '../../features/notifications/domain/usecases/schedule_session_dua_usecase.dart';
import '../../features/notifications/domain/usecases/schedule_session_reminder_usecase.dart';
import '../../features/notifications/domain/usecases/sync_category_topics_usecase.dart';
import '../../features/notifications/domain/usecases/watch_notifications_usecase.dart';
import '../../features/notifications/presentation/cubit/notification_cubit.dart';
import '../../features/notifications/services/fcm_service.dart';
import '../../features/notifications/services/fcm_token_manager.dart';
import '../../features/notifications/services/followed_categories_provider.dart';
import '../../features/notifications/services/foreground_message_listener.dart';
import '../../features/notifications/services/incoming_message_pipeline.dart';
import '../../features/notifications/services/notifications_session_coordinator.dart';
import '../../features/notifications/services/pending_messages_drainer.dart';

import '../../features/sessions/data/datasources/session_remote_datasource.dart';
import '../../features/sessions/data/repositories/session_repository_impl.dart'
    hide SessionRemoteDataSourceImpl;
import '../../features/sessions/domain/repositories/session_repository.dart';
import '../../features/sessions/domain/usecases/book_session_usecase.dart';
import '../../features/sessions/domain/usecases/cancel_booking_usecase.dart';
import '../../features/sessions/domain/usecases/create_session_usecase.dart';
import '../../features/sessions/domain/usecases/get_sessions_by_publisher_usecase.dart';
import '../../features/sessions/domain/usecases/get_sessions_usecase.dart';
import '../../features/sessions/domain/usecases/get_user_bookings_usecase.dart';
import '../../features/sessions/presentation/booking_cubit/booking_cubit.dart';
import '../../features/sessions/presentation/session_cubit/session_cubit.dart';
import '../../features/search/presentation/bloc/search_cubit.dart';
import '../../features/reports/data/datasources/report_remote_datasource.dart';
import '../../features/reports/data/repositories/report_repository_impl.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/domain/usecases/create_report_usecase.dart';
import '../../features/study_tools/data/datasources/study_tool_remote_datasource.dart';
import '../../features/study_tools/data/repositories/study_tool_repository_impl.dart';
import '../../features/study_tools/domain/repositories/study_tool_repository.dart';
import '../../features/study_tools/domain/usecases/create_study_tool_usecase.dart';
import '../../features/study_tools/domain/usecases/get_study_tools_by_owner_usecase.dart';
import '../../features/study_tools/domain/usecases/get_study_tools_usecase.dart';
import '../../features/study_tools/presentation/bloc/study_tool_cubit.dart';
import '../../core/services/profile_media_service.dart';
import '../constants/app_constants.dart';
import '../constants/app_timeouts.dart';
import '../network/network_info.dart';
import '../theme/theme_cubit.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Initializes all dependencies.
Future<void> initDependencies() async {
  print('<<<<<<<<<<<[initDependencies]>>>>>>>>>>>>>');
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  await Hive.initFlutter();
  final authBox = await Hive.openBox(AppConstants.authBoxName);
  final userBox = await Hive.openBox(AppConstants.userBoxName);
  final favoritesBox = await Hive.openBox<FavoriteItemModel>(
    AppConstants.favoritesBoxName,
  );
  final favoriteSessionsBox = await Hive.openBox<String>(
    AppConstants.favoriteSessionsBoxName,
  );
  final favoriteToolsBox = await Hive.openBox<String>(
    AppConstants.favoriteToolsBoxName,
  );

  // Validate Supabase configuration before initialization
  if (AppConstants.supabaseUrl.isEmpty ||
      AppConstants.supabaseAnonKey.isEmpty) {
    throw Exception(
      'Supabase is not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY '
      'via --dart-define or update AppConstants with your project credentials.',
    );
  }

  // ignore: deprecated_member_use
  final supabase = await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    httpClient: IOClient(
      HttpClient()
        ..connectionTimeout = AppTimeouts.connection
        ..idleTimeout = AppTimeouts.idle
        ..badCertificateCallback = (cert, host, port) => false,
    ),
  );

  // Session Cubit
  sl.registerLazySingleton<SessionCubit>(
    () => SessionCubit(
      getSessionsUseCase: sl<GetSessionsUseCase>(),
      createSessionUseCase: sl<CreateSessionUseCase>(),
    ),
  );

  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<Box>(() => authBox, instanceName: 'authBox');
  sl.registerLazySingleton<Box>(() => userBox, instanceName: 'userBox');
  sl.registerLazySingleton<Box<FavoriteItemModel>>(
    () => favoritesBox,
    instanceName: 'favoritesBox',
  );
  sl.registerLazySingleton<Box<String>>(
    () => favoriteSessionsBox,
    instanceName: 'favoriteSessionsBox',
  );
  sl.registerLazySingleton<Box<String>>(
    () => favoriteToolsBox,
    instanceName: 'favoriteToolsBox',
  );
  sl.registerLazySingleton<SupabaseClient>(() => supabase.client);
  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.instance,
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<InternetConnectionChecker>()),
  );

  // Data Sources
  sl.registerLazySingleton<ArticleRemoteDataSource>(
    () => ArticleRemoteDataSourceImpl(supabaseClient: sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<StudyToolRemoteDataSource>(
    () => StudyToolRemoteDataSourceImpl(supabaseClient: sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      authBox: sl<Box>(instanceName: 'authBox'),
      userBox: sl<Box>(instanceName: 'userBox'),
      sharedPreferences: sl<SharedPreferences>(),
    ),
  );
  sl.registerLazySingleton<ProfileMediaService>(
    () => ProfileMediaService(supabaseClient: sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(
      favoritesBox: sl<Box<FavoriteItemModel>>(instanceName: 'favoritesBox'),
    ),
  );
  sl.registerLazySingleton<SessionRemoteDataSource>(
    () => SessionRemoteDataSourceImpl(supabaseClient: sl<SupabaseClient>()),
  );

  // Repository
  sl.registerLazySingleton<ArticleRepository>(
    () => ArticleRepositoryImpl(
      remoteDataSource: sl<ArticleRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<StudyToolRepository>(
    () => StudyToolRepositoryImpl(
      remoteDataSource: sl<StudyToolRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(
      localDataSource: sl<FavoritesLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(
      remoteDataSource: sl<SessionRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<CreateArticleUseCase>(
    () => CreateArticleUseCase(sl<ArticleRepository>()),
  );
  sl.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(sl<ArticleRepository>()),
  );
  sl.registerLazySingleton<GetArticlesUseCase>(
    () => GetArticlesUseCase(sl<ArticleRepository>()),
  );
  sl.registerLazySingleton<GetMyArticlesUseCase>(
    () => GetMyArticlesUseCase(sl<ArticleRepository>()),
  );
  sl.registerLazySingleton<GetFavoritesUseCase>(
    () => GetFavoritesUseCase(sl<FavoritesRepository>()),
  );
  sl.registerLazySingleton<ToggleFavoriteUseCase>(
    () => ToggleFavoriteUseCase(sl<FavoritesRepository>()),
  );
  sl.registerLazySingleton<GetUserBookingsUseCase>(
    () => GetUserBookingsUseCase(sl<SessionRepository>()),
  );
  sl.registerLazySingleton<CreateSessionUseCase>(
    () => CreateSessionUseCase(sl<SessionRepository>()),
  );
  sl.registerLazySingleton<GetSessionsUseCase>(
    () => GetSessionsUseCase(sl<SessionRepository>()),
  );
  sl.registerLazySingleton<GetSessionsByPublisherUseCase>(
    () => GetSessionsByPublisherUseCase(sl<SessionRepository>()),
  );
  sl.registerLazySingleton<GetStudyToolsUseCase>(
    () => GetStudyToolsUseCase(sl<StudyToolRepository>()),
  );
  sl.registerLazySingleton<GetStudyToolsByOwnerUseCase>(
    () => GetStudyToolsByOwnerUseCase(sl<StudyToolRepository>()),
  );
  sl.registerLazySingleton<CreateStudyToolUseCase>(
    () => CreateStudyToolUseCase(sl<StudyToolRepository>()),
  );
  sl.registerLazySingleton<BookSessionUseCase>(
    () => BookSessionUseCase(sl<SessionRepository>()),
  );
  sl.registerLazySingleton<CancelBookingUseCase>(
    () => CancelBookingUseCase(sl<SessionRepository>()),
  );
  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(supabaseClient: sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(
      remoteDataSource: sl<ReportRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<CreateReportUseCase>(
    () => CreateReportUseCase(sl<ReportRepository>()),
  );
  sl.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignUpUseCase>(
    () => SignUpUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignInWithGoogleUseCase>(
    () => SignInWithGoogleUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetCurrentProfileUseCase>(
    () => GetCurrentProfileUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(sl<AuthRepository>()),
  );

  // Cubits
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(prefs: sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      signInUseCase: sl<SignInUseCase>(),
      signUpUseCase: sl<SignUpUseCase>(),
      signInWithGoogleUseCase: sl<SignInWithGoogleUseCase>(),
      signOutUseCase: sl<SignOutUseCase>(),
      supabaseClient: sl<SupabaseClient>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
    ),
  );
  sl.registerLazySingleton<StudyToolCubit>(
    () => StudyToolCubit(
      getStudyToolsUseCase: sl<GetStudyToolsUseCase>(),
      createStudyToolUseCase: sl<CreateStudyToolUseCase>(),
    ),
  );
  sl.registerLazySingleton<ArticleCubit>(
    () => ArticleCubit(
      getArticlesUseCase: sl<GetArticlesUseCase>(),
      createArticleUseCase: sl<CreateArticleUseCase>(),
    ),
  );
  sl.registerFactory<BookingCubit>(
    () => BookingCubit(
      bookSessionUseCase: sl<BookSessionUseCase>(),
      cancelBookingUseCase: sl<CancelBookingUseCase>(),
    ),
  );
  sl.registerFactory<SearchCubit>(
    () => SearchCubit(
      getSessionsUseCase: sl<GetSessionsUseCase>(),
      getArticlesUseCase: sl<GetArticlesUseCase>(),
      getStudyToolsUseCase: sl<GetStudyToolsUseCase>(),
      getCategoriesUseCase: sl<GetCategoriesUseCase>(),
    ),
  );
  sl.registerLazySingleton<FavoritesCubit>(() {
    final auth = sl<SupabaseClient>().auth;
    return FavoritesCubit(
      getFavoritesUseCase: sl<GetFavoritesUseCase>(),
      toggleFavoriteUseCase: sl<ToggleFavoriteUseCase>(),
      initialUserId: auth.currentUser?.id,
      userIdChanges: auth.onAuthStateChange.map((e) => e.session?.user.id),
    );
  });
  
} // 👈 تم إغلاق دالة initDependencies هنا بنجاح

// 👇 تم فصل دالة initNotifications لتصبح دالة مستقلة (Top-level)
Future<void> initNotifications(GetIt sl) async {
  final client = Supabase.instance.client;
  final box = await Hive.openBox<String>('notifications_local');
  final metaBox = await Hive.openBox<String>('notifications_meta');
  String? currentUserId() => client.auth.currentUser?.id;

  sl
    // ── data sources ──
    ..registerLazySingleton<NotificationsRemoteDataSource>(
        () => NotificationsRemoteDataSourceImpl(client))
    ..registerLazySingleton<NotificationsLocalDataSource>(
        () => NotificationsLocalDataSourceImpl(box))
    ..registerLazySingleton(() => DeviceTokensRemoteDataSource(client))
    ..registerLazySingleton(() => LocalNotificationsDataSource())
    ..registerLazySingleton(() => FcmDataSource(FirebaseMessaging.instance))
    ..registerLazySingleton(() => PendingMessagesDataSource())
    ..registerLazySingleton(() => IncomingMessageBus())
    // ── repositories ──
    ..registerLazySingleton<NotificationsRepository>(() => NotificationsRepositoryImpl(
          remote: sl(),
          local: sl(),
          bus: sl(),
          currentUserId: currentUserId,
        ))
    ..registerLazySingleton<NotificationScheduler>(() => NotificationSchedulerImpl(sl()))
    ..registerLazySingleton<CategoryTopicsRepository>(
        () => CategoryTopicsRepositoryImpl(sl(), metaBox))
    // ── use cases ──
    ..registerLazySingleton(() => GetNotificationsUseCase(sl()))
    ..registerLazySingleton(() => WatchLocalNotificationChangesUseCase(sl()))
    ..registerLazySingleton(() => MarkNotificationReadUseCase(sl()))
    ..registerLazySingleton(() => MarkAllNotificationsReadUseCase(sl()))
    ..registerLazySingleton(() => DeleteNotificationUseCase(sl()))
    ..registerLazySingleton(() => SaveLocalNotificationUseCase(sl()))
    ..registerLazySingleton(() => ScheduleSessionDuaUseCase(sl(), sl()))
    ..registerLazySingleton(() => ScheduleSessionReminderUseCase(sl(), sl()))
    ..registerLazySingleton(() => CancelSessionNotificationsUseCase(sl(), sl()))
    ..registerLazySingleton(() => SyncCategoryTopicsUseCase(sl()))
    ..registerLazySingleton(() => HandleIncomingNotificationUseCase(sl(), sl(), sl()))
    // ── services (FCM مقسّمة) ──
    ..registerLazySingleton(() => FcmTokenManager(sl(), sl()))
    ..registerLazySingleton(() => IncomingMessagePipeline(
          handle: sl(),
          bus: sl(),
          currentUserId: currentUserId,
        ))
    ..registerLazySingleton(() => ForegroundMessageListener(sl(), sl()))
    ..registerLazySingleton(() => PendingMessagesDrainer(sl(), sl()))
    ..registerLazySingleton(() => FcmService(
          token: sl(),
          foreground: sl(),
          drainer: sl(),
          topics: sl(),
          scheduler: sl(),
          pending: sl(),
          currentUserId: currentUserId,
        ))
    ..registerLazySingleton(() => FollowedCategoriesProvider(client))
    ..registerLazySingleton(
        () => NotificationsSessionCoordinator(client, sl(), sl()))
    // ── presentation: نسخة جديدة كل مرة تُفتح الشاشة ──
    ..registerFactory(() => NotificationsCubit(
          getNotifications: sl(),
          watchLocalChanges: sl(),
          markRead: sl(),
          markAllRead: sl(),
          deleteNotification: sl(),
        ));
}