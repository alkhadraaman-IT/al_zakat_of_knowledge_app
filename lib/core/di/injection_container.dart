import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../core/services/profile_media_service.dart';
import '../constants/app_constants.dart';
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

  // Validate Supabase configuration before initialization
  if (AppConstants.supabaseUrl.isEmpty || AppConstants.supabaseAnonKey.isEmpty) {
    throw Exception(
      'Supabase is not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY '
      'via --dart-define or update AppConstants with your project credentials.',
    );
  }

  // ignore: deprecated_member_use
  final supabase = await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<Box>(() => authBox, instanceName: 'authBox');
  sl.registerLazySingleton<Box>(() => userBox, instanceName: 'userBox');
  sl.registerLazySingleton<SupabaseClient>(() => supabase.client);
  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.instance,
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<InternetConnectionChecker>()),
  );

  // Data Sources
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

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use Cases
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

  // Theme Cubit
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(prefs: sl<SharedPreferences>()),
  );

  // BLoC
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      signInUseCase: sl<SignInUseCase>(),
      signUpUseCase: sl<SignUpUseCase>(),
      signInWithGoogleUseCase: sl<SignInWithGoogleUseCase>(),
      signOutUseCase: sl<SignOutUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
    ),
  );
}
