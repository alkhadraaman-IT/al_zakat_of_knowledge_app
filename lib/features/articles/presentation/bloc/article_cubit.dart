import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/article_entity.dart';
import '../../domain/usecases/create_article_usecase.dart';
import '../../domain/usecases/delete_article_usecase.dart';
import '../../domain/usecases/get_articles_usecase.dart';
import '../../domain/usecases/update_article_usecase.dart';
import 'article_state.dart';

class ArticleCubit extends Cubit<ArticleState> {
  final GetArticlesUseCase getArticlesUseCase;
  final CreateArticleUseCase createArticleUseCase;
  final UpdateArticleUseCase updateArticleUseCase;
  final DeleteArticleUseCase deleteArticleUseCase;

  ArticleCubit({
    required this.getArticlesUseCase,
    required this.createArticleUseCase,
    required this.updateArticleUseCase,
    required this.deleteArticleUseCase,
  }) : super(const ArticleInitial());

  Future<void> getArticles() async {
    emit(const ArticleLoading());
    final result = await getArticlesUseCase();
    result.fold(
      (f) => emit(ArticleError(message: f.message, code: f.code)),
      (articles) => emit(ArticleLoaded(articles: articles)),
    );
  }

  Future<void> _refreshQuietly() async {
    final result = await getArticlesUseCase();
    result.fold(
      (_) {},
      (articles) => emit(ArticleLoaded(articles: articles)),
    );
  }

  Future<void> createArticle({
    required String authorId,
    required String title,
    required String body,
    required int categoryId,
  }) async {
    emit(const ArticleSubmitting());
    final result = await createArticleUseCase(
      authorId: authorId,
      title: title,
      body: body,
      categoryId: categoryId,
    );
    result.fold(
      (f) => emit(ArticleError(message: f.message, code: f.code)),
      (article) {
        emit(ArticleSuccess(article: article));
        _refreshQuietly();
      },
    );
  }

  Future<void> updateArticle({
    required String articleId,
    required String title,
    required String body,
    required int categoryId,
  }) async {
    emit(const ArticleUpdating());
    final result = await updateArticleUseCase(
      articleId: articleId,
      title: title,
      body: body,
      categoryId: categoryId,
    );
    result.fold(
      (f) => emit(ArticleError(message: f.message, code: f.code)),
      (_) {
        emit(ArticleUpdateSuccess(
          article: ArticleEntity(
            id: articleId,
            authorId: '',
            title: title,
            body: body,
            categoryId: categoryId,
            imageUrl: null,
            createdAt: DateTime.now(),
          ),
        ));
        _refreshQuietly();
      },
    );
  }

  Future<void> deleteArticle({required String articleId}) async {
    emit(const ArticleDeleting());
    final result = await deleteArticleUseCase(articleId: articleId);
    result.fold(
      (f) => emit(ArticleError(message: f.message, code: f.code)),
      (_) {
        emit(ArticleDeleteSuccess(articleId: articleId));
        _refreshQuietly();
      },
    );
  }
}