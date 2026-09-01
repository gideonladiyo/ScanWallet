import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';

/// Initializes the Supabase client once before the app runs.
class SupabaseConfig {
  const SupabaseConfig._();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  }
}
