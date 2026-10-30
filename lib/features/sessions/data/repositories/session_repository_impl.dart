import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/supabase_timeout.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/session_with_profile.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/session_remote_datasource.dart';

/// Implementation of [SessionRepository] using Supabase.
class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SessionRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // ── قراءة ─────────────────────────────────────────────
  @override
  Future<Either<Failure, List<BookingEntity>>> getUserBookings(
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final bookings = await remoteDataSource.getUserBookings(userId);
      return Right(bookings);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return const Left(NetworkFailure(
        message: 'Network request timed out. Please check your connection.',
      ));
    } on SupabaseSocketException catch (_) {
      return const Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return const Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getSessions() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final sessions = await remoteDataSource.getSessions();
      return Right(sessions);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return const Left(NetworkFailure(
        message: 'Network request timed out. Please check your connection.',
      ));
    } on SupabaseSocketException catch (_) {
      return const Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return const Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getSessionsByPublisher(
    String publisherId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final sessions =
          await remoteDataSource.getSessionsByPublisher(publisherId);
      return Right(sessions);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return const Left(NetworkFailure(
        message: 'Network request timed out. Please check your connection.',
      ));
    } on SupabaseSocketException catch (_) {
      return const Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return const Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, SessionWithProfile>> getSessionById(
    String sessionId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final details = await remoteDataSource.getSessionById(sessionId);
      return Right(details);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return const Left(NetworkFailure(
        message: 'Network request timed out. Please check your connection.',
      ));
    } on SupabaseSocketException catch (_) {
      return const Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return const Left(ServerFailure(message: 'Server error'));
    }
  }

  // ── كتابة ─────────────────────────────────────────────
  @override
  Future<Either<Failure, SessionEntity>> createSession({
    required String publisherId,
    required String title,
    required String description,
    required int categoryId,
    required String city,
    required String placeName,
    required String startsAt,
    required int durationMinutes,
    required int maxSeats,
    required double lat,
    required double lng,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final session = await remoteDataSource.createSession(
        publisherId: publisherId,
        title: title,
        description: description,
        categoryId: categoryId,
        city: city,
        placeName: placeName,
        startsAt: startsAt,
        durationMinutes: durationMinutes,
        maxSeats: maxSeats,
        lat: lat,
        lng: lng,
      );
      return Right(session);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return const Left(NetworkFailure(
        message: 'Network request timed out. Please check your connection.',
      ));
    } on SupabaseSocketException catch (_) {
      return const Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return const Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> updateSession({
    required String sessionId,
    required String title,
    required String description,
    required int categoryId,
    required String city,
    required String placeName,
    required String startsAt,
    required int durationMinutes,
    required int maxSeats,
    required double lat,
    required double lng,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final session = await remoteDataSource.updateSession(
        sessionId: sessionId,
        title: title,
        description: description,
        categoryId: categoryId,
        city: city,
        placeName: placeName,
        startsAt: startsAt,
        durationMinutes: durationMinutes,
        maxSeats: maxSeats,
        lat: lat,
        lng: lng,
      );
      return Right(session);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return const Left(NetworkFailure(
        message: 'Network request timed out. Please check your connection.',
      ));
    } on SupabaseSocketException catch (_) {
      return const Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return const Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, void>> bookSession({
    required String sessionId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.bookSession(sessionId: sessionId);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return const Left(NetworkFailure(
        message: 'Network request timed out. Please check your connection.',
      ));
    } on SupabaseSocketException catch (_) {
      return const Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return const Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking({
    required String sessionId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.cancelBooking(sessionId: sessionId);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return const Left(NetworkFailure(
        message: 'Network request timed out. Please check your connection.',
      ));
    } on SupabaseSocketException catch (_) {
      return const Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return const Left(ServerFailure(message: 'Server error'));
    }
  }
}