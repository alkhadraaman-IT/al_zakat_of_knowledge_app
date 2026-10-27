import 'package:al_zakat_of_knowledge_app/core/errors/failures.dart';
import 'package:al_zakat_of_knowledge_app/core/utils/either.dart';

import '../../domain/entities/favorite_item_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_datasource.dart';
import '../models/favorite_item_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;
  FavoritesRepositoryImpl({required this.localDataSource});

  @override
  Stream<Either<Failure, List<FavoriteEntity>>> watchFavorites(
    String userId,
  ) async* {
    try {
      await for (final list in localDataSource.watchAll(userId)) {
        yield Right(list.map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      yield Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(
    String userId,
    FavoriteEntity item,
  ) async {
    try {
      final added = await localDataSource.toggle(
        userId,
        FavoriteItemModel.fromEntity(item, userId),
      );
      return Right(added);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
