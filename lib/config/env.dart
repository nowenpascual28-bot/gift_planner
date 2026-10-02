/// Reads Supabase configuration that is passed in at build/run time with
/// `--dart-define-from-file=.env` (see `.env.example` in the project root).
///
/// Nothing secret lives in this file: the Supabase URL and publishable
/// (anon) key are safe to ship in a client app. Row Level Security policies
/// on the database are what actually protect user data.
class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// True once both values above have been supplied. The app uses this to
  /// decide whether to boot normally or show a setup screen.
  static bool get isConfigured =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;
}