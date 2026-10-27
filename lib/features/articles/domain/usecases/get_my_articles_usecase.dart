import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/article_entity.dart';
import '../repositories/article_repository.dart';

/// Use case for listing the signed-in
/// user's published articles (filtered
/// by `author_id`), newest first.
class GetMyArticlesUseCase {
  final ArticleRepository repository;

  const GetMyArticlesUseCase(this.repository);

  Future<Either<Failure, List<ArticleEntity>>> call({
    required String authorId,
  }) {
    print('<<<<<<<<<<<[GetMyArticlesUseCase.call]>>>>>>>>>>>>>');
    return repository.getArticlesByAuthor(authorId);
  }
}
