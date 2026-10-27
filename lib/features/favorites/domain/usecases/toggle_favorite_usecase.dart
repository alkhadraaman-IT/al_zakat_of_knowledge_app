import 'package:al_zakat_of_knowledge_app/core/errors/failures.dart';
import 'package:al_zakat_of_knowledge_app/core/utils/either.dart';

import '../entities/favorite_item_entity.dart';
import '../repositories/favorites_repository.dart';

/// إضافة أو حذف من المفضلة (حسب وجوده).
class ToggleFavoriteUseCase {
  final FavoritesRepository repository;
  const ToggleFavoriteUseCase(this.repository);

  Future<Either<Failure, bool>> call(String userId, FavoriteEntity item) =>
      repository.toggleFavorite(userId, item);
}
