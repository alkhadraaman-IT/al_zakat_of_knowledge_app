import 'package:al_zakat_of_knowledge_app/core/errors/failures.dart';
import 'package:al_zakat_of_knowledge_app/core/utils/either.dart';

import '../entities/favorite_item_entity.dart';

abstract class FavoritesRepository {
  Stream<Either<Failure, List<FavoriteEntity>>> watchFavorites(String userId);

  /// Right(true) = انضافت، Right(false) = انحذفت
  Future<Either<Failure, bool>> toggleFavorite(
    String userId,
    FavoriteEntity item,
  );
}
