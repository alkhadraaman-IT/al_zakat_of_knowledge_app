/// Centralized timeout constants for all network operations.
///
/// These values are tuned for the Supabase client's HTTP client
/// and for per-call timeouts applied via `Future.timeout()`.
/// A 10-second ceiling ensures the UI never blocks indefinitely
/// when the network is unavailable or slow.
class AppTimeouts {
  AppTimeouts._();

  /// Maximum time to wait for a connection to be established.
  static const Duration connection = Duration(seconds: 10);

  /// Maximum time an idle connection can stay open.
  static const Duration idle = Duration(seconds: 15);

  /// Per-call timeout for Supabase PostgREST / Storage / Auth requests.
  /// Matches the HTTP client connection timeout to avoid race conditions.
  static const Duration call = Duration(seconds: 10);

  /// Timeout for storage uploads (larger files may need more time).
  static const Duration storageUpload = Duration(seconds: 30);
}