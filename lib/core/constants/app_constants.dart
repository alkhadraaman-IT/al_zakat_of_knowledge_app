/// Application-wide constants for Zakat Al-Ilm.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'زكاة العلم';
  static const String appTagline = 'علمٌ يُنتَفَعُ به';
  static const String appVersion = 'v1.0.0';

  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://krhrpvcpjfstcfjlxhot.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_KwCyi03am395kLe1yAUNbA_1yH9_e7Z',
  );

  /// Custom deep-link scheme for OAuth callbacks.
  /// Must be declared in android/app/src/main/AndroidManifest.xml
  /// (intent-filter) and ios/Runner/Info.plist (CFBundleURLSchemes),
  /// and allow-listed in the Supabase Dashboard
  /// (Authentication → URL Configuration → Redirect URLs).
  static const String supabaseDeepLinkScheme = 'io.supabase.zakatalilm';

  /// OAuth redirect URL — must match the callback URL configured
  /// in the Supabase Dashboard. Uses the custom deep-link scheme
  /// to bring the user back into the app after OAuth.
  static const String supabaseRedirectUrl = String.fromEnvironment(
    'SUPABASE_REDIRECT_URL',
    defaultValue: 'io.supabase.zakatalilm://login-callback',
  );

  // Hive box names, Hive entry keys and SharedPreferences keys are centralized
  // in [AppKeys] (see core/constants/app_keys.dart).

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration glowAnimationDuration = Duration(milliseconds: 1500);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration buttonPressDuration = Duration(milliseconds: 150);

  // Layout
  static const double defaultScreenPadding = 20.0;
  static const double buttonHeight = 56.0;
  static const double textFieldHeight = 56.0;
  static const double borderRadius = 16.0;
  static const double cardBorderRadius = 12.0;


}
