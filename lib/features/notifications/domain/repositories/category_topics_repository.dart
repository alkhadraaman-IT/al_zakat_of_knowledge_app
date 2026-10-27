/// اشتراك الجهاز بـ FCM topics التصنيفات المتابَعة.
abstract class CategoryTopicsRepository {
  /// يجعل اشتراكات الجهاز مطابقة تماماً لهذه المجموعة (يشترك بالجديد ويلغي القديم).
  Future<void> sync(Set<String> followedCategoryIds);

  /// ينسى الاشتراكات المخزنة (بعد deleteToken تضيع الاشتراكات فعلياً).
  Future<void> clear();
}
