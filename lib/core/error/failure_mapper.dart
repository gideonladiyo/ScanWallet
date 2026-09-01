import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'exceptions.dart';
import 'failures.dart';

/// Maps raw data-layer exceptions (Supabase / network / cache) into typed
/// [AppFailure] values (AGENTS.md §2.6). Never let raw exceptions reach UI.
AppFailure mapExceptionToFailure(Object error) {
  final text = error.toString();
  final looksLikeNetworkError =
      text.contains('ClientException') ||
      text.contains('Failed to fetch') ||
      text.contains('Connection') ||
      text.contains('network');

  return switch (error) {
    AuthSessionException() => AuthFailure(error.message),
    NetworkException() => NetworkFailure(),
    CacheException() => CacheFailure(),
    ServerException() => ServerFailure(error.message),
    SocketException() ||
    TimeoutException() ||
    HttpException() ||
    HandshakeException() => NetworkFailure(),
    AuthException() =>
      looksLikeNetworkError ? NetworkFailure() : ServerFailure(error.message),
    PostgrestException() =>
      looksLikeNetworkError ? NetworkFailure() : ServerFailure(error.message),
    _ => looksLikeNetworkError ? NetworkFailure() : ServerFailure(text),
  };
}
