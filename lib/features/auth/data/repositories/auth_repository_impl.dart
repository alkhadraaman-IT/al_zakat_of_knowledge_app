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
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final user = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await localDataSource.cacheUser(UserModel.fromSupabase(user.toJson()));
      await _syncProfile(user.id);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.statusCode));
    } on SupabaseTimeoutException catch (_) {
      print('<<<<<<<<<<<[signInWithEmailAndPassword Timeout]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network request timed out. Please check your connection.'));
    } on SupabaseSocketException catch (_) {
      print('<<<<<<<<<<<[signInWithEmailAndPassword SocketException]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
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
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

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
      return Left(AuthFailure(message: e.message, code: e.statusCode));
    } on SupabaseTimeoutException catch (_) {
      print('<<<<<<<<<<<[signUpWithEmailAndPassword Timeout]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network request timed out. Please check your connection.'));
    } on SupabaseSocketException catch (_) {
      print('<<<<<<<<<<<[signUpWithEmailAndPassword SocketException]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return Left(ServerFailure(message: 'Server error'));
    }
  }

  // @override
  // Future<Either<Failure, UserEntity>> signInWithGoogle() async {
  //   print('<<<<<<<<<<<[signInWithGoogle]>>>>>>>>>>>>>');
  //   if (!await networkInfo.isConnected) {
  //     return const Left(NetworkFailure(message: 'No internet connection'));
  //   }

  //   try {
  //     final user = await remoteDataSource.signInWithGoogle();
  //     await localDataSource.cacheUser(UserModel.fromSupabase(user.toJson()));
  //     await _syncProfile(user.id);
  //     return Right(user);
  //   } on AuthException catch (e) {
  //     return Left(AuthFailure(message: e.message, code: e.statusCode));
  //   } on SupabaseTimeoutException catch (_) {
  //     print('<<<<<<<<<<<[signInWithGoogle Timeout]>>>>>>>>>>>>>');
  //     return Left(NetworkFailure(message: 'Network request timed out. Please check your connection.'));
  //   } on SupabaseSocketException catch (_) {
  //     print('<<<<<<<<<<<[signInWithGoogle SocketException]>>>>>>>>>>>>>');
  //     return Left(NetworkFailure(message: 'Network error'));
  //   } catch (_) {
  //     return Left(ServerFailure(message: 'Server error'));
  //   }
  // }

  @override
Future<Either<Failure, void>> signOut() async {
  try {
    // 👈 لا ننتظر حذف الجهاز (يفضل أن يكون في الخلفية لتسريع الخروج)
    remoteDataSource.deleteDeviceRow().ignore(); 
    
    await remoteDataSource.signOut();
    await localDataSource.clearCachedUser();
    await localDataSource.clearCachedProfile();
    return const Right(null);
  } catch (_) {
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
      return Left(AuthFailure(message: e.message, code: e.statusCode));
    } on SupabaseTimeoutException catch (_) {
      print('<<<<<<<<<<<[updateProfile Timeout]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network request timed out. Please check your connection.'));
    } on SupabaseSocketException catch (_) {
      print('<<<<<<<<<<<[updateProfile SocketException]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
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

      // Fresh fetch — fall back to the cached row
      // when offline or the row does not exist yet.
      try {
        final profile = await remoteDataSource.fetchProfile(remoteUser.id);
        await localDataSource.cacheProfile(profile);
        return Right(profile);
      } catch (e) {
        return Right(await localDataSource.getCachedProfile());
      }
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  /// Best-effort sync of the logged-in user's `profiles` row.
  ///
  /// A missing profile row (e.g. one created asynchronously by a
  /// database trigger) must never fail the sign-in flow — the sync
  /// is skipped in that case and the cached profile stays absent.
  Future<void> _syncProfile(String userId) async {
    print('<<<<<<<<<<<[_syncProfile]>>>>>>>>>>>>>');
    try {
      final profile = await remoteDataSource.fetchProfile(userId);
      await localDataSource.cacheProfile(profile);
    } on SupabaseTimeoutException catch (_) {
      print('<<<<<<<<<<<[_syncProfile Timeout]>>>>>>>>>>>>>');
      // Non-fatal: the profile row may not exist yet or network timed out.
    } on SupabaseSocketException catch (_) {
      print('<<<<<<<<<<<[_syncProfile SocketException]>>>>>>>>>>>>>');
      // Non-fatal: network error.
    } catch (_) {
      // Non-fatal: the profile row may not exist yet.
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    print('<<<<<<<<<<<[getCurrentUser]>>>>>>>>>>>>>');
    try {
      // Try remote first
      final remoteUser = remoteDataSource.getCurrentSupabaseUser();
      if (remoteUser != null) {
        // Keep the Hive cache in sync with the live session: a
        // cold-start deep link restores the session without
        // running a sign-in use case, so the cache would
        // otherwise stay empty until the next sign-in.
        await localDataSource.cacheUser(remoteUser);
        return Right(remoteUser);
      }

      // Fallback to local cache
      final localUser = await localDataSource.getCachedUser();
      return Right(localUser);
    } catch (_) {
      return Left(CacheFailure(message: 'Cache error'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    print('<<<<<<<<<<<[isAuthenticated]>>>>>>>>>>>>>');
    try {
      final remoteUser = remoteDataSource.getCurrentSupabaseUser();
      if (remoteUser != null) {
        return const Right(true);
      }

      final isLoggedIn = await localDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } catch (_) {
      return Left(CacheFailure(message: 'Cache error'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    print('<<<<<<<<<<<[resetPassword]>>>>>>>>>>>>>');
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      await remoteDataSource.resetPassword(email: email);
      return const Right(null);
    } on SupabaseTimeoutException catch (_) {
      print('<<<<<<<<<<<[resetPassword Timeout]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network request timed out. Please check your connection.'));
    } on SupabaseSocketException catch (_) {
      print('<<<<<<<<<<<[resetPassword SocketException]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
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
