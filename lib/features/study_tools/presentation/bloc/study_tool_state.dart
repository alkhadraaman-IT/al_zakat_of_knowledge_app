import 'package:equatable/equatable.dart';

import '../../domain/entities/study_tool_entity.dart';

/// Study tools BLoC states.
sealed class StudyToolState extends Equatable {
  const StudyToolState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class StudyToolInitial extends StudyToolState {
  const StudyToolInitial();
}

/// Loading state while fetching the tools list.
class StudyToolLoading extends StudyToolState {
  const StudyToolLoading();
}

/// Tools list loaded successfully.
class StudyToolLoaded extends StudyToolState {
  final List<StudyToolEntity> tools;

  const StudyToolLoaded({required this.tools});

  @override
  List<Object?> get props => [tools];
}

/// Error state.
class StudyToolError extends StudyToolState {
  final String message;
  final String? code;

  const StudyToolError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Submitting state while creating a tool.
class StudyToolSubmitting extends StudyToolState {
  const StudyToolSubmitting();
}

/// Tool created successfully.
class StudyToolSuccess extends StudyToolState {
  final StudyToolEntity tool;

  const StudyToolSuccess({required this.tool});

  @override
  List<Object?> get props => [tool];
}
