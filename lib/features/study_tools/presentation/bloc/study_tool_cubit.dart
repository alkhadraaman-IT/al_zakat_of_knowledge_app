import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_study_tool_usecase.dart';
import '../../domain/usecases/get_study_tools_usecase.dart';
import 'study_tool_state.dart';

/// Study materials Cubit managing the
/// materials list and the creation flow.
class StudyToolCubit extends Cubit<StudyToolState> {
  final GetStudyToolsUseCase getStudyToolsUseCase;
  final CreateStudyToolUseCase createStudyToolUseCase;

  StudyToolCubit({
    required this.getStudyToolsUseCase,
    required this.createStudyToolUseCase,
  }) : super(const StudyToolInitial());

  /// Loads the offered study materials, newest first.
  Future<void> getStudyTools() async {
    print('<<<<<<<<<<<[StudyToolCubit.getStudyTools]>>>>>>>>>>>>>');
    emit(const StudyToolLoading());
    final result = await getStudyToolsUseCase();
    result.fold(
      (failure) {
        // Full error logging — the failure object, its
        // runtime type, message, SQLSTATE code and stack
        // trace expose the exact PostgrestException /
        // RLS rejection in the console (Logcat).
        print('<<<<<<<<<<<[getStudyTools Error]>>>>>>>>>>>>>');
        print('Error object: $failure');
        print('Error type: ${failure.runtimeType}');
        print('Message: ${failure.message}');
        print('Code: ${failure.code ?? 'none'}');
        print('Stack trace: ${StackTrace.current}');
        emit(StudyToolError(message: failure.message, code: failure.code));
      },
      (tools) => emit(StudyToolLoaded(tools: tools)),
    );
  }

  /// Offers a new study material (free, for pickup).
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
    print('<<<<<<<<<<<[Cubit: createStudyTool called]>>>>>>>>>>>>>');
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
      (failure) {
        // Full error logging — the failure object, its
        // runtime type, message, SQLSTATE code and stack
        // trace expose the exact PostgrestException /
        // RLS rejection in the console (Logcat).
        print('<<<<<<<<<<<[createStudyTool Error]>>>>>>>>>>>>>');
        print('Error object: $failure');
        print('Error type: ${failure.runtimeType}');
        print('Message: ${failure.message}');
        print('Code: ${failure.code ?? 'none'}');
        print('Stack trace: ${StackTrace.current}');
        emit(StudyToolError(message: failure.message, code: failure.code));
      },
      (tool) => emit(StudyToolSuccess(tool: tool)),
    );
  }
}
