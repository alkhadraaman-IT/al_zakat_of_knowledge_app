import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_report_usecase.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final CreateReportUseCase createReportUseCase;

  ReportCubit({required this.createReportUseCase})
      : super(const ReportInitial());

  Future<void> submitReport({
    required String reporterId,
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  }) async {
    emit(const ReportSubmitting());

    final result = await createReportUseCase(
      reporterId: reporterId,
      targetType: targetType,
      targetId: targetId,
      reason: reason,
      details: details,
    );

    result.fold(
      (f) => emit(ReportError(message: f.message, code: f.code)),
      (_) => emit(const ReportSuccess()),
    );
  }
}