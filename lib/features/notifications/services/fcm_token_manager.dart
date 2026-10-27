import 'dart:async';
import 'dart:io' show Platform;

import '../data/datasources/device_tokens_remote_data_source.dart';
import '../data/datasources/fcm_data_source.dart';
import 'guarded.dart';

/// مسؤول عن إذن الإشعارات وتوكن الجهاز فقط.
class FcmTokenManager {
  final FcmDataSource _fcm;
  final DeviceTokensRemoteDataSource _tokens;
  FcmTokenManager(this._fcm, this._tokens);

  StreamSubscription<String>? _refreshSub;

  /// عند تسجيل الدخول: إذن + تسجيل التوكن بالخادم + متابعة تجديده.
  Future<void> activate() async {
    await guarded('request permission', _fcm.requestPermission);
    await guarded('register token', () async {
      final t = await _fcm.getToken();
      if (t != null) await _tokens.register(token: t, platform: Platform.operatingSystem);
    });
    _refreshSub ??= _fcm.onTokenRefresh.listen(
      (t) => guarded(
        'refresh token',
        () => _tokens.register(token: t, platform: Platform.operatingSystem),
      ),
    );
  }

  /// عند تسجيل الخروج: يجب أن يُستدعى والمستخدم ما زال مسجّلاً (وإلا ترفض RLS حذف الصف).
  /// حتى لو فشل حذف الصف، deleteToken يوقف وصول أي رسالة لهذا الجهاز.
  Future<void> deactivate() async {
    await _refreshSub?.cancel();
    _refreshSub = null;
    await guarded('remove token row', () async {
      final t = await _fcm.getToken();
      if (t != null) await _tokens.remove(t);
    });
    await guarded('delete token', _fcm.deleteToken);
  }
}
