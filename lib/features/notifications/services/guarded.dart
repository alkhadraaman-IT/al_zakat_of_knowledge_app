import 'package:flutter/foundation.dart';

/// ينفّذ خطوة ولا يترك فشلها يوقف بقية التسلسل (إذن مرفوض، شبكة...).
Future<void> guarded(String tag, Future<void> Function() step) async {
  try {
    await step().timeout(const Duration(seconds: 15));
  } catch (e) {
    debugPrint('[notifications] $tag failed: $e');
  }
}
