import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// جسر بين isolate الخلفية (حيث تصل الرسائل والتطبيق مغلق) والتطبيق الرئيسي.
/// الخلفية تضع الرسالة بطابور، والتطبيق يفرغه عند الفتح/العودة ويعالجها.
/// نستخدم SharedPreferencesAsync لأنه يقرأ من التخزين مباشرة (آمن بين الـ isolates).
class PendingMessagesDataSource {
  final SharedPreferencesAsync _prefs;
  PendingMessagesDataSource([SharedPreferencesAsync? prefs])
      : _prefs = prefs ?? SharedPreferencesAsync();

  static const _queueKey = 'fcm_pending_messages';
  static const _uidKey = 'fcm_current_uid';
  static const _maxQueue = 50;

  Future<void> enqueue(Map<String, dynamic> data) async {
    final list = List<String>.of(await _prefs.getStringList(_queueKey) ?? const []);
    list.add(jsonEncode(data));
    final trimmed = list.length > _maxQueue ? list.sublist(list.length - _maxQueue) : list;
    await _prefs.setStringList(_queueKey, trimmed);
  }

  Future<List<Map<String, dynamic>>> takeAll() async {
    final list = await _prefs.getStringList(_queueKey) ?? const [];
    if (list.isEmpty) return const [];
    await _prefs.remove(_queueKey);
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
      id == null ? _prefs.remove(_uidKey) : _prefs.setString(_uidKey, id);

  Future<String?> currentUserId() => _prefs.getString(_uidKey);
}
