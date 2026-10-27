import '../../domain/entities/category_entity.dart';

/// Category model for Supabase `categories` mapping.
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    required super.sortOrder,
  });

  /// Creates a [CategoryModel] from a Supabase
  /// `categories` row — maps the `id`, `name_ar`,
  /// `name_en` and `sort_order` columns.
  factory CategoryModel.fromSupabase(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}
