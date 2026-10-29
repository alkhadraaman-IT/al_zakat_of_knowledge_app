import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/article_repository.dart';

class UpdateArticleUseCase {
  final ArticleRepository repository;
  const UpdateArticleUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String articleId,
    required String title,
    required String body,
    required int categoryId,
  }) {
    return repository.updateArticle(
      articleId: articleId,
      title: title,
      body: body,
      categoryId: categoryId,
    );
  }
}