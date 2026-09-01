import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Exposes the initialized [SupabaseClient] via Riverpod DI
/// (ARCHITECTURE.md §6.1 — no manual singletons/GetIt).
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Auth state stream (ARCHITECTURE.md §5.2). The router listens to this to
/// redirect on session loss without an app restart.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});
