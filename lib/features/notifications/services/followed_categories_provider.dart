import 'package:supabase_flutter/supabase_flutter.dart';

/// التصنيفات التي يتابعها المستخدم (جدول category_follows).
/// TODO: تأكد من أسماء الجدول والأعمدة (user_id, category_id) عندك.
class FollowedCategoriesProvider {
  final SupabaseClient _client;
  FollowedCategoriesProvider(this._client);

  /// null = فشل الجلب (لا نغيّر الاشتراكات). مجموعة فارغة = لا يتابع شيئاً فعلاً.
  Future<Set<String>?> fetch() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      final rows = await _client
          .from('category_follows')
          .select('category_id')
          .eq('user_id', uid)
          .timeout(const Duration(seconds: 10));
      return rows.map<String>((r) => r['category_id'].toString()).toSet();
    } catch (_) {
      return null;
    }
  }
}
