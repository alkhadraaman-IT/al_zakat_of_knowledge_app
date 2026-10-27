import 'package:al_zakat_of_knowledge_app/core/errors/failures.dart';
import 'package:al_zakat_of_knowledge_app/core/utils/either.dart';
import 'package:al_zakat_of_knowledge_app/features/favorites/domain/entities/favorite_item_entity.dart';
import 'package:al_zakat_of_knowledge_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_repository.dart';

void main() {
  late MockFavoritesRepository mockRepository;
  late FavoritesCubit favoritesCubit;

  setUp(() {
    // Pure unit test: the cubit is built directly with the mock
    // repository — no GetIt / Hive / initDependencies needed.
    mockRepository = MockFavoritesRepository();
    favoritesCubit = FavoritesCubit(
      favoritesRepository: mockRepository, getFavoritesUseCase: null, toggleFavoriteUseCase: null,
    );
  });

  tearDown(() async {
    await favoritesCubit.close();
  });

  group('FavoritesCubit - loadFavorites', () {
    test('emits [FavoritesLoading] then [FavoritesLoaded] on success', () async {
      final tFavorites = [
        FavoriteItemEntity(
          id: '1',
          title: 'Session 1',
          itemType: 'session',
          thumbnailUrl: 'thumbnail1.jpg',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      ];
      mockRepository.getFavoritesResponse = Right(tFavorites);

      await favoritesCubit.loadFavorites();

      expect(favoritesCubit.state, isA<FavoritesLoaded>());
      expect((favoritesCubit.state as FavoritesLoaded).favorites.length, 1);
    });

    test('emits [FavoritesError] on failure', () async {
      mockRepository.getFavoritesResponse =
          Left(CacheFailure(message: 'Cache error'));

      await favoritesCubit.loadFavorites();

      expect(favoritesCubit.state, isA<FavoritesError>());
    });
  });

  group('FavoritesCubit - toggleFavorite', () {
    test('adds favorite and emits [FavoritesLoaded] on success', () async {
      mockRepository.toggleFavoriteResponse = const Right(true);

      await favoritesCubit.toggleFavorite('1', 'session');
      // toggleFavorite fires loadFavorites() inside fold() without
      // awaiting it — let that reload's microtasks finish.
      await pumpEventQueue();

      expect(favoritesCubit.state, isA<FavoritesLoaded>());
    });

    test('removes favorite and emits [FavoritesLoaded] on success', () async {
      mockRepository.toggleFavoriteResponse = const Right(false);

      await favoritesCubit.toggleFavorite('1', 'session');
      await pumpEventQueue();

      expect(favoritesCubit.state, isA<FavoritesLoaded>());
    });

    test('emits [FavoritesError] on toggle failure', () async {
      mockRepository.toggleFavoriteResponse =
          Left(CacheFailure(message: 'Toggle error'));

      await favoritesCubit.toggleFavorite('1', 'session');

      expect(favoritesCubit.state, isA<FavoritesError>());
    });
  });

  group('FavoritesCubit - removeFavorite', () {
    test('removes favorite and emits [FavoritesLoaded] on success', () async {
      mockRepository.removeFavoriteResponse = const Right(null);

      await favoritesCubit.removeFavorite('1');
      // Same fire-and-forget reload pattern as toggleFavorite.
      await pumpEventQueue();

      expect(favoritesCubit.state, isA<FavoritesLoaded>());
    });

    test('emits [FavoritesError] on remove failure', () async {
      mockRepository.removeFavoriteResponse =
          Left(CacheFailure(message: 'Remove error'));

      await favoritesCubit.removeFavorite('1');

      expect(favoritesCubit.state, isA<FavoritesError>());
    });
  });
}
