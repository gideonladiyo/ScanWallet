import '../../../../core/utils/result.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class CreateCategoryUsecase {
  const CreateCategoryUsecase(this._repository);

  final CategoryRepository _repository;

  Future<Result<CategoryEntity>> call(
    String name,
    TransactionType transactionType, {
    String? color,
  }) {
    return _repository.createCategory(name, transactionType, color: color);
  }
}
