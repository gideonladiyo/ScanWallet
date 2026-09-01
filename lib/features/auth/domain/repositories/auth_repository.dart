import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> login(String email, String password);
  Future<Result<UserEntity>> register(
    String email,
    String password,
    String fullName,
  );
  Future<Result<UserEntity>> loginWithGoogle();
  Future<Result<void>> logout();
  Future<Result<UserEntity>> getCurrentSession();
}
