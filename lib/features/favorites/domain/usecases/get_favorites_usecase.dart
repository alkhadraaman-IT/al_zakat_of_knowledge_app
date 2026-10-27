import 'package:al_zakat_of_knowledge_app/core/errors/failures.dart';
import 'package:al_zakat_of_knowledge_app/core/utils/either.dart';

import '../entities/favorite_item_entity.dart';
import '../repositories/favorites_repository.dart';

/// جلب مفضلة مستخدم (Stream: بتتحدث لحالها عند أي تغيير).
class GetFavoritesUseCase {
  final FavoritesRepository repository;
  const GetFavoritesUseCase(this.repository);

  Stream<Either<Failure, List<FavoriteEntity>>> call(String userId) =>
      repository.watchFavorites(userId);
}
