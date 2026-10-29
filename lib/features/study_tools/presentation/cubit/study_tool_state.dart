import 'package:equatable/equatable.dart';
import '../../domain/entities/study_tool_entity.dart';

sealed class StudyToolState extends Equatable {
  const StudyToolState();
  @override
  List<Object?> get props => [];
}

// ─── حالات القائمة ──────────────────────────────
class StudyToolInitial extends StudyToolState {
  const StudyToolInitial();
}

class StudyToolLoading extends StudyToolState {
  const StudyToolLoading();
}

class StudyToolLoaded extends StudyToolState {
  final List<StudyToolEntity> tools;
  const StudyToolLoaded({required this.tools});
  @override
  List<Object?> get props => [tools];
}

class StudyToolError extends StudyToolState {
  final String message;
  final String? code;
  const StudyToolError({required this.message, this.code});
  @override
  List<Object?> get props => [message, code];
}

// ─── حالات الإنشاء ──────────────────────────────
class StudyToolSubmitting extends StudyToolState {
  const StudyToolSubmitting();
}

class StudyToolSuccess extends StudyToolState {
  final StudyToolEntity tool;
  const StudyToolSuccess({required this.tool});
  @override
  List<Object?> get props => [tool];
}

// ─── حالات التعديل ──────────────────────────────
class StudyToolUpdating extends StudyToolState {
  const StudyToolUpdating();
}

class StudyToolUpdateSuccess extends StudyToolState {
  final StudyToolEntity tool;
  const StudyToolUpdateSuccess({required this.tool});
  @override
  List<Object?> get props => [tool];
}

// ─── حالات الحذف ────────────────────────────────
class StudyToolDeleting extends StudyToolState {
  const StudyToolDeleting();
}

class StudyToolDeleteSuccess extends StudyToolState {
  final String toolId;
  const StudyToolDeleteSuccess({required this.toolId});
  @override
  List<Object?> get props => [toolId];
}

// ─── حالات الأخذ ────────────────────────────────
class StudyToolTaking extends StudyToolState {
  const StudyToolTaking();
}

class StudyToolTakeSuccess extends StudyToolState {
  final String toolId;
  const StudyToolTakeSuccess({required this.toolId});
  @override
  List<Object?> get props => [toolId];
}