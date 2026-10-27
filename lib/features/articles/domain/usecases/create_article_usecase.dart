import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/article_entity.dart';
import '../repositories/article_repository.dart';

/// Use case for publishing a new article
/// (sadaqah jariyah) to the `articles` table.
class CreateArticleUseCase {
  final ArticleRepository repository;

  const CreateArticleUseCase(this.repository);

  Future<Either<Failure, ArticleEntity>> call({
    required String authorId,
    required String title,
    required String body,
    required int categoryId,
  }) {
    print('<<<<<<<<<<<[CreateArticleUseCase.call]>>>>>>>>>>>>>');
    return repository.createArticle(
      authorId: authorId,
      title: title,
      body: body,
      categoryId: categoryId,
    );
  }
}
