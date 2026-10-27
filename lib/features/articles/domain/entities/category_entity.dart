import 'package:equatable/equatable.dart';

/// Category entity — a content category in the
/// `categories` table (articles / sessions /
/// materials taxonomy).
class CategoryEntity extends Equatable {
  final int id;
  final String nameAr;
  final String nameEn;
  final int sortOrder;

  const CategoryEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.sortOrder,
  });

  /// Localized display name — `nameAr` for Arabic
  /// locales, `nameEn` otherwise.
  String nameFor(String languageCode) {
    return languageCode == 'ar' ? nameAr : nameEn;
  }

  @override
  List<Object?> get props => [id, nameAr, nameEn, sortOrder];
}
