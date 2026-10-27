import 'package:hive_ce/hive.dart';

import '../../domain/entities/favorite_item_entity.dart';


part 'favorite_item_model.g.dart';

// typeId لازم يكون غير مستخدم بأي Adapter ثاني بالتطبيق
@HiveType(typeId: 10)
class FavoriteItemModel {
  @HiveField(0)
  final String id;

  /// lecture | article | tool
  @HiveField(1)
  final String type;

  @HiveField(2)
  final String title;

  /// ناتج model.toMap() للعنصر الأصلي
  @HiveField(3)
  final Map<dynamic, dynamic> payload;

  @HiveField(4)
  final int savedAtMs;

  /// صاحب المفضلة. القيمة الافتراضية للسجلات القديمة (بدون userId).
  @HiveField(5, defaultValue: '')
  final String userId;

  const FavoriteItemModel({
    required this.id,
    required this.type,
    required this.title,
    required this.payload,
    required this.savedAtMs,
    required this.userId,
  });

  factory FavoriteItemModel.fromEntity(FavoriteEntity e, String userId) =>
      FavoriteItemModel(
        id: e.id,
        type: e.type.name,
        title: e.title,
        payload: e.payload,
        savedAtMs: e.savedAt.millisecondsSinceEpoch,
        userId: userId,
      );

  FavoriteEntity toEntity() => FavoriteEntity(
        id: id,
        type: FavoriteType.values.byName(type),
        title: title,
        payload: payload,
        savedAt: DateTime.fromMillisecondsSinceEpoch(savedAtMs),
      );
}
