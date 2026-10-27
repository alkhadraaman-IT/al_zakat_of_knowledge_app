import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/article_repository.dart';

/// Use case for listing the content categories
/// for the article creation picker.
class GetCategoriesUseCase {
  final ArticleRepository repository;

  const GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<CategoryEntity>>> call() {
    print('<<<<<<<<<<<[GetCategoriesUseCase.call]>>>>>>>>>>>>>');
    return repository.getCategories();
  }
}
