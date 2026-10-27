import 'package:equatable/equatable.dart';

import '../../../articles/domain/entities/article_entity.dart';
import '../../../sessions/domain/entities/session_entity.dart';
import '../../../study_tools/domain/entities/study_tool_entity.dart';

/// Immutable states emitted by [SearchCubit].
sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state �?" recent searches are shown and
/// no remote data has been fetched yet.
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// Remote data is being fetched for the
/// first (non-empty) query.
class SearchLoading extends SearchState {
  const SearchLoading();
}

/// Remote data is available and filtered
/// results have been computed for [query].
class SearchLoaded extends SearchState {
  final String query;
  final int selectedTab;

  /// Filtered sessions (lectures).
  final List<SessionEntity> sessions;

  /// Filtered articles.
  final List<ArticleEntity> articles;

  /// Filtered study tools.
  final List<StudyToolEntity> tools;

  const SearchLoaded({
    required this.query,
    required this.selectedTab,
    required this.sessions,
    required this.articles,
    required this.tools,
  });

  @override
  List<Object?> get props => [query, selectedTab, sessions, articles, tools];
}

/// A load or filter attempt failed �?" [message]
/// is user-facing, details are logged separately.
class SearchError extends SearchState {
  final String message;
  final String? code;

  const SearchError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}