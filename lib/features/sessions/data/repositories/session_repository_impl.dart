import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

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
      return Left(NetworkFailure(message: 'messages.no_internet'.tr()));
    }
    try {
      final bookings = await remoteDataSource.getUserBookings(userId);
      return Right(bookings);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return Left(NetworkFailure(
        message: 'messages.network_timeout'.tr(),
      ));
    } on SupabaseSocketException catch (_) {
      return Left(NetworkFailure(message: 'messages.network_error'.tr()));
    } catch (_) {
      return Left(ServerFailure(message: 'messages.server_error'.tr()));
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getSessions() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'messages.no_internet'.tr()));
    }
    try {
      final sessions = await remoteDataSource.getSessions();
      return Right(sessions);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return Left(NetworkFailure(
        message: 'messages.network_timeout'.tr(),
      ));
    } on SupabaseSocketException catch (_) {
      return Left(NetworkFailure(message: 'messages.network_error'.tr()));
    } catch (_) {
      return Left(ServerFailure(message: 'messages.server_error'.tr()));
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getSessionsByPublisher(
    String publisherId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'messages.no_internet'.tr()));
    }
    try {
      final sessions =
          await remoteDataSource.getSessionsByPublisher(publisherId);
      return Right(sessions);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return Left(NetworkFailure(
        message: 'messages.network_timeout'.tr(),
      ));
    } on SupabaseSocketException catch (_) {
      return Left(NetworkFailure(message: 'messages.network_error'.tr()));
    } catch (_) {
      return Left(ServerFailure(message: 'messages.server_error'.tr()));
    }
  }

  @override
  Future<Either<Failure, SessionWithProfile>> getSessionById(
    String sessionId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'messages.no_internet'.tr()));
    }
    try {
      final details = await remoteDataSource.getSessionById(sessionId);
      return Right(details);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return Left(NetworkFailure(
        message: 'messages.network_timeout'.tr(),
      ));
    } on SupabaseSocketException catch (_) {
      return Left(NetworkFailure(message: 'messages.network_error'.tr()));
    } catch (_) {
      return Left(ServerFailure(message: 'messages.server_error'.tr()));
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
      return Left(NetworkFailure(message: 'messages.no_internet'.tr()));
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
      return Left(NetworkFailure(
        message: 'messages.network_timeout'.tr(),
      ));
    } on SupabaseSocketException catch (_) {
      return Left(NetworkFailure(message: 'messages.network_error'.tr()));
    } catch (_) {
      return Left(ServerFailure(message: 'messages.server_error'.tr()));
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
      return Left(NetworkFailure(message: 'messages.no_internet'.tr()));
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
      return Left(NetworkFailure(
        message: 'messages.network_timeout'.tr(),
      ));
    } on SupabaseSocketException catch (_) {
      return Left(NetworkFailure(message: 'messages.network_error'.tr()));
    } catch (_) {
      return Left(ServerFailure(message: 'messages.server_error'.tr()));
    }
  }

  @override
  Future<Either<Failure, void>> bookSession({
    required String sessionId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'messages.no_internet'.tr()));
    }
    try {
      await remoteDataSource.bookSession(sessionId: sessionId);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return Left(NetworkFailure(
        message: 'messages.network_timeout'.tr(),
      ));
    } on SupabaseSocketException catch (_) {
      return Left(NetworkFailure(message: 'messages.network_error'.tr()));
    } catch (_) {
      return Left(ServerFailure(message: 'messages.server_error'.tr()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking({
    required String sessionId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'messages.no_internet'.tr()));
    }
    try {
      await remoteDataSource.cancelBooking(sessionId: sessionId);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return Left(NetworkFailure(
        message: 'messages.network_timeout'.tr(),
      ));
    } on SupabaseSocketException catch (_) {
      return Left(NetworkFailure(message: 'messages.network_error'.tr()));
    } catch (_) {
      return Left(ServerFailure(message: 'messages.server_error'.tr()));
    }
  }
}