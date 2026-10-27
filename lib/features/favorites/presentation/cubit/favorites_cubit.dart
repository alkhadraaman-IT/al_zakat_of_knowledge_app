import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/favorite_item_entity.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import 'favorites_state.dart';

/// مفضلة المستخدم الحالي فقط. لما يتغير المستخدم (تسجيل خروج/دخول)
/// بيعيد الاشتراك على مفضلة المستخدم الجديد بدل ما يعرض مفضلة غيره.
class FavoritesCubit extends Cubit<FavoritesState> {
  final GetFavoritesUseCase _getFavorites;
  final ToggleFavoriteUseCase _toggleFavorite;

  StreamSubscription<dynamic>? _favoritesSub;
  StreamSubscription<String?>? _userSub;
  String? _userId;

  /// [initialUserId]: المستخدم عند إنشاء الـ Cubit (null = ما في مستخدم).
  /// [userIdChanges]: ستريم بتغيّر المستخدم (من Supabase auth بالـ DI).
  FavoritesCubit({
    required GetFavoritesUseCase getFavoritesUseCase,
    required ToggleFavoriteUseCase toggleFavoriteUseCase,
    required String? initialUserId,
    required Stream<String?> userIdChanges,
  })  : _getFavorites = getFavoritesUseCase,
        _toggleFavorite = toggleFavoriteUseCase,
        super(const FavoritesState()) {
    _bindUser(initialUserId);
    _userSub = userIdChanges.listen(_bindUser);
  }

  void _bindUser(String? userId) {
    if (userId == _userId && _favoritesSub != null) return; // نفس المستخدم
    _userId = userId;
    _favoritesSub?.cancel();
    _favoritesSub = null;

    if (userId == null) {
      emit(state.copyWith(status: FavoritesStatus.success, items: const []));
      return;
    }

    emit(state.copyWith(status: FavoritesStatus.loading, items: const []));
    _favoritesSub = _getFavorites(userId).listen(
      (result) => result.fold(
        (failure) => emit(state.copyWith(
          status: FavoritesStatus.failure,
          error: failure.message,
        )),
        (items) => emit(state.copyWith(
          status: FavoritesStatus.success,
          items: items,
        )),
      ),
    );
  }

  void selectType(FavoriteType type) =>
      emit(state.copyWith(selectedType: type));

  /// إضافة أو حذف. القائمة بتتحدّث لحالها من الـ Stream.
  Future<void> toggle(FavoriteEntity item) async {
    final userId = _userId;
    if (userId == null) return; // لازم مستخدم مسجّل
    final result = await _toggleFavorite(userId, item);
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) {},
    );
  }

  @override
  Future<void> close() async {
    await _favoritesSub?.cancel();
    await _userSub?.cancel();
    return super.close();
  }
}
