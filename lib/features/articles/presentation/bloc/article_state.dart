import 'package:equatable/equatable.dart';

import '../../domain/entities/article_entity.dart';

/// Articles BLoC states.
sealed class ArticleState extends Equatable {
  const ArticleState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class ArticleInitial extends ArticleState {
  const ArticleInitial();
}

/// Loading state while fetching the articles list.
class ArticleLoading extends ArticleState {
  const ArticleLoading();
}

/// Articles list loaded successfully.
class ArticleLoaded extends ArticleState {
  final List<ArticleEntity> articles;

  const ArticleLoaded({required this.articles});

  @override
  List<Object?> get props => [articles];
}

/// Error state.
class ArticleError extends ArticleState {
  final String message;
  final String? code;

  const ArticleError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Submitting state while publishing an article.
class ArticleSubmitting extends ArticleState {
  const ArticleSubmitting();
}

/// Article published successfully.
class ArticleSuccess extends ArticleState {
  final ArticleEntity article;

  const ArticleSuccess({required this.article});

  @override
  List<Object?> get props => [article];
}
