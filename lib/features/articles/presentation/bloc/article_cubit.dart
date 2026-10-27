import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_article_usecase.dart';
import '../../domain/usecases/get_articles_usecase.dart';
import 'article_state.dart';

/// Articles Cubit managing the published
/// articles feed and the publication flow.
class ArticleCubit extends Cubit<ArticleState> {
  final GetArticlesUseCase getArticlesUseCase;
  final CreateArticleUseCase createArticleUseCase;

  ArticleCubit({
    required this.getArticlesUseCase,
    required this.createArticleUseCase,
  }) : super(const ArticleInitial());

  /// Loads the published articles, newest first.
  Future<void> getArticles() async {
    print('<<<<<<<<<<<[ArticleCubit.getArticles]>>>>>>>>>>>>>');
    emit(const ArticleLoading());
    final result = await getArticlesUseCase();
    result.fold(
      (failure) {
        print('<<<<<<<<<<<[getArticles Error]>>>>>>>>>>>>>');
        print('Error object: $failure');
        print('Error type: ${failure.runtimeType}');
        print('Message: ${failure.message}');
        print('Code: ${failure.code ?? 'none'}');
        print('Stack trace: ${StackTrace.current}');
        emit(ArticleError(message: failure.message, code: failure.code));
      },
      (articles) => emit(ArticleLoaded(articles: articles)),
    );
  }

  /// Publishes a new article (sadaqah jariyah).
  Future<void> createArticle({
    required String authorId,
    required String title,
    required String body,
    required int categoryId,
  }) async {
    print('<<<<<<<<<<<[ArticleCubit.createArticle]>>>>>>>>>>>>>');
    emit(const ArticleSubmitting());
    final result = await createArticleUseCase(
      authorId: authorId,
      title: title,
      body: body,
      categoryId: categoryId,
    );
    result.fold(
      (failure) {
        print('<<<<<<<<<<<[createArticle Error]>>>>>>>>>>>>>');
        print('Error object: $failure');
        print('Error type: ${failure.runtimeType}');
        print('Message: ${failure.message}');
        print('Code: ${failure.code ?? 'none'}');
        print('Stack trace: ${StackTrace.current}');
        emit(ArticleError(message: failure.message, code: failure.code));
      },
      (article) {
        emit(ArticleSuccess(article: article));
        getArticles(); // <--- الحل الجذري: إعادة جلب المقالات فوراً لتحديث الواجهة تلقائياً
      },
    );
  }
}