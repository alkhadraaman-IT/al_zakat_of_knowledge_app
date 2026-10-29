import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/supabase_timeout.dart';
import '../../domain/entities/study_tool_entity.dart';
import '../../domain/repositories/study_tool_repository.dart';
import '../datasources/study_tool_remote_datasource.dart';

class StudyToolRepositoryImpl implements StudyToolRepository {
  final StudyToolRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  StudyToolRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<StudyToolEntity>>> getStudyTools() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final tools = await remoteDataSource.getStudyTools();
      return Right(tools);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return const Left(NetworkFailure(message: 'Network timeout'));
    } on SupabaseSocketException catch (_) {
      return const Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return const Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, List<StudyToolEntity>>> getStudyToolsByOwner(
    String ownerId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final tools = await remoteDataSource.getStudyToolsByOwner(ownerId);
      return Right(tools);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return const Left(NetworkFailure(message: 'Network timeout'));
    } on SupabaseSocketException catch (_) {
      return const Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return const Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, StudyToolEntity>> createStudyTool({
    required String ownerId,
    required String title,
    required String subject,
    required String studyYear,
    required String university,
    required String city,
    required String pickupPlace,
    required String pickupNotes,
    required int categoryId,
    required String kind,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final tool = await remoteDataSource.createStudyTool(
        ownerId: ownerId,
        title: title,
        subject: subject,
        studyYear: studyYear,
        university: university,
        city: city,
        pickupPlace: pickupPlace,
        pickupNotes: pickupNotes,
        categoryId: categoryId,
        kind: kind,
      );
      return Right(tool);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return const Left(NetworkFailure(message: 'Network timeout'));
    } on SupabaseSocketException catch (_) {
      return const Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return const Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, StudyToolEntity>> updateStudyTool({
    required String toolId,
    required String title,
    required String subject,
    required String studyYear,
    required String university,
    required String city,
    required String pickupPlace,
    required String pickupNotes,
    required int categoryId,
    required String kind,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final tool = await remoteDataSource.updateStudyTool(
        toolId: toolId,
        title: title,
        subject: subject,
        studyYear: studyYear,
        university: university,
        city: city,
        pickupPlace: pickupPlace,
        pickupNotes: pickupNotes,
        categoryId: categoryId,
        kind: kind,
      );
      return Right(tool);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return const Left(NetworkFailure(message: 'Network timeout'));
    } on SupabaseSocketException catch (_) {
      return const Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return const Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStudyTool({
    required String toolId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.deleteStudyTool(toolId: toolId);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return const Left(NetworkFailure(message: 'Network timeout'));
    } on SupabaseSocketException catch (_) {
      return const Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return const Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, void>> takeStudyTool({
    required String toolId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.takeStudyTool(toolId: toolId);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      return const Left(NetworkFailure(message: 'Network timeout'));
    } on SupabaseSocketException catch (_) {
      return const Left(NetworkFailure(message: 'Network error'));
    } catch (_) {
      return const Left(ServerFailure(message: 'Server error'));
    }
  }
}