import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/article_entity.dart';
import '../repositories/article_repository.dart';

/// Use case for listing the published
/// articles, newest first.
class GetArticlesUseCase {
  final ArticleRepository repository;

  const GetArticlesUseCase(this.repository);

  Future<Either<Failure, List<ArticleEntity>>> call() {
    print('<<<<<<<<<<<[GetArticlesUseCase.call]>>>>>>>>>>>>>');
    return repository.getArticles();
  }
}
