import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecase {
  const RegisterUsecase(this._repository);

  final AuthRepository _repository;

  Future<Result<UserEntity>> call(
    String email,
    String password,
    String fullName,
  ) {
    return _repository.register(email, password, fullName);
  }
}
