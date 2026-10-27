import 'package:al_zakat_of_knowledge_app/core/errors/failures.dart';
// Local Either implementation (core/utils/either.dart) — NOT dartz.
// Using the project's own Either in every override prevents the
// "type mismatch" errors between the repository contract and the
// stubbed responses.
import 'package:al_zakat_of_knowledge_app/core/utils/either.dart';
import 'package:al_zakat_of_knowledge_app/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:al_zakat_of_knowledge_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:mocktail/mocktail.dart';

/// Mock [FavoritesRepository] — all four abstract methods are
/// overridden with the project-local [Either] types.
///
/// Responses are controlled by assigning the `...Response` fields
/// (defaults are the happy path). Direct field assignment is used
/// instead of mocktail's `when()/thenAnswer()` because concretely
/// overridden methods never route through [Mock.noSuchMethod], so
/// `when()` cannot register a stub for them.
class MockFavoritesRepository extends Mock implements FavoritesRepository {
  /// Response for [getFavorites] — defaults to an empty success list.
  Either<Failure, List<FavoriteItemEntity>> getFavoritesResponse =
      const Right([]);

  /// Response for [toggleFavorite] — defaults to success.
  Either<Failure, bool> toggleFavoriteResponse = const Right(true);

  /// Response for [isFavorite] — defaults to "not a favorite".
  Either<Failure, bool> isFavoriteResponse = const Right(false);

  /// Response for [removeFavorite] — defaults to success.
  Either<Failure, void> removeFavoriteResponse = const Right(null);

  @override
  Future<Either<Failure, List<FavoriteItemEntity>>> getFavorites() async {
    return getFavoritesResponse;
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(
    String id,
    String itemType,
  ) async {
    return toggleFavoriteResponse;
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String id) async {
    return isFavoriteResponse;
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String id) async {
    return removeFavoriteResponse;
  }
}
