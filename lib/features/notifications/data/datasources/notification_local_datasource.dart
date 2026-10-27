import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../models/notification_model.dart';

/// إشعارات محلية على الجهاز: المحتوى الجديد (FCM topics) + الدعاء.
/// كل إشعار يُخزَّن كنص JSON بمفتاح = id، بدون حاجة لـ adapters.
abstract class NotificationsLocalDataSource {
  List<NotificationModel> getAll(String userId);
  bool contains(String id);

  /// يتجاهل المكرر (نفس الـ id) كي لا تُعاد حالة «مقروء» لـ«غير مقروء».
  Future<void> save(NotificationModel n);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead(String userId);
  Future<void> delete(String id);
  Future<void> deleteOlderThan(Duration age);

  /// يصدر حدثاً عند أي تغيير (لتحديث القائمة وهي مفتوحة).
  Stream<void> watch();
}

class NotificationsLocalDataSourceImpl implements NotificationsLocalDataSource {
  final Box<String> _box;
  NotificationsLocalDataSourceImpl(this._box);

  Map<String, dynamic>? _decode(String raw) {
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null; // سجل تالف: نتجاهله
    }
  }

  @override
  List<NotificationModel> getAll(String userId) {
    final out = <NotificationModel>[];
    for (final raw in _box.values) {
      final json = _decode(raw);
      if (json == null) continue;
      try {
        final n = NotificationModel.fromJson(json);
        if (n.userId == userId) out.add(n);
      } catch (_) {}
    }
    return out;
  }

  @override
  bool contains(String id) => _box.containsKey(id);

  @override
  Future<void> save(NotificationModel n) async {
    if (_box.containsKey(n.id)) return;
    await _box.put(n.id, jsonEncode(n.toJson()));
  }

  @override
  Future<void> markAsRead(String id) async {
    final raw = _box.get(id);
    final json = raw == null ? null : _decode(raw);
    if (json == null) return;
    json['is_read'] = true;
    await _box.put(id, jsonEncode(json));
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final updates = <String, String>{};
    for (final key in _box.keys.cast<String>()) {
      final json = _decode(_box.get(key)!);
      if (json == null || json['user_id'] != userId || json['is_read'] == true) {
        continue;
      }
      json['is_read'] = true;
      updates[key] = jsonEncode(json);
    }
    if (updates.isNotEmpty) await _box.putAll(updates);
  }

  @override
  Future<void> delete(String id) => _box.delete(id);

  @override
  Future<void> deleteOlderThan(Duration age) async {
    final cutoff = DateTime.now().toUtc().subtract(age);
    final stale = <String>[];
    for (final key in _box.keys.cast<String>()) {
      final json = _decode(_box.get(key)!);
      final created = DateTime.tryParse((json?['created_at'] as String?) ?? '');
      if (json == null || created == null || created.isBefore(cutoff)) {
        stale.add(key);
      }
    }
    if (stale.isNotEmpty) await _box.deleteAll(stale);
  }

  @override
  Stream<void> watch() => _box.watch().map((_) {});
}
