import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_study_tool_usecase.dart';
import '../../domain/usecases/delete_study_tool_usecase.dart';
import '../../domain/usecases/get_study_tools_usecase.dart';
import '../../domain/usecases/take_study_tool_usecase.dart';
import '../../domain/usecases/update_study_tool_usecase.dart';
import 'study_tool_state.dart';

class StudyToolCubit extends Cubit<StudyToolState> {
  final GetStudyToolsUseCase getStudyToolsUseCase;
  final CreateStudyToolUseCase createStudyToolUseCase;
  final UpdateStudyToolUseCase updateStudyToolUseCase;
  final DeleteStudyToolUseCase deleteStudyToolUseCase;
  final TakeStudyToolUseCase takeStudyToolUseCase;

  StudyToolCubit({
    required this.getStudyToolsUseCase,
    required this.createStudyToolUseCase,
    required this.updateStudyToolUseCase,
    required this.deleteStudyToolUseCase,
    required this.takeStudyToolUseCase,
  }) : super(const StudyToolInitial());

  /// جلب القائمة (يصدر Loading ثم Loaded أو Error)
  Future<void> getStudyTools() async {
    emit(const StudyToolLoading());
    final result = await getStudyToolsUseCase();
    result.fold(
      (f) => emit(StudyToolError(message: f.message, code: f.code)),
      (tools) => emit(StudyToolLoaded(tools: tools)),
    );
  }

  /// إعادة جلب صامتة — تحافظ على القائمة الحالية أثناء الجلب
  Future<void> _refreshQuietly() async {
    final result = await getStudyToolsUseCase();
    result.fold(
      (_) {}, // إذا فشل، نُبقي الحالة الحالية
      (tools) => emit(StudyToolLoaded(tools: tools)),
    );
  }

  Future<void> createStudyTool({
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
    emit(const StudyToolSubmitting());
    final result = await createStudyToolUseCase(
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

    result.fold(
      (f) => emit(StudyToolError(message: f.message, code: f.code)),
      (tool) {
        emit(StudyToolSuccess(tool: tool));
        // إعادة الجلب في الخلفية — الشيت سيُغلق أولاً من listener
        _refreshQuietly();
      },
    );
  }

  Future<void> updateStudyTool({
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
    emit(const StudyToolUpdating());
    final result = await updateStudyToolUseCase(
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

    result.fold(
      (f) => emit(StudyToolError(message: f.message, code: f.code)),
      (tool) {
        emit(StudyToolUpdateSuccess(tool: tool));
        _refreshQuietly();
      },
    );
  }

  Future<void> deleteStudyTool({required String toolId}) async {
    emit(const StudyToolDeleting());
    final result = await deleteStudyToolUseCase(toolId: toolId);

    result.fold(
      (f) => emit(StudyToolError(message: f.message, code: f.code)),
      (_) {
        emit(StudyToolDeleteSuccess(toolId: toolId));
        _refreshQuietly();
      },
    );
  }

  Future<void> takeStudyTool({required String toolId}) async {
    emit(const StudyToolTaking());
    final result = await takeStudyToolUseCase(toolId: toolId);

    result.fold(
      (f) => emit(StudyToolError(message: f.message, code: f.code)),
      (_) {
        emit(StudyToolTakeSuccess(toolId: toolId));
        _refreshQuietly();
      },
    );
  }
}