import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/supabase_timeout.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/profile_model.dart';
import '../models/user_model.dart';

/// Implementation of [AuthRepository] using Supabase remote + Hive local.
///
/// ملاحظة: لا نعتمد على `networkInfo.isConnected` كفحص مسبق لعمليات
/// المصادقة، لأن `connectivity_plus` قد يُرجع `false` مؤقتًا فيَمنع
/// إظهار الخطأ الحقيقي (بيانات دخول خاطئة). الطلب الفعلي سيرمي
/// `SocketException`/`TimeoutException` إن لم يوجد اتصال فعلاً،
/// ونعالج ذلك في الـ catch.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    print('<<<<<<<<<<<[signInWithEmailAndPassword]>>>>>>>>>>>>>');
    try {
      final user = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await localDataSource.cacheUser(UserModel.fromSupabase(user.toJson()));
      await _syncProfile(user.id);
      return Right(user);
    } on AuthException catch (e) {
      print('🟢 [signIn] AuthException: ${e.message} (code: ${e.statusCode})');
      return Left(AuthFailure(message: e.message, code: e.statusCode));
    } on SupabaseTimeoutException catch (e) {
      print('🔴 [signIn] Timeout: ${e.operationName} after ${e.timeout.inSeconds}s');
      return Left(NetworkFailure(
        message: 'Network request timed out. Please check your connection.',
      ));
    } on SupabaseSocketException catch (e) {
      print('🟠 [signIn] SocketException: ${e.message}');
      return Left(NetworkFailure(message: 'Network error'));
    } catch (e) {
      print('⚫ [signIn] Unknown error: $e');
      return Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String university,
  }) async {
    print('<<<<<<<<<<<[signUpWithEmailAndPassword]>>>>>>>>>>>>>');
    try {
      final user = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        university: university,
      );
      await localDataSource.cacheUser(UserModel.fromSupabase(user.toJson()));
      await _syncProfile(user.id);
      return Right(user);
    } on AuthException catch (e) {
      print('🟢 [signUp] AuthException: ${e.message} (code: ${e.statusCode})');
      return Left(AuthFailure(message: e.message, code: e.statusCode));
    } on SupabaseTimeoutException catch (e) {
      print('🔴 [signUp] Timeout: ${e.operationName} after ${e.timeout.inSeconds}s');
      return Left(NetworkFailure(
        message: 'Network request timed out. Please check your connection.',
      ));
    } on SupabaseSocketException catch (e) {
      print('🟠 [signUp] SocketException: ${e.message}');
      return Left(NetworkFailure(message: 'Network error'));
    } catch (e) {
      print('⚫ [signUp] Unknown error: $e');
      return Left(ServerFailure(message: 'Server error'));
    }
  }

  // @override
  // Future<Either<Failure, UserEntity>> signInWithGoogle() async { ... }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // لا ننتظر حذف صف الجهاز — يفعل في الخلفية لتسريع الخروج
      remoteDataSource.deleteDeviceRow().ignore();

      await remoteDataSource.signOut();
      await localDataSource.clearCachedUser();
      await localDataSource.clearCachedProfile();
      return const Right(null);
    } catch (e) {
      print('⚫ [signOut] Error: $e');
      return const Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(
    ProfileEntity profile,
  ) async {
    print('<<<<<<<<<<<[updateProfile]>>>>>>>>>>>>>');
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final updated = await remoteDataSource.updateProfile(
        ProfileModel.fromEntity(profile),
      );
      await localDataSource.cacheProfile(updated);
      return Right(updated);
    } on AuthException catch (e) {
      print('🟢 [updateProfile] AuthException: ${e.message}');
      return Left(AuthFailure(message: e.message, code: e.statusCode));
    } on SupabaseTimeoutException catch (e) {
      print('🔴 [updateProfile] Timeout: ${e.operationName}');
      return Left(NetworkFailure(
        message: 'Network request timed out. Please check your connection.',
      ));
    } on SupabaseSocketException catch (e) {
      print('🟠 [updateProfile] SocketException: ${e.message}');
      return Left(NetworkFailure(message: 'Network error'));
    } catch (e) {
      print('⚫ [updateProfile] Unknown error: $e');
      return Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity?>> getCurrentProfile() async {
    print('<<<<<<<<<<<[getCurrentProfile]>>>>>>>>>>>>>');
    try {
      final remoteUser = remoteDataSource.getCurrentSupabaseUser();
      if (remoteUser == null) {
        return Right(await localDataSource.getCachedProfile());
      }

      try {
        final profile = await remoteDataSource.fetchProfile(remoteUser.id);
        await localDataSource.cacheProfile(profile);
        return Right(profile);
      } catch (e) {
        print('🟠 [getCurrentProfile] fetch failed, fallback to cache: $e');
        return Right(await localDataSource.getCachedProfile());
      }
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// مزامنة صف `profiles` للمستخدم الحالي (أفضل جهد ممكن).
  /// فشل المزامنة (مثلاً الصف لم يُنشأ بعد بواسطة trigger) لا يجب أن
  /// يفشل تسجيل الدخول — يُتجاهل الخطأ.
  Future<void> _syncProfile(String userId) async {
    print('<<<<<<<<<<<[_syncProfile]>>>>>>>>>>>>>');
    try {
      final profile = await remoteDataSource.fetchProfile(userId);
      await localDataSource.cacheProfile(profile);
    } on SupabaseTimeoutException catch (_) {
      print('<<<<<<<<<<<[_syncProfile Timeout]>>>>>>>>>>>>>');
    } on SupabaseSocketException catch (_) {
      print('<<<<<<<<<<<[_syncProfile SocketException]>>>>>>>>>>>>>');
    } catch (e) {
      print('<<<<<<<<<<<[_syncProfile Error: $e]>>>>>>>>>>>>>');
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    print('<<<<<<<<<<<[getCurrentUser]>>>>>>>>>>>>>');
    try {
      final remoteUser = remoteDataSource.getCurrentSupabaseUser();
      if (remoteUser != null) {
        await localDataSource.cacheUser(remoteUser);
        return Right(remoteUser);
      }

      final localUser = await localDataSource.getCachedUser();
      return Right(localUser);
    } catch (e) {
      print('⚫ [getCurrentUser] Error: $e');
      return Left(CacheFailure(message: 'Cache error'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    print('<<<<<<<<<<<[isAuthenticated]>>>>>>>>>>>>>');
    try {
      final remoteUser = remoteDataSource.getCurrentSupabaseUser();
      if (remoteUser != null) return const Right(true);

      final isLoggedIn = await localDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } catch (e) {
      print('⚫ [isAuthenticated] Error: $e');
      return Left(CacheFailure(message: 'Cache error'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    print('<<<<<<<<<<<[resetPassword]>>>>>>>>>>>>>');
    try {
      await remoteDataSource.resetPassword(email: email);
      return const Right(null);
    } on AuthException catch (e) {
      print('🟢 [resetPassword] AuthException: ${e.message}');
      return Left(AuthFailure(message: e.message, code: e.statusCode));
    } on SupabaseTimeoutException catch (e) {
      print('🔴 [resetPassword] Timeout: ${e.operationName}');
      return Left(NetworkFailure(
        message: 'Network request timed out. Please check your connection.',
      ));
    } on SupabaseSocketException catch (e) {
      print('🟠 [resetPassword] SocketException: ${e.message}');
      return Left(NetworkFailure(message: 'Network error'));
    } catch (e) {
      print('⚫ [resetPassword] Unknown error: $e');
      return Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    print('<<<<<<<<<<<[authStateChanges]>>>>>>>>>>>>>');
    return remoteDataSource.authStateChanges.map((authState) {
      final user = authState.session?.user;
      if (user == null) return null;
      return UserModel.fromSupabase(user.toJson());
    });
  }
}