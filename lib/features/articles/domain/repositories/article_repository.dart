import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/article_entity.dart';
import '../entities/category_entity.dart';

/// Abstract article repository interface.
abstract class ArticleRepository {
  /// Publishes a new article row in the `articles`
  /// table. Returns the created [ArticleEntity] on
  /// success, [Failure] on error.
  Future<Either<Failure, ArticleEntity>> createArticle({
    required String authorId,
    required String title,
    required String body,
    required int categoryId,
  });

  /// Lists the content categories.
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  /// Lists the published articles, newest first.
  Future<Either<Failure, List<ArticleEntity>>> getArticles();

  /// Lists the articles authored by
  /// [authorId], newest first.
  Future<Either<Failure, List<ArticleEntity>>> getArticlesByAuthor(
    String authorId,
  );
}
