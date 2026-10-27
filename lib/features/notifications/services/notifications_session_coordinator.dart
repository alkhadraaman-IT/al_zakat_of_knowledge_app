import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'fcm_service.dart';
import 'followed_categories_provider.dart';

/// يربط الإشعارات بحالة الدخول تلقائياً:
///  - دخول (أو جلسة موجودة عند الإقلاع) ← تفعيل الإشعارات
///  - خروج ← إيقافها (توكن، topics، تنبيهات مجدولة)
/// استخدم [logout] بدل auth.signOut() ليتم الإيقاف والجلسة ما زالت صالحة.
class NotificationsSessionCoordinator {
  final SupabaseClient _client;
  final FcmService _fcm;
  final FollowedCategoriesProvider _followed;

  NotificationsSessionCoordinator(this._client, this._fcm, this._followed);

  StreamSubscription<AuthState>? _sub;
  String? _activeUid;

  /// نسلسل الأحداث كي لا يتداخل تفعيل مع إيقاف.
  Future<void> _chain = Future.value();

  void listen() {
    _sub ??= _client.auth.onAuthStateChange.listen((s) {
      _chain = _chain.then((_) => _onAuth(s)).catchError((_) {});
    });
  }

  Future<void> _onAuth(AuthState s) async {
    switch (s.event) {
      case AuthChangeEvent.initialSession:
      case AuthChangeEvent.signedIn:
        final uid = s.session?.user.id;
        if (uid != null) await _activate(uid);
      case AuthChangeEvent.signedOut:
        await _deactivate();
      default:
        break; // tokenRefreshed, userUpdated... لا تغيّر شيئاً
    }
  }

  Future<void> _activate(String uid) async {
    if (_activeUid == uid) return; // signedIn قد يتكرر
    if (_activeUid != null) await _deactivate(); // تبديل حساب
    _activeUid = uid;
    final followed = await _followed.fetch();
    await _fcm.start(followedCategoryIds: followed);
  }

  Future<void> _deactivate() async {
    if (_activeUid == null) return;
    _activeUid = null;
    await _fcm.stop();
  }

  /// تسجيل الخروج الصحيح: أوقف الإشعارات أولاً ثم اخرج.
  Future<void> logout() async {
    _chain = _chain.then((_) => _deactivate()).catchError((_) {});
    await _chain;
    await _client.auth.signOut();
  }

  Future<void> dispose() async => _sub?.cancel();
}
