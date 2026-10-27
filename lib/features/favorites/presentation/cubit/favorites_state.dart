// presentation/cubit/favorites_state.dart
import 'package:equatable/equatable.dart';

import '../../domain/entities/favorite_item_entity.dart';

enum FavoritesStatus { loading, success, failure }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<FavoriteEntity> items;
  final FavoriteType selectedType;
  final String? error;

  const FavoritesState({
    this.status = FavoritesStatus.loading,
    this.items = const [],
    this.selectedType = FavoriteType.lecture,
    this.error,
  });

  List<FavoriteEntity> get visible =>
      items.where((e) => e.type == selectedType).toList();

  bool isFavorite(FavoriteType type, String id) =>
      items.any((e) => e.type == type && e.id == id);

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<FavoriteEntity>? items,
    FavoriteType? selectedType,
    String? error,
  }) =>
      FavoritesState(
        status: status ?? this.status,
        items: items ?? this.items,
        selectedType: selectedType ?? this.selectedType,
        error: error,
      );

  @override
  List<Object?> get props => [status, items, selectedType, error];
}
