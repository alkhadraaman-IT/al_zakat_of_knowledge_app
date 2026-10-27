import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/report_entity.dart';
import '../repositories/report_repository.dart';

/// Use case for submitting a new report.
class CreateReportUseCase {
  final ReportRepository reportRepository;

  const CreateReportUseCase(this.reportRepository);

  Future<Either<Failure, ReportEntity>> call({
    required String reporterId,
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  }) {
    print('<<<<<<<<<<<[CreateReportUseCase.call]>>>>>>>>>>>>>');
    return reportRepository.createReport(
      reporterId: reporterId,
      targetType: targetType,
      targetId: targetId,
      reason: reason,
      details: details,
    );
  }
}