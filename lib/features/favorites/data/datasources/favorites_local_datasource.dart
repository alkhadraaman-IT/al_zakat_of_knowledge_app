import 'package:hive_ce/hive.dart';

import '../models/favorite_item_model.dart';

abstract class FavoritesLocalDataSource {
  /// مفضلة مستخدم محدد فقط (القيمة الحالية ثم أي تغيير).
  Stream<List<FavoriteItemModel>> watchAll(String userId);

  /// true = انضافت، false = انحذفت.
  Future<bool> toggle(String userId, FavoriteItemModel item);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final Box<FavoriteItemModel> favoritesBox;
  FavoritesLocalDataSourceImpl({required this.favoritesBox});

  /// المفتاح يشمل المستخدم والنوع: نفس العنصر ممكن ينحفظ من أكتر من مستخدم.
  static String _key(String userId, String type, String id) =>
      '$userId|$type:$id';

  List<FavoriteItemModel> _forUser(String userId) =>
      favoritesBox.values.where((m) => m.userId == userId).toList()
        ..sort((a, b) => b.savedAtMs.compareTo(a.savedAtMs));

  @override
  Stream<List<FavoriteItemModel>> watchAll(String userId) async* {
    yield _forUser(userId);
    yield* favoritesBox.watch().map((_) => _forUser(userId));
  }

  @override
  Future<bool> toggle(String userId, FavoriteItemModel item) async {
    final key = _key(userId, item.type, item.id);
    if (favoritesBox.containsKey(key)) {
      await favoritesBox.delete(key);
      return false;
    }
    await favoritesBox.put(key, item);
    return true;
  }
}
