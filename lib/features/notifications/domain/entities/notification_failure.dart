/// أنواع الفشل المفهومة للمستخدم (لا نعرض رسائل تقنية خام).
enum NotificationsFailureKind {
  network,
  unauthenticated,
  permissionDenied,
  server,
  unknown;

  /// هل لإعادة المحاولة معنى؟ (انتهاء الجلسة/الصلاحية لا يُصلحهما التكرار)
  bool get isRetryable =>
      this != unauthenticated && this != permissionDenied;
}

class NotificationsException implements Exception {
  final NotificationsFailureKind kind;

  /// تفاصيل تقنية للتشخيص فقط (لا تُعرض للمستخدم).
  final String? details;

  const NotificationsException(this.kind, {this.details});

  @override
  String toString() => 'NotificationsException($kind, $details)';
}
