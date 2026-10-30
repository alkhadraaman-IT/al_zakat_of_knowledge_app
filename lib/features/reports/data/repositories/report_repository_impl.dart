import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/supabase_timeout.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

/// Implementation of [ReportRepository] using Supabase.
class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ReportRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ReportEntity>> createReport({
    required String reporterId,
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  }) async {
    print('<<<<<<<<<<<[createReport]>>>>>>>>>>>>>');
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'messages.no_internet'.tr()));
    }

    try {
      final report = await remoteDataSource.createReport(
        reporterId: reporterId,
        targetType: targetType,
        targetId: targetId,
        reason: reason,
        details: details,
      );
      return Right(report);
    } on PostgrestException catch (e) {
      print('<<<<<<<<<<<[createReport PostgrestException]>>>>>>>>>>>>>');
      print('Message: ${e.message} (code: ${e.code})');
      return Left(ServerFailure(message: e.message, code: e.code));
    } on SupabaseTimeoutException catch (_) {
      print('<<<<<<<<<<<[createReport Timeout]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'messages.network_timeout'.tr()));
    } on SupabaseSocketException catch (_) {
      print('<<<<<<<<<<<[createReport SocketException]>>>>>>>>>>>>>');
      return Left(NetworkFailure(message: 'messages.network_error'.tr()));
    } catch (e) {
      // Handle reporter ID mismatch — Supabase throws Exception when owner != reporterId
      if (e.toString().contains('Reporter ID mismatch')) {
        return Left(ServerFailure(
          message: 'report.error_permission'.tr(),
          code: '42501',
        ));
      }
      return Left(ServerFailure(message: 'messages.server_error'.tr()));
    }
  }
}