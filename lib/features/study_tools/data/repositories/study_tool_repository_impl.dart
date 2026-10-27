import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/supabase_timeout.dart';
import '../../domain/entities/study_tool_entity.dart';
import '../../domain/repositories/study_tool_repository.dart';
import '../datasources/study_tool_remote_datasource.dart';

/// Implementation of [StudyToolRepository] using Supabase.
class StudyToolRepositoryImpl implements StudyToolRepository {
  final StudyToolRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  StudyToolRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<StudyToolEntity>>> getStudyTools() async {
    print('<<<<<<<<<<<[getStudyTools]>>>>>>>>>>>>>');
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final tools = await remoteDataSource.getStudyTools();
      return Right(tools);
    } on PostgrestException catch (e) {
      // Detailed logging — every backend rejection
      // (RLS, undefined table, ...) is traced. An
      // empty result is a legitimate empty list,
      // never sample data.
      print('<<<<<<<<<<<[getStudyTools PostgrestException]>>>>>>>>>>>>>');
      print('Message: ${e.message} (code: ${e.code})');
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      print('<<<<<<<<<<<[getStudyTools Timeout]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network request timed out. Please check your connection.'));
    } on SupabaseSocketException catch (_) {
      print('<<<<<<<<<<<[getStudyTools SocketException]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network error'));
    } catch (e) {
      print('<<<<<<<<<<<[Repository Error]>>>>>>>>>>>>>');
      print('Exception: $e');
      return Left(ServerFailure(message: 'Server error'));
    }
  }

  @override
  Future<Either<Failure, List<StudyToolEntity>>> getStudyToolsByOwner(
    String ownerId,
  ) async {
    print('<<<<<<<<<<<[getStudyToolsByOwner]>>>>>>>>>>>>>');
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final tools = await remoteDataSource.getStudyToolsByOwner(ownerId);
      return Right(tools);
    } on PostgrestException catch (e) {
      // Detailed logging — every backend rejection
      // (RLS, undefined table, ...) is traced. An
      // empty result is a legitimate empty list,
      // never sample data.
      print('<<<<<<<<<<<[getStudyToolsByOwner PostgrestException]>>>>>>>>>>>>>');
      print('Message: ${e.message} (code: ${e.code})');
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      print('<<<<<<<<<<<[getStudyToolsByOwner Timeout]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network request timed out. Please check your connection.'));
    } on SupabaseSocketException catch (_) {
      print('<<<<<<<<<<<[getStudyToolsByOwner SocketException]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network error'));
    } catch (e) {
      print('<<<<<<<<<<<[Repository Error]>>>>>>>>>>>>>');
      print('Exception: $e');
      return Left(ServerFailure(message: 'Server error'));
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
    print('<<<<<<<<<<<[createStudyTool]>>>>>>>>>>>>>');
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final material = await remoteDataSource.createStudyTool(
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
      return Right(material);
    } on PostgrestException catch (e) {
      print('<<<<<<<<<<<[createStudyTool PostgrestException]>>>>>>>>>>>>>');
      print('Message: ${e.message} (code: ${e.code})');
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      print('<<<<<<<<<<<[createStudyTool Timeout]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network request timed out. Please check your connection.'));
    } on SupabaseSocketException catch (_) {
      print('<<<<<<<<<<<[createStudyTool SocketException]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'Network error'));
    } catch (e) {
      print('<<<<<<<<<<<[Repository Error]>>>>>>>>>>>>>');
      print('Exception: $e');
      return Left(ServerFailure(message: 'Server error'));
    }
  }
}
