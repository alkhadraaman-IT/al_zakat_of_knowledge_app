import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_keys.dart';

/// جسر بين isolate الخلفية (حيث تصل الرسائل والتطبيق مغلق) والتطبيق الرئيسي.
/// الخلفية تضع الرسالة بطابور، والتطبيق يفرغه عند الفتح/العودة ويعالجها.
/// نستخدم SharedPreferencesAsync لأنه يقرأ من التخزين مباشرة (آمن بين الـ isolates).
class PendingMessagesDataSource {
  final SharedPreferencesAsync _prefs;
  PendingMessagesDataSource([SharedPreferencesAsync? prefs])
      : _prefs = prefs ?? SharedPreferencesAsync();

  static const _maxQueue = 50;

  Future<void> enqueue(Map<String, dynamic> data) async {
    final list = List<String>.of(
      await _prefs.getStringList(AppKeys.FCM_PENDING_MESSAGES) ?? const [],
    );
    list.add(jsonEncode(data));
    final trimmed = list.length > _maxQueue ? list.sublist(list.length - _maxQueue) : list;
    await _prefs.setStringList(AppKeys.FCM_PENDING_MESSAGES, trimmed);
  }

  Future<List<Map<String, dynamic>>> takeAll() async {
    final list = await _prefs.getStringList(AppKeys.FCM_PENDING_MESSAGES) ?? const [];
    if (list.isEmpty) return const [];
    await _prefs.remove(AppKeys.FCM_PENDING_MESSAGES);
    final out = <Map<String, dynamic>>[];
    for (final raw in list) {
      try {
        out.add(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }
    return out;
  }

  /// نحتاجه بالخلفية (لا يوجد Supabase هناك) لمعرفة المستخدم الحالي.
  Future<void> setCurrentUserId(String? id) =>
      id == null
          ? _prefs.remove(AppKeys.FCM_CURRENT_UID)
          : _prefs.setString(AppKeys.FCM_CURRENT_UID, id);

  Future<String?> currentUserId() => _prefs.getString(AppKeys.FCM_CURRENT_UID);
}
