/// Environment-driven configuration supplied via --dart-define at build time.
class AppConfig {
  const AppConfig._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Google Cloud "Web application" OAuth client ID — the same one
  /// configured in the Supabase Google provider. Public, not a secret.
  /// Required for native Google Sign-In (ID-token flow).
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );
}
