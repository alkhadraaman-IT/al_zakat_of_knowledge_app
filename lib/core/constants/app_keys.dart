// The UPPER_SNAKE_CASE naming of every key below is a deliberate contract:
// storage keys must stay stable and greppable across the whole codebase.
// ignore_for_file: constant_identifier_names

/// Central registry of every internal storage / preference key used by the app.
///
/// Every Hive box name, Hive entry key, SharedPreferences key and service
/// locator instance name lives here so keys are defined (and renamed) in one
/// single place. Both the constant names and their string values are written
/// in `UPPER_SNAKE_CASE`.
class AppKeys {
  AppKeys._();

  // ── Hive box names ────────────────────────────────────────────────────────
  static const String AUTH_BOX = 'AUTH_BOX';
  static const String USER_BOX = 'USER_BOX';
  static const String ONBOARDING_BOX = 'ONBOARDING_BOX';
  static const String FAVORITES_BOX = 'FAVORITES_BOX';
  static const String FAVORITES_V2 = 'FAVORITES_V2';
  static const String FAVORITE_SESSIONS_BOX = 'FAVORITE_SESSIONS_BOX';
  static const String FAVORITE_TOOLS_BOX = 'FAVORITE_TOOLS_BOX';
  static const String NOTIFICATIONS_LOCAL = 'NOTIFICATIONS_LOCAL';
  static const String NOTIFICATIONS_META = 'NOTIFICATIONS_META';

  // ── Hive entry keys ───────────────────────────────────────────────────────
  static const String CURRENT_USER = 'CURRENT_USER';
  static const String CURRENT_PROFILE = 'CURRENT_PROFILE';
  static const String SUBSCRIBED_TOPICS = 'SUBSCRIBED_TOPICS';

  // ── SharedPreferences keys ────────────────────────────────────────────────
  static const String ONBOARDING_COMPLETED = 'ONBOARDING_COMPLETED';
  static const String IS_LOGGED_IN = 'IS_LOGGED_IN';
  static const String AUTH_TOKEN = 'AUTH_TOKEN';
  static const String USER_ID = 'USER_ID';
  static const String IS_DARK_MODE = 'IS_DARK_MODE';
  static const String FCM_PENDING_MESSAGES = 'FCM_PENDING_MESSAGES';
  static const String FCM_CURRENT_UID = 'FCM_CURRENT_UID';
}
