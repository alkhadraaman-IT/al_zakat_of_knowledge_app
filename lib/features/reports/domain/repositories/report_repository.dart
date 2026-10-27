import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/report_entity.dart';

/// Abstract reports repository interface.
abstract class ReportRepository {
  /// Submits a new report.
  /// Returns the created [ReportEntity] on success, [Failure] on error.
  Future<Either<Failure, ReportEntity>> createReport({
    required String reporterId,
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  });
}