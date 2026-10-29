import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/article_repository.dart';

class DeleteArticleUseCase {
  final ArticleRepository repository;
  const DeleteArticleUseCase(this.repository);

  Future<Either<Failure, void>> call({required String articleId}) {
    return repository.deleteArticle(articleId: articleId);
  }
}