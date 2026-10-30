import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../../../core/constants/app_keys.dart';
import '../../domain/repositories/category_topics_repository.dart';
import '../datasources/fcm_data_source.dart';

class CategoryTopicsRepositoryImpl implements CategoryTopicsRepository {
  final FcmDataSource _fcm;
  final Box<String> _meta;
  CategoryTopicsRepositoryImpl(this._fcm, this._meta);

  static const _key = AppKeys.SUBSCRIBED_TOPICS;

  /// أسماء الـ topics: أحرف وأرقام و - _ . ~ % فقط (UUID مناسب).
  static String topicFor(String categoryId) => 'category_$categoryId';

  Set<String> _read() {
    final raw = _meta.get(_key);
    if (raw == null) return {};
    try {
      return (jsonDecode(raw) as List).cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> _write(Set<String> topics) => _meta.put(_key, jsonEncode(topics.toList()));

  @override
  Future<void> sync(Set<String> followedCategoryIds) async {
    final target = followedCategoryIds.map(topicFor).toSet();
    final done = _read();

    for (final t in target.difference(done)) {
      try {
        await _fcm.subscribe(t);
        done.add(t);
      } catch (_) {} // بدون إنترنت: يُعاد المحاولة بالمزامنة القادمة
    }
    for (final t in done.difference(target).toList()) {
      try {
        await _fcm.unsubscribe(t);
        done.remove(t);
      } catch (_) {}
    }
    await _write(done);
  }

  @override
  Future<void> clear() => _meta.delete(_key);
}
