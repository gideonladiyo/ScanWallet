import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._datasource);

  final AuthRemoteDatasource _datasource;

  @override
  Future<Result<UserEntity>> login(String email, String password) async {
    try {
      final response = await _datasource.signIn(email, password);
      final user = response.user;
      if (user == null) {
        return const Failure(ServerFailure('Respons autentikasi tidak valid.'));
      }
      return Success(UserModel.fromAuthUser(user));
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('not confirmed')) {
        return const Failure(ValidationFailure(AppStrings.emailNotConfirmed));
      }
      return Failure(mapExceptionToFailure(e));
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<UserEntity>> register(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final response = await _datasource.signUp(email, password, fullName);
      final user = response.user;
      if (user == null) {
        return const Failure(ServerFailure('Respons autentikasi tidak valid.'));
      }
      // With "Confirm email" enabled the user exists but no session is
      // issued — emailConfirmed stays false until the link is clicked.
      return Success(UserModel.fromAuthUser(user));
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<UserEntity>> loginWithGoogle() async {
    try {
      final response = await _datasource.signInWithGoogle();
      final user = response.user;
      if (user == null) {
        return const Failure(ServerFailure('Respons autentikasi tidak valid.'));
      }
      return Success(UserModel.fromAuthUser(user));
    } on AuthException catch (e) {
      if (e.message.contains('dibatalkan')) {
        return const Failure(ValidationFailure(AppStrings.googleCancelled));
      }
      return Failure(mapExceptionToFailure(e));
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _datasource.signOut();
      return const Success(null);
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<UserEntity>> getCurrentSession() async {
    try {
      final user = UserModel.fromSession(_datasource.currentSession);
      if (user == null) {
        return const Failure(CacheFailure('Tidak ada sesi aktif.'));
      }
      return Success(user);
    } catch (e) {
      return Failure(mapExceptionToFailure(e));
    }
  }
}
