import '../repositories/category_topics_repository.dart';

/// استدعِها: بعد تسجيل الدخول، وعند متابعة/إلغاء متابعة تصنيف (بالمجموعة الكاملة).
class SyncCategoryTopicsUseCase {
  final CategoryTopicsRepository _repo;
  const SyncCategoryTopicsUseCase(this._repo);

  Future<void> call(Set<String> followedCategoryIds) =>
      _repo.sync(followedCategoryIds);

  Future<void> clear() => _repo.clear();
}
