import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentSessionUsecase {
  const GetCurrentSessionUsecase(this._repository);

  final AuthRepository _repository;

  Future<Result<UserEntity>> call() {
    return _repository.getCurrentSession();
  }
}
