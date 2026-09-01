import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/supabase_client_provider.dart';

/// Thin wrapper around Supabase Auth calls + native Google Sign-In
/// (ID-token flow, the approach recommended by Supabase for Flutter).
class AuthRemoteDatasource {
  AuthRemoteDatasource(this._client);

  final SupabaseClient _client;

  bool _googleInitialized = false;

  Future<AuthResponse> signIn(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password, String fullName) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  /// Native Google Sign-In: authenticate with Google on-device, then
  /// exchange the Google ID token for a Supabase session.
  Future<AuthResponse> signInWithGoogle() async {
    final idToken = await _getGoogleIdToken();
    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    // Also sign out from Google so the next tap shows the account picker.
    if (_googleInitialized) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Signing out of Google is best-effort; ignore failures.
      }
    }
  }

  Session? get currentSession => _client.auth.currentSession;

  Future<String> _getGoogleIdToken() async {
    final serverClientId = AppConfig.googleWebClientId;
    if (serverClientId.isEmpty) {
      throw AuthException(
        'GOOGLE_WEB_CLIENT_ID belum dikonfigurasi. Jalankan aplikasi dengan '
        '--dart-define=GOOGLE_WEB_CLIENT_ID=...',
      );
    }

    final google = GoogleSignIn.instance;
    if (!_googleInitialized) {
      await google.initialize(serverClientId: serverClientId);
      _googleInitialized = true;
    }

    final GoogleSignInAccount account;
    try {
      account = await google.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AuthException('Login Google dibatalkan.');
      }
      throw AuthException('Login Google gagal: ${e.code.name}');
    }

    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw AuthException('Login Google gagal: ID token tidak ditemukan.');
    }
    return idToken;
  }
}

final authRemoteDatasourceProvider = riverpod.Provider<AuthRemoteDatasource>((
  ref,
) {
  return AuthRemoteDatasource(ref.watch(supabaseClientProvider));
});
