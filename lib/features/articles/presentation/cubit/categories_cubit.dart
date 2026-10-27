import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';

/// يحمّل تصنيفات المحتوى مرة وحدة، ويرجع للقائمة المدمجة إذا فشل الطلب.
/// الـ State هو القائمة نفسها (فاضية = لسا ما تحمّلت).
class CategoriesCubit extends Cubit<List<CategoryEntity>> {
  final GetCategoriesUseCase _getCategories;

  CategoriesCubit({required GetCategoriesUseCase getCategoriesUseCase})
      : _getCategories = getCategoriesUseCase,
        super(const []) {
    load();
  }

  static const List<CategoryEntity> _fallback = [
    CategoryEntity(
      id: 1,
      nameAr: 'علوم شريعة',
      nameEn: 'Islamic Sciences',
      sortOrder: 1,
    ),
    CategoryEntity(id: 2, nameAr: 'طب', nameEn: 'Medicine', sortOrder: 2),
    CategoryEntity(id: 3, nameAr: 'برمجة', nameEn: 'Programming', sortOrder: 3),
    CategoryEntity(id: 4, nameAr: 'تجارة', nameEn: 'Commerce', sortOrder: 4),
    CategoryEntity(
      id: 5,
      nameAr: 'تطوير ذاتي',
      nameEn: 'Self Development',
      sortOrder: 5,
    ),
    CategoryEntity(id: 6, nameAr: 'أكاديمي', nameEn: 'Academic', sortOrder: 6),
  ];

  Future<void> load() async {
    final result = await _getCategories();
    if (isClosed) return;
    result.fold(
      (_) => emit(_fallback),
      (categories) => emit(categories.isEmpty ? _fallback : categories),
    );
  }

  /// اسم التصنيف حسب اللغة، أو الرقم نفسه إذا ما انلقى.
  String nameOf(int categoryId, String languageCode) {
    for (final category in state) {
      if (category.id == categoryId) return category.nameFor(languageCode);
    }
    return '$categoryId';
  }
}
