import '../../domain/entities/article_entity.dart';

/// Article model for Supabase `articles` mapping.
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    required super.id,
    required super.authorId,
    required super.title,
    required super.body,
    required super.categoryId,
    super.imageUrl,
    required super.createdAt,
  });

  /// Creates an [ArticleModel] from a Supabase `articles` row.
  factory ArticleModel.fromEntity(ArticleEntity e) => ArticleModel(
      id: e.id,
      authorId: e.authorId,
      title: e.title,
      body: e.body,
      categoryId: e.categoryId,
      imageUrl: e.imageUrl,
      createdAt: e.createdAt,
    );

  /// Insert payload — permitted fields only.
  /// `image_url` stays null while `images_enabled = false`
  /// (deferred per the backend specification); `id` and
  /// `created_at` are server-managed and never sent.
  Map<String, dynamic> toInsertJson() {
    return {
      'author_id': authorId,
      'title': title,
      'body': body,
      'category_id': categoryId,
      'image_url': imageUrl,
    };
  }

  /// Creates an [ArticleModel] from a Hive JSON map.
  factory ArticleModel.fromMap(Map<dynamic, dynamic> json) {
    print('<<<<<<<<<<<[ArticleModel.fromHive]>>>>>>>>>>>>>');
    return ArticleModel(
      id: json['id']?.toString() ?? '',
      authorId: json['authorId']?.toString() ?? json['author_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      categoryId: (json['categoryId'] as num?)?.toInt() ??
          (json['category_id'] as num?)?.toInt() ??
          0,
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)?.toLocal() ??
              DateTime.now()
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)?.toLocal() ??
                  DateTime.now()
              : DateTime.now(),
    );
  }

  /// Converts the model to a JSON map for Hive storage.
  Map<String, dynamic> toMap() {
    print('<<<<<<<<<<<[ArticleModel.toHive]>>>>>>>>>>>>>');
    return {
      'id': id,
      'authorId': authorId,
      'title': title,
      'body': body,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
