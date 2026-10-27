import 'package:supabase_flutter/supabase_flutter.dart';

/// جدول user_devices: توكن FCM لكل جهاز.
class DeviceTokensRemoteDataSource {
  final SupabaseClient _client;
  DeviceTokensRemoteDataSource(this._client);

  static const _table = 'user_devices';

  /// استدعِها بعد تسجيل الدخول وعند onTokenRefresh.
  Future<void> register({required String token, String? platform}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    await _client.from(_table).upsert(
      {'user_id': uid, 'fcm_token': token, 'platform': platform},
      onConflict: 'fcm_token',
    );
  }

  /// استدعِها *قبل* signOut (والمستخدم ما زال مسجّل دخول) وإلا ترفضها RLS.
  Future<void> remove(String token) async {
    await _client.from(_table).delete().eq('fcm_token', token);
  }
}
