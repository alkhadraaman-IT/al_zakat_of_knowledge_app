import 'package:equatable/equatable.dart';

/// Article entity — a published reflection (sadaqah
/// jariyah) in the `articles` table.
class ArticleEntity extends Equatable {
  final String id;
  final String authorId;
  final String title;
  final String body;

  /// Category id — an `int` foreign key into the
  /// `categories` table.
  final int categoryId;
  final String? imageUrl;
  final DateTime createdAt;

  const ArticleEntity({
    required this.id,
    required this.authorId,
    required this.title,
    required this.body,
    required this.categoryId,
    this.imageUrl,
    required this.createdAt,
  });

  ArticleEntity copyWith({
    String? id,
    String? authorId,
    String? title,
    String? body,
    int? categoryId,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return ArticleEntity(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      body: body ?? this.body,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorId,
        title,
        body,
        categoryId,
        imageUrl,
        createdAt,
      ];
}
