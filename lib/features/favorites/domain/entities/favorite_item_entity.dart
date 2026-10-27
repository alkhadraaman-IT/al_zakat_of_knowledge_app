// domain/entities/favorite_entity.dart
import 'package:equatable/equatable.dart';

enum FavoriteType { lecture, article, tool }

class FavoriteEntity extends Equatable {
  final String id;
  final FavoriteType type;
  final String title;

  /// ناتج model.toMap() للعنصر الأصلي (نسخة تشتغل أوفلاين)
  final Map<dynamic, dynamic> payload;
  final DateTime savedAt;

  const FavoriteEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.payload,
    required this.savedAt,
  });

  /// مفتاح فريد عبر الأنواع الثلاثة
  String get key => '${type.name}:$id';

  @override
  List<Object?> get props => [id, type, title, payload, savedAt];
}
