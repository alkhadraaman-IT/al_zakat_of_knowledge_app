import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> fetch({int limit = 20, int offset = 0});
  Stream<List<NotificationModel>> watch({int limit = 50});
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> delete(String id);
  Future<void> recordSessionEndedDua(String sessionId);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final SupabaseClient _client;
  NotificationsRemoteDataSourceImpl(this._client);

  static const _table = 'notifications';

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AuthException('not_authenticated');
    return id;
  }

  @override
  Future<List<NotificationModel>> fetch({int limit = 20, int offset = 0}) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', _uid)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return rows.map<NotificationModel>(NotificationModel.fromJson).toList();
  }

  /// يحتاج تفعيل Realtime لجدول notifications من لوحة Supabase.
  @override
  Stream<List<NotificationModel>> watch({int limit = 50}) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', _uid)
        .order('created_at', ascending: false)
        .limit(limit)
        .map((rows) => rows.map(NotificationModel.fromJson).toList());
  }

  @override
  Future<void> markAsRead(String id) async {
    await _client
        .from(_table)
        .update({'is_read': true})
        .eq('id', id)
        .eq('user_id', _uid);
  }

  @override
  Future<void> markAllAsRead() async {
    await _client
        .from(_table)
        .update({'is_read': true})
        .eq('user_id', _uid)
        .eq('is_read', false);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id).eq('user_id', _uid);
  }

  @override
  Future<void> recordSessionEndedDua(String sessionId) async {
    await _client.rpc(
      'create_session_dua_notification',
      params: {'p_session_id': sessionId},
    );
  }
}
