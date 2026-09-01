import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../auth_providers.dart';
import '../../domain/entities/user_entity.dart';

/// Holds the current authenticated user (TASKS.md 2C.1).
class AuthController extends AsyncNotifier<UserEntity?> {
  @override
  FutureOr<UserEntity?> build() async {
    final result = await ref.watch(getCurrentSessionUsecaseProvider).call();
    return result.fold((_) => null, (user) => user);
  }

  Future<Result<void>> login(String email, String password) async {
    final result = await ref.read(loginUsecaseProvider).call(email, password);
    return result.fold((failure) => Failure(failure), (user) {
      state = AsyncData(user);
      return const Success(null);
    });
  }

  /// Returns the registered user. With "Confirm email" enabled the user is
  /// created but NOT logged in — [UserEntity.emailConfirmed] is false and
  /// the caller should show a "check your email" notice instead of
  /// navigating to the dashboard.
  Future<Result<UserEntity>> register(
    String email,
    String password,
    String fullName,
  ) async {
    final result = await ref
        .read(registerUsecaseProvider)
        .call(email, password, fullName);
    return result.fold((failure) => Failure(failure), (user) {
      // Only mark authenticated when Supabase issued a session
      // (email already confirmed / Google account).
      state = user.emailConfirmed ? AsyncData(user) : const AsyncData(null);
      return Success(user);
    });
  }

  Future<Result<void>> loginWithGoogle() async {
    final result = await ref.read(googleLoginUsecaseProvider).call();
    return result.fold((failure) => Failure(failure), (user) {
      state = AsyncData(user);
      return const Success(null);
    });
  }

  Future<void> logout() async {
    final result = await ref.read(logoutUsecaseProvider).call();
    result.fold((failure) => null, (_) => state = const AsyncData(null));
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserEntity?>(AuthController.new);
